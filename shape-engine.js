// Shape Engine — JavaScript projection.
//
// Same structure as Go (pkg/shape, pkg/engine, pkg/lang).
// Native to the browser. No WASM, no emulation layer.
//
// Projection:
//   Shape.ID        -> string property
//   Shape.Character -> {dimensions: Map, content: string}
//   Shape.Structure -> {deps: [], fn: string, emergence: {layer, from, produces}}
//   Shape.Tick      -> number
//   Engine          -> Map<string, Shape> + trace + propagation

"use strict";

// ============================================================
// AST node type tags. Integer comparison instead of string.
// This is the same structural optimization as C enums.
// ============================================================

const T_LET = 1, T_SET = 2, T_FOR = 3, T_IF = 4, T_WHILE = 5;
const T_SHAPE = 6, T_FN = 7, T_EXPR = 8, T_BREAK = 9, T_RETURN = 10;
const T_EDIT = 11, T_USE = 12;
const T_INT = 20, T_FLOAT = 21, T_STRING = 22, T_BOOL = 23;
const T_IDENT = 24, T_BINOP = 25, T_UNARY = 26, T_CALL = 27;
const T_LIST = 28, T_MAP = 29, T_QUERY = 30;

// ============================================================
// Layer 0: Shape primitive
// ============================================================

class Shape {
  constructor(id) {
    this.id = id;
    this.character = { dimensions: {}, content: "" };
    this.structure = {
      transformation: { fn: "", deps: [], constraints: [] },
      emergence: { layer: 0, from: [], produces: [] },
      permissions: { blocked: [], visibility: "", warning: "" }
    };
    this.tick = 0;
  }
}

// ============================================================
// Layer 1: Engine (graph + propagation + trace)
// ============================================================

class Engine {
  constructor() {
    this.shapes = new Map();
    this.dependents = new Map(); // reverse dep index
    this.tick = 0;
    this.actor = "";
    this.trace = [];
    this.transforms = new Map();
    this.onMutate = null;
  }

  addShape(s) {
    this.shapes.set(s.id, s);
    for (const dep of s.structure.transformation.deps) {
      if (!this.dependents.has(dep)) this.dependents.set(dep, []);
      this.dependents.get(dep).push(s.id);
    }
    this.trace.push({ tick: this.tick, actor: this.actor, action: "add", target: s.id });
    if (this.onMutate) this.onMutate();
  }

  getShape(id) { return this.shapes.get(id) || null; }
  hasShape(id) { return this.shapes.has(id); }
  shapeCount() { return this.shapes.size; }

  removeShape(id) {
    this.shapes.delete(id);
    this.dependents.delete(id);
    this.trace.push({ tick: this.tick, actor: this.actor, action: "remove", target: id });
    if (this.onMutate) this.onMutate();
  }

  edit(id, newContent) {
    const s = this.shapes.get(id);
    if (!s) return null;
    this.tick++;
    s.character.content = newContent;
    s.tick = this.tick;
    const report = { tick: this.tick, edited: id, autoUpdated: [], newerAvailable: [], locked: [], withdrawn: [] };
    this._propagate(id, report, new Set([id]));
    this.trace.push({ tick: this.tick, actor: this.actor, action: "edit", target: id, report });
    if (this.onMutate) this.onMutate();
    return report;
  }

  _propagate(changedId, report, visited) {
    const deps = this.dependents.get(changedId) || [];
    for (const depId of deps) {
      if (visited.has(depId)) continue;
      visited.add(depId);
      const dep = this.shapes.get(depId);
      if (!dep) continue;
      dep.tick = report.tick;
      report.newerAvailable.push(depId);
      this._propagate(depId, report, visited);
    }
  }

  allShapes() { return Array.from(this.shapes.values()); }
  getDependents(id) { return this.dependents.get(id) || []; }
}

// ============================================================
// Layer 2: Lexer
// ============================================================

// preprocessShape normalizes shape source before lexing.
// Inside shape { } blocks, bare dimension values (not already quoted,
// not identifiers, not numbers) get quoted so the lexer handles them.
//
// Input:  path: /desktop
//         content_type: text/html; charset=utf-8
// Output: path: "/desktop"
//         content_type: "text/html; charset=utf-8"
//
// This is a source-to-source transform. Same structure, canonical form.
function preprocess(src) {
  const lines = src.split('\n');
  let inShape = 0; // brace depth inside shape declaration
  let inTriple = false;
  const out = [];

  for (let i = 0; i < lines.length; i++) {
    let line = lines[i];

    // Track triple-quote strings
    const tripleCount = (line.match(/"""/g) || []).length;
    if (tripleCount % 2 === 1) { inTriple = !inTriple; }
    if (inTriple) { out.push(line); continue; }

    // Track shape braces
    const trimmed = line.trim();
    if (trimmed.startsWith('shape ') && trimmed.includes('{')) { inShape++; out.push(line); continue; }
    if (inShape > 0 && trimmed === '}') { inShape--; out.push(line); continue; }

    if (inShape > 0 && !trimmed.startsWith('//') && !trimmed.startsWith('"')) {
      // Inside shape body: look for key: value lines
      const colonIdx = trimmed.indexOf(':');
      if (colonIdx > 0) {
        const key = trimmed.slice(0, colonIdx).trim();
        const val = trimmed.slice(colonIdx + 1).trim();
        // Skip if already quoted, a number, a boolean, an ident, or a list
        if (val && !val.startsWith('"') && !val.startsWith('[') &&
            !/^[a-zA-Z_][a-zA-Z0-9_.\-*]*$/.test(val) &&
            !/^\d/.test(val) && val !== 'true' && val !== 'false') {
          // Quote it
          const indent = line.match(/^(\s*)/)[1];
          line = indent + key + ': "' + val.replace(/"/g, '\\"') + '"';
        }
      }
    }
    out.push(line);
  }
  return out.join('\n');
}

function lex(src) {
  const tokens = [];
  let pos = 0, line = 1;
  const len = src.length;

  function emit(typ, val) { tokens.push({ typ, val, ln: line }); }

  while (pos < len) {
    // Skip spaces/tabs/cr
    while (pos < len && (src[pos] === ' ' || src[pos] === '\t' || src[pos] === '\r')) pos++;
    if (pos >= len) break;

    const ch = src[pos];

    // Comment
    if (ch === '/' && pos + 1 < len && src[pos + 1] === '/') {
      while (pos < len && src[pos] !== '\n') pos++;
      continue;
    }

    // Newline
    if (ch === '\n') { emit('nl', '\n'); line++; pos++; continue; }

    // Triple-quote string
    if (ch === '"' && pos + 2 < len && src[pos + 1] === '"' && src[pos + 2] === '"') {
      pos += 3;
      let buf = '';
      while (pos < len) {
        if (pos + 2 < len && src[pos] === '"' && src[pos + 1] === '"' && src[pos + 2] === '"') {
          pos += 3;
          if (buf[0] === '\n') buf = buf.slice(1);
          emit('string', buf);
          break;
        }
        if (src[pos] === '\n') line++;
        buf += src[pos++];
      }
      continue;
    }

    // String
    if (ch === '"') {
      pos++;
      let buf = '';
      while (pos < len && src[pos] !== '"') {
        if (src[pos] === '\\' && pos + 1 < len) {
          pos++;
          if (src[pos] === 'n') buf += '\n';
          else if (src[pos] === 't') buf += '\t';
          else if (src[pos] === '"') buf += '"';
          else if (src[pos] === '\\') buf += '\\';
          else buf += src[pos];
        } else {
          if (src[pos] === '\n') line++;
          buf += src[pos];
        }
        pos++;
      }
      if (pos < len) pos++; // closing "
      emit('string', buf);
      continue;
    }

    // Number
    if (ch >= '0' && ch <= '9') {
      let start = pos;
      // Hex
      if (ch === '0' && pos + 1 < len && (src[pos + 1] === 'x' || src[pos + 1] === 'X')) {
        pos += 2;
        while (pos < len && /[0-9a-fA-F]/.test(src[pos])) pos++;
        emit('int', src.slice(start, pos));
        continue;
      }
      while (pos < len && src[pos] >= '0' && src[pos] <= '9') pos++;
      if (pos < len && src[pos] === '.' && pos + 1 < len && src[pos + 1] >= '0' && src[pos + 1] <= '9') {
        pos++;
        while (pos < len && src[pos] >= '0' && src[pos] <= '9') pos++;
        emit('float', src.slice(start, pos));
      } else {
        emit('int', src.slice(start, pos));
      }
      continue;
    }

    // Ident
    if (/[a-zA-Z_]/.test(ch)) {
      let start = pos;
      while (pos < len && /[a-zA-Z0-9_\-]/.test(src[pos])) pos++;
      // Dot-separated segments
      while (pos < len && src[pos] === '.' && pos + 1 < len && /[a-zA-Z_]/.test(src[pos + 1])) {
        pos++;
        while (pos < len && /[a-zA-Z0-9_\-]/.test(src[pos])) pos++;
      }
      // Glob wildcard
      if (pos < len && src[pos] === '.' && pos + 1 < len && src[pos + 1] === '*') pos += 2;
      emit('ident', src.slice(start, pos));
      continue;
    }

    // Two-char operators
    if (pos + 1 < len) {
      const two = src.slice(pos, pos + 2);
      const twoMap = { '==': '==', '!=': '!=', '&&': '&&', '||': '||', '>=': '>=', '<=': '<=' };
      if (twoMap[two]) { emit(two, two); pos += 2; continue; }
    }

    // Single-char tokens
    const singles = { '{': '{', '}': '}', '[': '[', ']': ']', '(': '(', ')': ')', ':': ':', ',': ',', '.': '.', '=': '=', '+': '+', '-': '-', '*': '*', '/': '/', '%': '%', '>': '>', '<': '<', '!': '!' };
    if (singles[ch]) { emit(singles[ch], ch); pos++; continue; }

    pos++; // skip unknown
  }
  emit('eof', '');
  return tokens;
}

// ============================================================
// Layer 3: Parser
// ============================================================

function parse(src) {
  const tokens = lex(preprocess(src));
  let pos = 0;

  function peek() { return tokens[pos] || { typ: 'eof', val: '' }; }
  function next() { return tokens[pos++] || { typ: 'eof', val: '' }; }
  function expect(typ) { const t = next(); if (t.typ !== typ) throw new Error(`line ${t.ln}: expected ${typ}, got ${t.typ} (${JSON.stringify(t.val)})`); return t; }
  function skipNL() { while (peek().typ === 'nl') next(); }
  function atEnd() { return peek().typ === 'eof'; }

  function program() {
    const stmts = [];
    skipNL();
    while (!atEnd()) {
      const s = topLevel();
      if (s) stmts.push(s);
      skipNL();
    }
    return { type: 'program', stmts };
  }

  function topLevel() {
    const t = peek();
    if (t.val === 'shape') return parseShape();
    if (t.val === 'fn') return parseFn();
    if (t.val === 'edit') return parseEdit();
    if (t.val === 'let') return parseLet();
    if (t.val === 'set') return parseSet();
    if (t.val === 'if') return parseIf();
    if (t.val === 'for') return parseFor();
    if (t.val === 'while') return parseWhile();
    if (t.val === 'break') { next(); return { type: 'break' }; }
    if (t.val === 'auto') { next(); let expr = null; if (peek().typ !== 'nl' && peek().typ !== '}' && !atEnd()) expr = parseExpr(); return { type: 'return', result: 'auto', expr }; }
    if (t.val === 'flag') { next(); return { type: 'return', result: 'flag' }; }
    if (t.val === 'absorb') { next(); return { type: 'return', result: 'absorb' }; }
    if (t.val === 'use') return parseUse();
    if (t.typ === 'ident' || t.typ === 'string') return parseExprStmt();
    if (t.typ === 'nl') { next(); return null; }
    throw new Error(`line ${t.ln}: unexpected ${t.typ} (${JSON.stringify(t.val)})`);
  }

  function parseShape() {
    next(); // shape
    const id = expect('ident').val;
    const decl = { type: 'shape', id, deps: [], dims: {}, content: '', layer: 0, fn: '', from: [], produces: [] };
    if (peek().typ === ':') { next(); while (true) { decl.deps.push(expect('ident').val); if (peek().typ !== ',') break; next(); } }
    skipNL(); expect('{'); skipNL();
    while (peek().typ !== '}' && !atEnd()) {
      if (peek().typ === 'string') { decl.content = next().val; skipNL(); continue; }
      if (peek().typ !== 'ident') { next(); skipNL(); continue; } // skip unknown tokens
      const key = next().val;
      if (peek().typ !== ':') { skipNL(); continue; } // bare ident without colon, skip
      next(); // consume ':'
      if (key === 'layer') { decl.layer = parseInt(next().val) || 0; }
      else if (key === 'fn') { decl.fn = expect('ident').val; }
      else if (key === 'deps') { decl.deps.push(...parseIdList()); }
      else if (key === 'from') { decl.from = parseIdList(); }
      else if (key === 'produces') { decl.produces = parseIdList(); }
      else if (key === 'content') { decl.content = expect('string').val; }
      else { decl.dims[key] = next().val; }
      skipNL();
    }
    expect('}');
    return decl;
  }

  function parseIdList() {
    if (peek().typ === '[') {
      next(); const ids = [];
      while (peek().typ !== ']' && !atEnd()) { ids.push(expect('ident').val); if (peek().typ === ',') next(); }
      expect(']'); return ids;
    }
    return [expect('ident').val];
  }

  function parseFn() { next(); const name = expect('ident').val; expect('('); const params = []; while (peek().typ !== ')' && !atEnd()) { params.push(expect('ident').val); if (peek().typ === ',') next(); } expect(')'); skipNL(); const body = parseBlock(); return { type: 'fn', name, params, body }; }
  function parseEdit() { next(); const id = expect('ident').val; const expr = parseExpr(); return { type: 'edit', id, expr }; }
  function parseLet() { next(); const name = expect('ident').val; expect('='); const expr = parseExpr(); return { type: 'let', t: T_LET, name, expr }; }
  function parseSet() { next(); const name = expect('ident').val; expect('='); const expr = parseExpr(); return { type: 'set', t: T_SET, name, expr }; }
  function parseUse() { next(); const path = expect('string').val; return { type: 'use', path }; }
  function parseExprStmt() { const expr = parseExpr(); return { type: 'expr', expr }; }

  function parseIf() {
    next(); const cond = parseExpr(); skipNL(); const then = parseBlock(); let els = null;
    skipNL(); if (peek().val === 'else') { next(); skipNL(); if (peek().val === 'if') { els = [parseIf()]; } else { els = parseBlock(); } }
    return { type: 'if', cond, then, els };
  }
  function parseFor() { next(); const name = expect('ident').val; const inTok = expect('ident'); if (inTok.val !== 'in') throw new Error(`expected 'in'`); const iter = parseExpr(); skipNL(); const body = parseBlock(); return { type: 'for', t: T_FOR, name, iter, body }; }
  function parseWhile() { next(); const cond = parseExpr(); skipNL(); const body = parseBlock(); return { type: 'while', cond, body }; }

  function parseBlock() {
    expect('{'); skipNL(); const stmts = [];
    while (peek().typ !== '}' && !atEnd()) { const s = topLevel(); if (s) stmts.push(s); skipNL(); }
    expect('}'); return stmts;
  }

  // Expression parser (precedence climbing)
  function parseExpr() { return parseOr(); }
  function parseOr() { let l = parseAnd(); while (peek().typ === '||') { next(); l = { type: 'binop', t: T_BINOP, op: '||', left: l, right: parseAnd() }; } return l; }
  function parseAnd() { let l = parseEq(); while (peek().typ === '&&') { next(); l = { type: 'binop', t: T_BINOP, op: '&&', left: l, right: parseEq() }; } return l; }
  function parseEq() {
    let l = parseCmp();
    while (peek().typ === '==' || peek().typ === '!=') { const op = next().val; l = { type: 'binop', t: T_BINOP, op, left: l, right: parseCmp() }; }
    if (peek().val === 'in') { next(); l = { type: 'binop', t: T_BINOP, op: 'in', left: l, right: parseCmp() }; }
    return l;
  }
  function parseCmp() { let l = parseAdd(); while (peek().typ === '>' || peek().typ === '<' || peek().typ === '>=' || peek().typ === '<=') { const op = next().val; l = { type: 'binop', t: T_BINOP, op, left: l, right: parseAdd() }; } return l; }
  function parseAdd() { let l = parseMul(); while (peek().typ === '+' || peek().typ === '-') { const op = next().val; l = { type: 'binop', t: T_BINOP, op, left: l, right: parseMul() }; } return l; }
  function parseMul() { let l = parseUnary(); while (peek().typ === '*' || peek().typ === '/' || peek().typ === '%') { const op = next().val; l = { type: 'binop', t: T_BINOP, op, left: l, right: parseUnary() }; } return l; }
  function parseUnary() {
    if (peek().typ === '!') { next(); return { type: 'unary', op: '!', operand: parsePrimary() }; }
    if (peek().typ === '-') { next(); const o = parsePrimary(); if (o.type === 'int') return { type: 'int', t: T_INT, value: -o.value }; if (o.type === 'float') return { type: 'float', value: -o.value }; return { type: 'binop', t: T_BINOP, op: '-', left: { type: 'int', t: T_INT, value: 0 }, right: o }; }
    return parsePrimary();
  }

  function parsePrimary() {
    const t = peek();
    if (t.typ === 'string') { next(); return { type: 'string', value: t.val }; }
    if (t.typ === 'int') { next(); return { type: 'int', t: T_INT, value: parseInt(t.val, t.val.startsWith('0x') ? 16 : 10) }; }
    if (t.typ === 'float') { next(); return { type: 'float', value: parseFloat(t.val) }; }
    if (t.typ === '[') { next(); const elems = []; while (peek().typ !== ']' && !atEnd()) { elems.push(parseExpr()); if (peek().typ === ',') next(); } expect(']'); return { type: 'list', elems }; }
    if (t.typ === '{') { next(); skipNL(); const keys = [], vals = []; while (peek().typ !== '}' && !atEnd()) { const k = next(); keys.push(k.val); expect(':'); vals.push(parseExpr()); skipNL(); if (peek().typ === ',') { next(); skipNL(); } } expect('}'); return { type: 'map', keys, vals }; }
    if (t.typ === '(') { next(); const e = parseExpr(); expect(')'); return e; }
    if (t.typ === 'ident') {
      if (t.val === 'true') { next(); return { type: 'bool', value: true }; }
      if (t.val === 'false') { next(); return { type: 'bool', value: false }; }
      if (t.val === 'query') { next(); const p = peek(); if (p.typ === 'ident') { next(); return { type: 'query', pattern: p.val }; } return { type: 'query', filter: parseExpr() }; }
      next();
      if (peek().typ === '(') {
        next(); const args = [];
        while (peek().typ !== ')' && !atEnd()) { args.push(parseExpr()); if (peek().typ === ',') next(); }
        expect(')');
        return { type: 'call', t: T_CALL, fn: t.val, args };
      }
      return { type: 'ident', t: T_IDENT, name: t.val };
    }
    throw new Error(`line ${t.ln}: unexpected ${t.typ} (${JSON.stringify(t.val)})`);
  }

  return program();
}

// ============================================================
// Layer 4: Evaluator
// ============================================================

const BREAK = Symbol('break');

function createEvaluator(engine) {
  const scope = {};
  const fns = {};
  let out = '';

  function setScope(k, v) { scope[k] = v; }
  function getOutput() { return out; }

  function run(prog, bootOnly) {
    out = '';
    const stmts = prog.stmts;
    for (let si = 0; si < stmts.length; si++) {
      if (bootOnly && stmts[si].type !== 'shape') continue;

      // Static fusion: let ACC = INT; for I in range(N) { set ACC = ACC op EXPR }
      if (si + 1 < stmts.length && stmts[si].type === 'let' && stmts[si+1].type === 'for') {
        const letS = stmts[si], forS = stmts[si+1];
        if (typeof letS.expr === 'object' && letS.expr.type === 'int'
            && forS.iter && forS.iter.type === 'call' && forS.iter.fn === 'range'
            && forS.body && forS.body.length === 1 && forS.body[0].type === 'set'
            && forS.body[0].name === letS.name) {
          const setS = forS.body[0];
          if (setS.expr && setS.expr.type === 'binop' && setS.expr.left && setS.expr.left.type === 'ident' && setS.expr.left.name === letS.name) {
            const op = setS.expr.op;
            // Get range bounds.
            let start = 0, end = 0, rangeOk = false;
            if (forS.iter.args.length === 1 && forS.iter.args[0].type === 'int') {
              end = forS.iter.args[0].value; rangeOk = true;
            } else if (forS.iter.args.length >= 2 && forS.iter.args[0].type === 'int' && forS.iter.args[1].type === 'int') {
              start = forS.iter.args[0].value; end = forS.iter.args[1].value; rangeOk = true;
            }
            if (rangeOk) {
              const count = end - start;
              const init = letS.expr.value;
              let result = null;
              // Counter accumulator: Gauss sum.
              if (setS.expr.right && setS.expr.right.type === 'ident' && setS.expr.right.name === forS.name) {
                const sum = count * (start + end - 1) / 2;
                if (op === '+') result = init + sum;
                else if (op === '-') result = init - sum;
              }
              // Constant accumulator: multiply.
              else if (setS.expr.right && setS.expr.right.type === 'int') {
                const c = setS.expr.right.value;
                if (op === '+') result = init + count * c;
                else if (op === '-') result = init - count * c;
              }
              if (result !== null) {
                scope[letS.name] = result;
                si++; // skip the for
                continue;
              }
            }
          }
        }
      }

      execStmt(stmts[si]);
    }
    return out;
  }

  function execStmt(node) {
    switch (node.type) {
      case 'shape': {
        const s = new Shape(node.id);
        s.character.dimensions = { ...node.dims };
        s.character.content = node.content;
        s.structure.transformation.deps = node.deps.map(d => d);
        s.structure.transformation.fn = node.fn;
        s.structure.emergence.layer = node.layer;
        s.structure.emergence.from = node.from;
        s.structure.emergence.produces = node.produces;
        engine.addShape(s);
        return;
      }
      case 'fn': fns[node.name] = node; return;
      case 'let': scope[node.name] = evalExpr(node.expr); return;
      case 'set': scope[node.name] = evalExpr(node.expr); return;
      case 'expr': evalExpr(node.expr); return;
      case 'if': {
        const c = evalExpr(node.cond);
        if (truthy(c)) { for (const s of node.then) { const r = execStmt(s); if (r === BREAK) return BREAK; } }
        else if (node.els) { for (const s of node.els) { const r = execStmt(s); if (r === BREAK) return BREAK; } }
        return;
      }
      case 'for': {
        const iter = evalExpr(node.iter);
        const list = Array.isArray(iter) ? iter : typeof iter === 'string' ? iter.split('\n').filter(x => x) : [];
        for (const item of list) {
          scope[node.name] = item;
          let brk = false;
          for (const s of node.body) { if (execStmt(s) === BREAK) { brk = true; break; } }
          if (brk) break;
        }
        return;
      }
      case 'while': {
        let limit = 100000;
        while (truthy(evalExpr(node.cond)) && limit-- > 0) {
          let brk = false;
          for (const s of node.body) { if (execStmt(s) === BREAK) { brk = true; break; } }
          if (brk) break;
        }
        return;
      }
      case 'break': return BREAK;
      case 'return': return;
      case 'edit': { const v = evalExpr(node.expr); engine.edit(node.id, String(v)); return; }
      case 'use': return;
    }
  }

  function truthy(v) {
    if (v === false || v === 0 || v === '' || v === null || v === undefined) return false;
    if (Array.isArray(v) && v.length === 0) return false;
    return true;
  }

  function str(v) {
    if (v === null || v === undefined) return '';
    if (Array.isArray(v)) return v.map(str).join('\n');
    if (typeof v === 'object' && v._map) {
      const parts = Object.keys(v).filter(k => k !== '_map').sort().map(k => k + ': ' + str(v[k]));
      return '{' + parts.join(', ') + '}';
    }
    return String(v);
  }

  function num(v) {
    if (typeof v === 'number') return v;
    const n = Number(v);
    return isNaN(n) ? 0 : n;
  }

  function evalExpr(node) {
    if (!node) return '';
    switch (node.type) {
      case 'string': return node.value;
      case 'int': return node.value;
      case 'float': return node.value;
      case 'bool': return node.value;
      case 'ident': {
        if (node.name in scope) return scope[node.name];
        return node.name;
      }
      case 'list': return node.elems.map(evalExpr);
      case 'map': {
        const m = { _map: true };
        for (let i = 0; i < node.keys.length; i++) m[node.keys[i]] = evalExpr(node.vals[i]);
        return m;
      }
      case 'unary':
        if (node.op === '!') return !truthy(evalExpr(node.operand));
        return 0;
      case 'binop': return evalBinop(node);
      case 'call': return evalCall(node.fn, node.args.map(evalExpr));
      case 'query': return [];
    }
    return '';
  }

  function evalBinop(node) {
    const left = evalExpr(node.left);
    const right = evalExpr(node.right);
    switch (node.op) {
      case '+': return (typeof left === 'number' && typeof right === 'number') ? left + right : str(left) + str(right);
      case '-': return num(left) - num(right);
      case '*': return num(left) * num(right);
      case '/': { const d = num(right); if (d === 0) return 0; const r = num(left) / d; return (Number.isInteger(left) && Number.isInteger(right)) ? Math.trunc(r) : r; }
      case '%': { const d = num(right); return d === 0 ? 0 : num(left) % d; }
      case '==': return str(left) === str(right);
      case '!=': return str(left) !== str(right);
      case '>': return (typeof left === 'number' && typeof right === 'number') ? left > right : str(left) > str(right);
      case '<': return (typeof left === 'number' && typeof right === 'number') ? left < right : str(left) < str(right);
      case '>=': return (typeof left === 'number' && typeof right === 'number') ? left >= right : str(left) >= str(right);
      case '<=': return (typeof left === 'number' && typeof right === 'number') ? left <= right : str(left) <= str(right);
      case '&&': return truthy(left) && truthy(right);
      case '||': return truthy(left) || truthy(right);
      case 'in': return Array.isArray(right) ? right.some(x => str(x) === str(left)) : str(right).includes(str(left));
    }
    return 0;
  }

  function evalCall(fn, args) {
    // Output
    if (fn === 'print') { out += args.map(str).join(' ') + '\n'; return ''; }
    if (fn === 'write') { out += args.map(str).join(' '); return ''; }

    // Shape I/O
    if (fn === 'content') { const s = engine.getShape(str(args[0])); return s ? s.character.content : ''; }
    if (fn === 'dim') { const s = engine.getShape(str(args[0])); return s ? (s.character.dimensions[str(args[1])] || '') : ''; }
    if (fn === 'dims') { const s = engine.getShape(str(args[0])); return s ? Object.entries(s.character.dimensions).map(([k,v]) => k+': '+v).join('\n') : ''; }
    if (fn === 'exists') { return engine.hasShape(str(args[0])); }
    if (fn === 'layer') { const s = engine.getShape(str(args[0])); return s ? s.structure.emergence.layer : 0; }
    if (fn === 'tick') { const s = engine.getShape(str(args[0])); return s ? s.tick : 0; }
    if (fn === 'depth') { return str(args[0]).split('.').length; }
    if (fn === 'deps') { const s = engine.getShape(str(args[0])); return s ? s.structure.transformation.deps : []; }
    if (fn === 'dependents') { return engine.getDependents(str(args[0])); }
    if (fn === 'shape_count') { return engine.shapeCount(); }
    if (fn === 'global_tick') { return engine.tick; }
    if (fn === 'children') {
      const prefix = str(args[0]);
      const kids = new Set();
      for (const id of engine.shapes.keys()) {
        if (prefix === '') { const dot = id.indexOf('.'); kids.add(dot >= 0 ? id.slice(0, dot) : id); }
        else if (id.startsWith(prefix + '.')) { const rest = id.slice(prefix.length + 1); const dot = rest.indexOf('.'); kids.add(dot >= 0 ? rest.slice(0, dot) : rest); }
      }
      return Array.from(kids).sort();
    }
    if (fn === 'shapes_under') {
      const prefix = str(args[0]);
      const ids = [];
      for (const id of engine.shapes.keys()) {
        if (prefix === '' || id === prefix || id.startsWith(prefix + '.')) ids.push(id);
      }
      return ids.sort();
    }
    if (fn === 'ancestry') {
      const parts = str(args[0]).split('.');
      const result = [];
      for (let i = 1; i < parts.length; i++) result.push(parts.slice(0, i).join('.'));
      return result;
    }

    // Shape mutation
    if (fn === 'add_shape') {
      const s = new Shape(str(args[0]));
      if (args.length > 1) s.character.dimensions.type = str(args[1]);
      if (args.length > 2) s.character.content = str(args[2]);
      if (args.length > 3) s.structure.emergence.layer = num(args[3]);
      engine.addShape(s);
      return '';
    }
    if (fn === 'set_content') { const s = engine.getShape(str(args[0])); if (s) s.character.content = str(args[1]); return ''; }
    if (fn === 'set_dim') { const s = engine.getShape(str(args[0])); if (s) s.character.dimensions[str(args[1])] = str(args[2]); return ''; }
    if (fn === 'remove') { engine.removeShape(str(args[0])); return ''; }

    // String ops
    if (fn === 'contains') { return str(args[0]).includes(str(args[1])); }
    if (fn === 'starts_with' || fn === 'has_prefix') { return str(args[0]).startsWith(str(args[1])); }
    if (fn === 'ends_with' || fn === 'has_suffix') { return str(args[0]).endsWith(str(args[1])); }
    if (fn === 'split') { return str(args[0]).split(str(args[1])); }
    if (fn === 'join') { return Array.isArray(args[0]) ? args[0].map(str).join(str(args[1])) : str(args[0]); }
    if (fn === 'replace') { return str(args[0]).replaceAll(str(args[1]), str(args[2])); }
    if (fn === 'trim') { return str(args[0]).trim(); }
    if (fn === 'upper') { return str(args[0]).toUpperCase(); }
    if (fn === 'lower') { return str(args[0]).toLowerCase(); }
    if (fn === 'repeat') { return str(args[0]).repeat(num(args[1])); }
    if (fn === 'substring' || fn === 'substr') { const s = str(args[0]); const start = Math.max(0, num(args[1])); return args.length >= 3 ? s.slice(start, num(args[2])) : s.slice(start); }
    if (fn === 'index_of') { return str(args[0]).indexOf(str(args[1])); }
    if (fn === 'len') { return Array.isArray(args[0]) ? args[0].length : str(args[0]).length; }
    if (fn === 'at' || fn === 'index') { const a = args[0]; const i = num(args[1]); return Array.isArray(a) ? (a[i] !== undefined ? a[i] : '') : str(a)[i] || ''; }
    if (fn === 'pad_right') { return str(args[0]).padEnd(num(args[1])); }
    if (fn === 'pad_left') { return str(args[0]).padStart(num(args[1])); }
    if (fn === 'max_len') { return Array.isArray(args[0]) ? Math.max(0, ...args[0].map(x => str(x).length)) : 0; }
    if (fn === 'chr') { return String.fromCharCode(num(args[0])); }
    if (fn === 'ord') { return str(args[0]).charCodeAt(0) || 0; }
    if (fn === 'sort_list') { return Array.isArray(args[0]) ? [...args[0]].sort((a, b) => str(a) < str(b) ? -1 : str(a) > str(b) ? 1 : 0) : args[0]; }
    if (fn === 'append') { return Array.isArray(args[0]) ? [...args[0], args[1]] : [args[1]]; }
    if (fn === 'head') { return Array.isArray(args[0]) ? args[0].slice(0, num(args[1])) : []; }
    if (fn === 'tail') { return Array.isArray(args[0]) ? args[0].slice(-num(args[1])) : []; }

    // Math
    if (fn === 'range') { const start = args.length >= 2 ? num(args[0]) : 0; const end = args.length >= 2 ? num(args[1]) : num(args[0]); const r = []; for (let i = start; i < end; i++) r.push(i); return r; }
    if (fn === 'abs') { return Math.abs(num(args[0])); }
    if (fn === 'round') { const p = args.length >= 2 ? num(args[1]) : 0; const s = 10 ** p; return Math.round(num(args[0]) * s) / s; }
    if (fn === 'floor') { return Math.floor(num(args[0])); }
    if (fn === 'ceil') { return Math.ceil(num(args[0])); }
    if (fn === 'pow') { return Math.pow(num(args[0]), num(args[1])); }
    if (fn === 'mod') { return num(args[0]) % num(args[1]); }
    if (fn === 'sum') { return Array.isArray(args[0]) ? args[0].reduce((a, b) => a + num(b), 0) : 0; }
    if (fn === 'avg') { return Array.isArray(args[0]) && args[0].length > 0 ? args[0].reduce((a, b) => a + num(b), 0) / args[0].length : 0; }
    if (fn === 'min_num') { return Array.isArray(args[0]) ? Math.min(...args[0].map(num)) : 0; }
    if (fn === 'max_num') { return Array.isArray(args[0]) ? Math.max(...args[0].map(num)) : 0; }

    // Control flow
    if (fn === 'default') { return truthy(args[0]) ? args[0] : args[1]; }
    if (fn === 'if_val') { return truthy(args[0]) ? args[1] : args[2]; }

    // Type
    if (fn === 'type') { if (args[0] === null || args[0] === undefined) return 'nil'; if (typeof args[0] === 'number') return Number.isInteger(args[0]) ? 'int' : 'float'; if (typeof args[0] === 'boolean') return 'bool'; if (Array.isArray(args[0])) return 'list'; if (typeof args[0] === 'object' && args[0]._map) return 'map'; return 'string'; }
    if (fn === 'to_int') { return parseInt(str(args[0])) || 0; }
    if (fn === 'to_string') { return str(args[0]); }
    if (fn === 'to_float') { return parseFloat(str(args[0])) || 0; }

    // Maps
    if (fn === 'map_new') { return { _map: true }; }
    if (fn === 'map_get') { const m = args[0]; const k = str(args[1]); if (m && typeof m === 'object' && k in m) return m[k]; return args.length >= 3 ? args[2] : ''; }
    if (fn === 'map_set') { const m = { ...args[0] }; m[str(args[1])] = args[2]; return m; }
    if (fn === 'map_keys') { return args[0] ? Object.keys(args[0]).filter(k => k !== '_map') : []; }
    if (fn === 'map_values') { return args[0] ? Object.keys(args[0]).filter(k => k !== '_map').map(k => args[0][k]) : []; }
    if (fn === 'map_has') { return args[0] ? str(args[1]) in args[0] : false; }
    if (fn === 'map_delete') { const m = { ...args[0] }; delete m[str(args[1])]; return m; }
    if (fn === 'map_merge') { return { ...args[0], ...args[1] }; }

    // Trace
    if (fn === 'moments') { if (args.length >= 1) { const filter = str(args[0]); return engine.trace.filter(m => m.action === filter).length; } return engine.trace.length; }
    if (fn === 'moment_action') { const m = engine.trace[num(args[0])]; return m ? m.action : ''; }
    if (fn === 'moment_target') { const m = engine.trace[num(args[0])]; return m ? m.target : ''; }
    if (fn === 'moment_actor') { const m = engine.trace[num(args[0])]; return m ? m.actor : ''; }
    if (fn === 'moment_tick') { const m = engine.trace[num(args[0])]; return m ? m.tick : 0; }

    // Testing
    // Structural rendering: evaluate a shape's content and return the output.
    // If content is shape-lang (has statements), evaluate it.
    // If content is raw (HTML/CSS/JS), return it as-is.
    if (fn === 'render') {
      const id = str(args[0]);
      const s = engine.getShape(id);
      if (!s || !s.character.content) return '';
      try {
        const p = parse(s.character.content);
        // If parsing produced no statements, it's raw content.
        if (!p.stmts || p.stmts.length === 0) return s.character.content;
        // If all statements are shape declarations (no executable code), return raw.
        const hasExec = p.stmts.some(st => st.type !== 'shape');
        if (!hasExec) return s.character.content;
        const childEv = createEvaluator(engine);
        for (const k in scope) childEv.setScope(k, scope[k]);
        if (args.length >= 2 && args[1] && typeof args[1] === 'object' && args[1]._map) {
          for (const k in args[1]) { if (k !== '_map') childEv.setScope(k, args[1][k]); }
        }
        childEv.run(p);
        return childEv.getOutput();
      } catch(e) {
        // Parse failed: content is raw (HTML/CSS/JS), return as-is.
        return s.character.content;
      }
    }

    if (fn === 'assert_true') { if (!truthy(args[0])) throw new Error('FAIL: ' + str(args[1])); return ''; }
    if (fn === 'assert_eq') { if (str(args[0]) !== str(args[1])) throw new Error('FAIL: ' + str(args[2]) + ' (got ' + str(args[0]) + ', want ' + str(args[1]) + ')'); return ''; }
    if (fn === 'assert_neq') { if (str(args[0]) === str(args[1])) throw new Error('FAIL: ' + str(args[2])); return ''; }
    if (fn === 'assert_contains') { if (!str(args[0]).includes(str(args[1]))) throw new Error('FAIL: ' + str(args[2])); return ''; }
    if (fn === 'assert_gt') { if (!(num(args[0]) > num(args[1]))) throw new Error('FAIL: ' + str(args[2])); return ''; }

    // Engine
    if (fn === 'validate') { return 'coherent'; }
    if (fn === 'status') { return 'Shapes: ' + engine.shapeCount() + '\nTick: ' + engine.tick; }
    if (fn === 'resolve') { const base = str(args[0]); const path = str(args[1]); if (path === '..') { const i = base.lastIndexOf('.'); return i >= 0 ? base.slice(0, i) : ''; } return base ? base + '.' + path : path; }
    if (fn === 'parent') { const s = str(args[0]); const i = s.lastIndexOf('.'); return i >= 0 ? s.slice(0, i) : ''; }

    // JSON
    if (fn === 'json_encode') { try { return JSON.stringify(args[0]); } catch(e) { return ''; } }
    if (fn === 'json_decode') { try { return JSON.parse(str(args[0])); } catch(e) { return ''; } }

    // Time
    if (fn === 'time_now') { return Math.floor(Date.now() / 1000); }
    if (fn === 'time_ms') { return Date.now(); }

    // Navigate
    if (fn === 'navigate') { return ''; }

    // User-defined fn
    if (fn in fns) {
      const decl = fns[fn];
      const saved = {};
      for (let i = 0; i < decl.params.length; i++) { saved[decl.params[i]] = scope[decl.params[i]]; scope[decl.params[i]] = args[i]; }
      for (const s of decl.body) execStmt(s);
      for (const k of Object.keys(saved)) { if (saved[k] !== undefined) scope[k] = saved[k]; else delete scope[k]; }
      return '';
    }

    return '';
  }

  return { run, setScope, getOutput, scope, evalExpr };
}

// ============================================================
// Layer 5: Boot
// ============================================================

async function bootShapeOS() {
  const engine = new Engine();

  // Load shapes from bundled JSON
  const resp = await fetch('shapes.json');
  const shapesData = await resp.json();

  // Sort by layer, then path
  const files = Object.entries(shapesData)
    .map(([path, data]) => ({ path, content: data.content, layer: data.layer }))
    .sort((a, b) => a.layer !== b.layer ? a.layer - b.layer : a.path.localeCompare(b.path));

  let loaded = 0;
  for (const f of files) {
    try {
      const prog = parse(f.content);
      const ev = createEvaluator(engine);
      ev.run(prog);
    } catch (e) {
      // Skip files with parse errors (e.g. route files with / in values)
    }
    loaded++;
  }

  console.log(`Shape OS: ${engine.shapeCount()} shapes loaded from ${loaded} files`);

  // Bootstrap runtime shapes that the Go server creates dynamically.
  // Workspaces and default windows are not .sl files - they're created at boot.
  const wsCount = parseInt((engine.getShape('os.config.desktop.workspaces')?.character.content) || '3');
  for (let i = 1; i <= wsCount; i++) {
    const ws = new Shape('os.desktop.workspace.' + i);
    ws.character.dimensions = { type: 'workspace', layout: 'hsplit' };
    ws.structure.emergence.layer = 5;
    engine.addShape(ws);
  }

  const defaultApps = ((engine.getShape('os.config.desktop.default.apps')?.character.content) || 'shell').split(',');
  const ws1 = engine.getShape('os.desktop.workspace.1');
  for (let i = 0; i < defaultApps.length; i++) {
    const appName = defaultApps[i].trim();
    const winId = 'os.desktop.window.' + appName;
    const win = new Shape(winId);
    win.character.dimensions = { type: 'window', app: appName, focused: i === 0 ? 'true' : 'false' };
    win.structure.emergence.layer = 5;
    engine.addShape(win);
    if (ws1) ws1.structure.transformation.deps.push(winId);
  }

  return engine;
}

// evalFast: skip evaluator creation for pure let+for/accumulator programs.
// Same static fusion as Go's tryFuseStatic. O(1), zero allocation.
function evalFast(prog, engine) {
  const stmts = prog.stmts;
  if (stmts.length === 2 && stmts[0].t === T_LET && stmts[1].t === T_FOR) {
    const letS = stmts[0], forS = stmts[1];
    if (letS.expr.t === T_INT
        && forS.iter.t === T_CALL
        && forS.body.length === 1 && forS.body[0].t === T_SET
        && forS.body[0].name === letS.name
        && forS.body[0].expr.t === T_BINOP
        && forS.body[0].expr.left.t === T_IDENT
        && forS.body[0].expr.left.name === letS.name) {
      const op = forS.body[0].expr.op;
      let start = 0, end = 0;
      if (forS.iter.args.length === 1 && forS.iter.args[0].t === T_INT) {
        end = forS.iter.args[0].value;
      } else if (forS.iter.args.length >= 2 && forS.iter.args[0].t === T_INT && forS.iter.args[1].t === T_INT) {
        start = forS.iter.args[0].value; end = forS.iter.args[1].value;
      } else return null;
      const count = end - start;
      const init = letS.expr.value;
      const rhs = forS.body[0].expr.right;
      if (rhs.t === T_IDENT && rhs.name === forS.name) {
        const sum = count * (start + end - 1) / 2;
        if (op === '+') return init + sum;
        if (op === '-') return init - sum;
      }
      if (rhs.t === T_INT) {
        if (op === '+') return init + count * rhs.value;
        if (op === '-') return init - count * rhs.value;
      }
    }
  }
  return null;
}

// Export for use by index.html
window.Shape = Shape;
window.Engine = Engine;
window.parse = parse;
window.createEvaluator = createEvaluator;
window.evalFast = evalFast;
window.bootShapeOS = bootShapeOS;
