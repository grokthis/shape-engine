package lang

import (
	"encoding/json"
	"fmt"
	"sort"
	"strconv"
)

// jsonEncode converts a shape-lang value to a JSON string.
func jsonEncode(v value) string {
	switch v.kind {
	case "nil":
		return "null"
	case "string":
		b, _ := json.Marshal(v.str)
		return string(b)
	case "int":
		return strconv.Itoa(v.num)
	case "float":
		return strconv.FormatFloat(v.flt, 'f', -1, 64)
	case "bool":
		if v.boolean {
			return "true"
		}
		return "false"
	case "list":
		var parts []string
		for _, elem := range v.list {
			parts = append(parts, jsonEncode(elem))
		}
		return "[" + jsonJoin(parts, ",") + "]"
	case "map":
		var keys []string
		for k := range v.mp {
			keys = append(keys, k)
		}
		sort.Strings(keys)
		var parts []string
		for _, k := range keys {
			kb, _ := json.Marshal(k)
			parts = append(parts, string(kb)+":"+jsonEncode(v.mp[k]))
		}
		return "{" + jsonJoin(parts, ",") + "}"
	case "shapes":
		var parts []string
		for _, s := range v.shapes {
			m := make(map[string]interface{})
			m["id"] = string(s.ID)
			m["content"] = s.Character.Content
			if len(s.Character.Dimensions) > 0 {
				m["dims"] = s.Character.Dimensions
			}
			if len(s.Structure.Transformation.Deps) > 0 {
				var deps []string
				for _, d := range s.Structure.Transformation.Deps {
					deps = append(deps, string(d))
				}
				m["deps"] = deps
			}
			m["layer"] = s.Structure.Emergence.Layer
			b, _ := json.Marshal(m)
			parts = append(parts, string(b))
		}
		return "[" + jsonJoin(parts, ",") + "]"
	default:
		return fmt.Sprintf("%q", v.String())
	}
}

func jsonJoin(parts []string, sep string) string {
	result := ""
	for i, p := range parts {
		if i > 0 {
			result += sep
		}
		result += p
	}
	return result
}

// jsonDecode parses a JSON string into a shape-lang value.
func jsonDecode(s string) (value, error) {
	var raw interface{}
	if err := json.Unmarshal([]byte(s), &raw); err != nil {
		return nilVal(), err
	}
	return jsonToValue(raw), nil
}

func jsonToValue(raw interface{}) value {
	switch v := raw.(type) {
	case nil:
		return nilVal()
	case bool:
		return boolVal(v)
	case float64:
		if v == float64(int(v)) {
			return intVal(int(v))
		}
		return floatVal(v)
	case string:
		return strVal(v)
	case []interface{}:
		var elems []value
		for _, e := range v {
			elems = append(elems, jsonToValue(e))
		}
		return listVal(elems)
	case map[string]interface{}:
		m := make(map[string]value, len(v))
		for k, val := range v {
			m[k] = jsonToValue(val)
		}
		return mapVal(m)
	default:
		return strVal(fmt.Sprintf("%v", v))
	}
}
