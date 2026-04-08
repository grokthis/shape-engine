// Package llm is the LLM interface for shape agents.
// Each API call is a moment. The LLM emits shape-lang.
// The prompt is a shape (cached on the provider).
// Each call is minimal: prompt cached, only context sent fresh.
package llm

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"time"
)

// Client calls an LLM API. Provider-agnostic interface,
// Anthropic implementation.
type Client struct {
	APIKey    string
	Model     string
	Endpoint  string
	MaxTokens int
	HTTP      *http.Client
}

// Response from the LLM.
type Response struct {
	Content    string // The shape-lang code emitted
	StopReason string // "end_turn", "max_tokens", "stop_sequence"
	InputToks  int
	OutputToks int
}

// NewClient creates an Anthropic client.
// Reads API key from config or ANTHROPIC_API_KEY env var.
func NewClient(apiKey, model string) *Client {
	if apiKey == "" {
		apiKey = os.Getenv("ANTHROPIC_API_KEY")
	}
	if model == "" {
		model = "claude-sonnet-4-20250514"
	}
	return &Client{
		APIKey:    apiKey,
		Model:     model,
		Endpoint:  "https://api.anthropic.com/v1/messages",
		MaxTokens: 4096,
		HTTP:      &http.Client{Timeout: 120 * time.Second},
	}
}

// Ready returns true if the client has an API key configured.
func (c *Client) Ready() bool {
	return c.APIKey != ""
}

// Call sends a message to the LLM.
// system is the cached system prompt (the prompt shape content).
// context is the per-step context (what changed, what's next).
func (c *Client) Call(system, context string) (*Response, error) {
	if c.APIKey == "" {
		return nil, fmt.Errorf("no API key configured (set ANTHROPIC_API_KEY or os.config.llm.api_key)")
	}

	// Build Anthropic Messages API request.
	// System prompt uses cache_control for prompt caching.
	body := map[string]interface{}{
		"model":      c.Model,
		"max_tokens": c.MaxTokens,
		"system": []map[string]interface{}{
			{
				"type": "text",
				"text": system,
				"cache_control": map[string]string{
					"type": "ephemeral",
				},
			},
		},
		"messages": []map[string]interface{}{
			{
				"role": "user",
				"content": []map[string]interface{}{
					{
						"type": "text",
						"text": context,
					},
				},
			},
		},
	}

	data, err := json.Marshal(body)
	if err != nil {
		return nil, fmt.Errorf("marshal: %w", err)
	}

	req, err := http.NewRequest("POST", c.Endpoint, bytes.NewReader(data))
	if err != nil {
		return nil, fmt.Errorf("request: %w", err)
	}
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("x-api-key", c.APIKey)
	req.Header.Set("anthropic-version", "2023-06-01")

	resp, err := c.HTTP.Do(req)
	if err != nil {
		return nil, fmt.Errorf("http: %w", err)
	}
	defer resp.Body.Close()

	respBody, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("read body: %w", err)
	}

	if resp.StatusCode != 200 {
		return nil, fmt.Errorf("API %d: %s", resp.StatusCode, string(respBody))
	}

	// Parse Anthropic response.
	var apiResp struct {
		Content []struct {
			Type string `json:"type"`
			Text string `json:"text"`
		} `json:"content"`
		StopReason string `json:"stop_reason"`
		Usage      struct {
			InputTokens  int `json:"input_tokens"`
			OutputTokens int `json:"output_tokens"`
		} `json:"usage"`
	}
	if err := json.Unmarshal(respBody, &apiResp); err != nil {
		return nil, fmt.Errorf("parse response: %w", err)
	}

	// Extract text content.
	var text string
	for _, block := range apiResp.Content {
		if block.Type == "text" {
			text += block.Text
		}
	}

	return &Response{
		Content:    text,
		StopReason: apiResp.StopReason,
		InputToks:  apiResp.Usage.InputTokens,
		OutputToks: apiResp.Usage.OutputTokens,
	}, nil
}

// Adapter wraps Client to satisfy the eval.go directCaller interface.
// This avoids importing pkg/llm in pkg/lang — eval.go uses duck typing.
// The ConfigFunc is called before each API call to pick up live config
// changes (e.g. API key pasted in Settings UI mid-session).
type Adapter struct {
	*Client
	ConfigFunc func() (apiKey, model string, maxTokens int)
}

// NewAdapter creates an adapter suitable for engine.SetExt("llm", adapter).
// configFn is optional — if provided, it's called before each API call
// to refresh the client's API key, model, and max tokens from live config.
func NewAdapter(c *Client, configFn ...func() (string, string, int)) *Adapter {
	a := &Adapter{Client: c}
	if len(configFn) > 0 && configFn[0] != nil {
		a.ConfigFunc = configFn[0]
	}
	return a
}

// Ready returns true if the client has an API key (checks live config).
func (a *Adapter) Ready() bool {
	a.refreshConfig()
	return a.Client.Ready()
}

// Call implements directCaller interface (content, stopReason, inputToks, outputToks, err).
func (a *Adapter) Call(system, context string) (string, string, int, int, error) {
	a.refreshConfig()
	resp, err := a.Client.Call(system, context)
	if err != nil {
		return "", "", 0, 0, err
	}
	return resp.Content, resp.StopReason, resp.InputToks, resp.OutputToks, nil
}

func (a *Adapter) refreshConfig() {
	if a.ConfigFunc == nil {
		return
	}
	key, model, maxToks := a.ConfigFunc()
	if key != "" {
		a.Client.APIKey = key
	}
	if model != "" {
		a.Client.Model = model
	}
	if maxToks > 0 {
		a.Client.MaxTokens = maxToks
	}
}
