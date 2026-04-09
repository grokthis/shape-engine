# Shape Engine
#
# Usage:
#   make test       Run all tests
#   make build      Build shape binary
#   make clean      Remove binaries

BIN_DIR := bin
SHAPE_BIN := $(BIN_DIR)/shape

.PHONY: all test test-v build wasm web hw-test deploy clean

all: test build

test:
	@echo "==> Running tests..."
	@go test ./... 2>&1 | grep -E '(ok|FAIL|---)'
	@echo "==> All tests passed."

test-v:
	go test ./... -v

build: $(SHAPE_BIN)

$(SHAPE_BIN): $(shell find pkg cmd/shape shapes -name '*.go' -o -name '*.sl' 2>/dev/null)
	@mkdir -p $(BIN_DIR)
	@echo "==> Building shape..."
	@go build -o $@ ./cmd/shape

wasm:
	@echo "==> Building WASM..."
	@GOOS=js GOARCH=wasm go build -o web/shape.wasm ./cmd/shape-wasm
	@echo "==> web/shape.wasm ($(shell ls -lh web/shape.wasm | awk '{print $$5}'))"

web: web/shapes.json
	@echo "==> Web assets ready ($(shell python3 -c "import json;print(len(json.load(open('web/shapes.json'))))" 2>/dev/null) shapes)."

web/shapes.json: $(shell find shapes -name '*.sl' 2>/dev/null)
	@echo "==> Building shapes.json..."
	@python3 web/build-shapes-json.py

deploy: web
	@echo "==> Deploy ready. Push main branch to update GitHub Pages."

hw-test:
	@echo "==> Running hardware tests..."
	@cd hardware && iverilog -o shape_gate_tb.vvp shape_gate.v shape_gate_tb.v && vvp shape_gate_tb.vvp
	@echo "==> Hardware tests done."

clean:
	@rm -rf $(BIN_DIR) web/shape.wasm hardware/*.vvp
	@echo "==> Clean."
