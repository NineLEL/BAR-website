"use strict";

/* Pure codec, Lua formatting, and command-packing logic shared by the browser
 * app and Node tests. This file is deliberately a classic-script-compatible
 * module so the static app needs no bundler and CommonJS can require it. */
(function (root, createApi) {
  var api = createApi();
  if (typeof module === "object" && module.exports) module.exports = api;
  else root.BARAppPure = api;
})(typeof globalThis !== "undefined" ? globalThis : this, function () {
  var MAX_SLOTS = 10;

  function getLimit(value) {
    var v = parseInt(value, 10);
    if (!v || v < 1000) return 16384;
    return v;
  }

  /* ---------- UTF-8 safe base64 ---------- */
  function b64encode(str, urlSafe) {
    var bytes = new TextEncoder().encode(str);
    var bin = "";
    var CH = 0x8000;
    for (var i = 0; i < bytes.length; i += CH) {
      bin += String.fromCharCode.apply(null, bytes.subarray(i, i + CH));
    }
    var out = btoa(bin);
    if (urlSafe) out = out.replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
    return out;
  }

  function b64decode(b64) {
    var clean = b64.replace(/\s+/g, "");
    // accept URL-safe variant too
    clean = clean.replace(/-/g, "+").replace(/_/g, "/");
    while (clean.length % 4) clean += "=";
    var bin = atob(clean);
    var bytes = new Uint8Array(bin.length);
    for (var i = 0; i < bin.length; i++) bytes[i] = bin.charCodeAt(i);
    return new TextDecoder().decode(bytes);
  }

  /* ---------- Lua minifier ----------
   * Lexes Lua tokens, removes comments/whitespace, and inserts a space only when
   * concatenating adjacent tokens would change how Lua lexes them. Long brackets
   * honor their equals level, so nested-looking text cannot terminate a string or
   * comment early. */
  /* Shared Lua lexer for minification, formatting, and table inspection.
   * Source spans keep diagnostics and delimiter matching out of literal text. */
  function luaTokenize(src, includeComments) {
    src = String(src == null ? "" : src);
    var tokens = [];
    var i = 0, n = src.length, line = 1, column = 1, previousCR = false;
    var operators = ["...", "..", "==", "~=", "<=", ">=", "//", "<<", ">>", "::", "+", "-", "*", "/", "%", "^", "#", "&", "~", "|", "<", ">", "=", "(", ")", "{", "}", "[", "]", ";", ":", ",", "."];

    function fail(message, offset, atLine, atColumn) {
      var error = new SyntaxError(message + " at line " + atLine + ", column " + atColumn);
      error.offset = offset;
      error.line = atLine;
      error.column = atColumn;
      throw error;
    }
    function advanceTo(end) {
      while (i < end) {
        var c = src[i];
        if (c === "\r") { line++; column = 1; previousCR = true; }
        else if (c === "\n") { if (!previousCR) line++; column = 1; previousCR = false; }
        else { column++; previousCR = false; }
        i++;
      }
    }
    function longOpen(at) {
      var m = /^\[(=*)\[/.exec(src.slice(at));
      return m ? { open: m[0], close: "]" + m[1] + "]" } : null;
    }
    function scanLong(at, bracket, startLine, startColumn, isComment) {
      var end = src.indexOf(bracket.close, at + bracket.open.length);
      if (end < 0) fail(isComment ? "Unterminated long-bracket comment" : "Unterminated long-bracket string", at, startLine, startColumn);
      return end + bracket.close.length;
    }
    function scanQuoted(at, startLine, startColumn) {
      var quote = src[at], j = at + 1;
      while (j < n) {
        var c = src[j];
        if (c === "\\") {
          if (j + 1 >= n) break;
          if (src[j + 1] === "\r" && src[j + 2] === "\n") j += 3;
          else j += 2;
          continue;
        }
        if (c === quote) return j + 1;
        if (c === "\n" || c === "\r") fail("Unescaped newline in quoted string", at, startLine, startColumn);
        j++;
      }
      fail("Unterminated quoted string", at, startLine, startColumn);
    }
    function add(text, kind, start, startLine, startColumn, end) {
      tokens.push({ text: text, kind: kind, start: start, end: end, line: startLine, column: startColumn });
    }

    while (i < n) {
      var c = src[i];
      if (/\s/.test(c)) { advanceTo(i + 1); continue; }

      var start = i, startLine = line, startColumn = column;
      if (c === "-" && src[i + 1] === "-") {
        var comment = longOpen(i + 2);
        if (comment) {
          var commentEnd = scanLong(i + 2, comment, startLine, startColumn, true);
          if (includeComments) add(src.slice(i, commentEnd), "comment", start, startLine, startColumn, commentEnd);
          advanceTo(commentEnd);
        } else {
          var lineEnd = i + 2;
          while (lineEnd < n && src[lineEnd] !== "\n" && src[lineEnd] !== "\r") lineEnd++;
          if (includeComments) add(src.slice(i, lineEnd), "comment", start, startLine, startColumn, lineEnd);
          advanceTo(lineEnd);
        }
        continue;
      }

      if (c === "'" || c === '"') {
        var quoteEnd = scanQuoted(i, startLine, startColumn);
        add(src.slice(i, quoteEnd), "string", start, startLine, startColumn, quoteEnd);
        advanceTo(quoteEnd);
        continue;
      }

      var bracket = c === "[" ? longOpen(i) : null;
      if (bracket) {
        var longEnd = scanLong(i, bracket, startLine, startColumn, false);
        add(src.slice(i, longEnd), "string", start, startLine, startColumn, longEnd);
        advanceTo(longEnd);
        continue;
      }

      if (/[A-Za-z_]/.test(c)) {
        var idEnd = i + 1;
        while (idEnd < n && /[A-Za-z0-9_]/.test(src[idEnd])) idEnd++;
        add(src.slice(i, idEnd), "word", start, startLine, startColumn, idEnd);
        advanceTo(idEnd);
        continue;
      }

      if (/[0-9]/.test(c) || (c === "." && /[0-9]/.test(src[i + 1] || ""))) {
        var number = src.slice(i).match(/^(?:0[xX][0-9A-Fa-f]+(?:\.(?!\.)[0-9A-Fa-f]*)?(?:[pP][+-]?[0-9]+)?|[0-9]+(?:\.(?!\.)[0-9]*)?(?:[eE][+-]?[0-9]+)?|\.[0-9]+(?:[eE][+-]?[0-9]+)?)/);
        if (number) {
          var numberEnd = i + number[0].length;
          add(number[0], "number", start, startLine, startColumn, numberEnd);
          advanceTo(numberEnd);
          continue;
        }
      }

      var op = null;
      for (var oi = 0; oi < operators.length; oi++) {
        if (src.slice(i, i + operators[oi].length) === operators[oi]) { op = operators[oi]; break; }
      }
      var symbol = op || c;
      var symbolEnd = i + symbol.length;
      add(symbol, "symbol", start, startLine, startColumn, symbolEnd);
      advanceTo(symbolEnd);
    }
    return tokens;
  }

  /* Token boundaries are preserved; only comments and unnecessary whitespace are removed. */
  function luaMinify(src) {
    var tokens = luaTokenize(src);
    var compound = ["...", "..", "==", "~=", "<=", ">=", "//", "<<", ">>", "::", "--"];

    function needsSpace(a, b) {
      var left = a.text, right = b.text;
      var last = left[left.length - 1], first = right[0];
      if (/[A-Za-z0-9_]/.test(last) && /[A-Za-z0-9_]/.test(first)) return true;
      if ((a.kind === "number" && first === ".") || (a.text === "." && b.kind === "number")) return true;
      for (var ci = 0; ci < compound.length; ci++) {
        var token = compound[ci];
        for (var split = 1; split < token.length; split++) {
          if (left.slice(-split) === token.slice(0, split) && right.slice(0, token.length - split) === token.slice(split)) return true;
        }
      }
      return false;
    }
    function removableSemicolon(index) {
      if (tokens[index].text !== ";") return false;
      var next = tokens[index + 1];
      return !next || /^(?:end|else|elseif|until|\}|\)|\])$/.test(next.text);
    }

    var out = "";
    for (var ti = 0; ti < tokens.length; ti++) {
      if (removableSemicolon(ti)) continue;
      if (ti > 0 && needsSpace(tokens[ti - 1], tokens[ti])) out += " ";
      out += tokens[ti].text;
    }
    return out;
  }

  /* Human-readable Lua formatting built on the exact minifier lexer contract.
   * It intentionally avoids rewriting literals or identifiers. */
  function luaPrettify(src) {
    var tokens = luaTokenize(luaMinify(src));
    var out = "", line = "", indent = 0, parens = 0, pendingSpace = false;
    function flush() { if (line.trim()) out += "  ".repeat(indent) + line.trim() + "\n"; line = ""; pendingSpace = false; }
    function append(s, space) { if (space && line && !/[\s(\[{.]$/.test(line)) line += " "; line += s; }
    tokens.forEach(function (t, index) {
      var x = t.text, prev = tokens[index - 1] && tokens[index - 1].text;
      if (x === ";") { flush(); return; }
      if (x === "end" || x === "else" || x === "elseif" || x === "until") {
        flush();
        indent = Math.max(0, indent - 1);
        append(x, false);
        flush();
        if (x === "else" || x === "elseif") indent++;
        return;
      }
      if (x === "then" || x === "do") { append(x, true); flush(); indent++; return; }
      if (x === "{") { append(x, false); return; }
      if (x === "}") { append(x, false); return; }
      if (x === "(") { append(x, false); parens++; return; }
      if (x === ")") { append(x, false); parens--; return; }
      if (x === ",") { append(x, false); line += " "; return; }
      var operator = /^(?:=|==|~=|<=|>=|\.\.|\.\.\.|[+*/%^#&|<>~-])$/.test(x);
      if (operator) {
        append(x, true);
        line += " ";
      } else {
        append(x, !!(prev && /^[A-Za-z0-9_\])}]$/.test(prev.slice(-1)) && /^[A-Za-z_0-9"'\[]/.test(x)));
      }
    });
    flush();
    return out.replace(/\n+$/, "");
  }

  /* ---------- slot command ---------- */
  function slotKey(kind, idx) { return idx === 0 ? kind : kind + idx; }
  function cmdPrefix(kind, idx) { return "!bset " + slotKey(kind, idx) + " "; }
  function buildCommand(kind, idx, minified, urlSafe) {
    var b64 = b64encode(minified, urlSafe);
    return { b64: b64, cmd: cmdPrefix(kind, idx) + b64 };
  }

  /* Parse the command-or-payload input used by the browser's decode tool. */
  function parseDecodeInput(raw) {
    var input = raw.trim();
    var match = input.match(/!bset\s+(tweak\w+)\s+([\s\S]+)/i);
    return match
      ? { key: match[1], b64: match[2].trim() }
      : { key: "(unknown key)", b64: input.split(/\s+/).pop() };
  }

  /* Merge standalone tweakunits table sources into one table source. */
  function mergeTweakUnits(sources) {
    var inners = [];
    sources.forEach(function (s) {
      var source = String(s == null ? "" : s);
      var tokens = luaTokenize(source, true);
      var significant = tokens.filter(function (token) { return token.kind !== "comment"; });
      if (!significant.length) return;
      if (significant[0].text !== "{") {
        throw new SyntaxError("Expected a standalone tweakunits table starting with '{'");
      }

      var depth = 0, closeIndex = -1;
      for (var i = 0; i < significant.length; i++) {
        if (significant[i].text === "{") depth++;
        else if (significant[i].text === "}") {
          depth--;
          if (depth < 0) throw new SyntaxError("Unexpected '}' in tweakunits table");
          if (depth === 0) { closeIndex = i; break; }
        }
      }
      if (closeIndex < 0) throw new SyntaxError("Unclosed '{' in tweakunits table");
      if (closeIndex !== significant.length - 1) {
        throw new SyntaxError("Unexpected content after the tweakunits table");
      }

      var innerStart = significant[0].end, innerEnd = significant[closeIndex].start;
      var parts = [], cursor = innerStart;
      tokens.forEach(function (token) {
        if (token.kind !== "comment" || token.start < innerStart || token.end > innerEnd) return;
        parts.push(source.slice(cursor, token.start));
        parts.push(token.text.replace(/[^\r\n]/g, " "));
        cursor = token.end;
      });
      parts.push(source.slice(cursor, innerEnd));
      var inner = parts.join("").trim().replace(/,+$/, "");
      if (inner) inners.push(inner);
    });
    return "{ " + inners.filter(Boolean).join(", ") + " }";
  }

  /* Pure core: order-preserving optimal packing with explicit fit diagnostics. */
  function planChunks(kind, minis, limit, urlSafe) {
    var n = minis.length;
    if (!n) return { chunks: [], sizes: [], oversized: [], overflow: [] };
    function pick(list) { return list.map(function (k) { return minis[k]; }); }
    function joined(list) {
      var items = pick(list);
      if (kind === "tweakdefs") return items.join("\n");
      return mergeTweakUnits(items);
    }
    function sizeOf(luaSrc) {
      var b = b64encode(luaSrc, urlSafe);
      // worst-case prefix: numbered slots (1-9) are 1 char longer than bare slot 0
      return cmdPrefix(kind, 1).length + b.length;
    }
    var best = new Array(n + 1);
    best[n] = { count: 0, waste: 0, next: n };
    for (var i = n - 1; i >= 0; i--) {
      var choice = null;
      for (var end = i; end < n; end++) {
        var indexes = [];
        for (var k = i; k <= end; k++) indexes.push(k);
        var size = sizeOf(joined(indexes));
        if (end > i && size > limit) break;
        var tail = best[end + 1];
        var option = { count: tail.count + 1, waste: Math.max(0, limit - size) + tail.waste, next: end + 1 };
        if (choice === null || option.count < choice.count || (option.count === choice.count && option.waste < choice.waste)) choice = option;
      }
      best[i] = choice;
    }
    var chunks = [];
    for (var at = 0; at < n;) {
      var stop = best[at] && best[at].next > at ? best[at].next : at + 1;
      var chunk = [];
      for (var x = at; x < stop; x++) chunk.push(x);
      chunks.push(chunk);
      at = stop;
    }
    var sizes = chunks.map(function (chunk) { return sizeOf(joined(chunk)); });
    var oversized = [];
    var overflow = [];
    chunks.forEach(function (chunk, slot) {
      chunk.forEach(function (index) {
        if (sizes[slot] > limit) oversized.push(index);
        if (slot >= MAX_SLOTS) overflow.push(index);
      });
    });
    return { chunks: chunks, sizes: sizes, oversized: oversized, overflow: overflow };
  }
  /* Backward-compatible chunks-only API. */
  function packChunks(kind, minis, limit, urlSafe) {
    return planChunks(kind, minis, limit, urlSafe).chunks;
  }

  /* Duplicate literal dst fields are warnings, not pack blockers. */
  function findDuplicateDstDetails(minis) {
    var sourcesByDst = Object.create(null);
    minis.forEach(function (minified, sourceIndex) {
      var tokens = luaTokenize(minified), local = Object.create(null);
      for (var i = 0; i + 2 < tokens.length; i++) {
        if (tokens[i].kind !== "word" || tokens[i].text !== "dst" || tokens[i + 1].text !== "=" || tokens[i + 2].kind !== "string") continue;
        var previous = tokens[i - 1];
        if (previous && (previous.text === "." || previous.text === ":")) continue;
        if (previous && previous.text !== "{" && previous.text !== "," && previous.text !== ";") continue;
        var literal = tokens[i + 2].text;
        if (literal.charAt(0) !== '"' && literal.charAt(0) !== "'") continue;
        var fieldEnd = tokens[i + 3];
        if (fieldEnd && fieldEnd.text !== "," && fieldEnd.text !== ";" && fieldEnd.text !== "}") continue;
        local[literal.slice(1, -1)] = true;
      }
      Object.keys(local).forEach(function (dst) {
        if (!sourcesByDst[dst]) sourcesByDst[dst] = [];
        sourcesByDst[dst].push(sourceIndex);
      });
    });

    return Object.keys(sourcesByDst).filter(function (dst) {
      return sourcesByDst[dst].length > 1;
    }).map(function (dst) {
      return { dst: dst, sources: sourcesByDst[dst] };
    });
  }
  function findDuplicateDst(minis) {
    return findDuplicateDstDetails(minis).map(function (detail) { return detail.dst; });
  }

  /* Reset commands: setting a slot's value to 0 clears it lobby-side. */
  function resetCommands(kind) {
    var cmds = [];
    for (var idx = 0; idx < MAX_SLOTS; idx++) cmds.push(cmdPrefix(kind, idx) + "0");
    return cmds;
  }
  function resetAllCommands() {
    // Apply unit table resets before runnable definitions, matching combined copy order.
    return resetCommands("tweakunits").concat(resetCommands("tweakdefs"));
  }

  return {
    MAX_SLOTS: MAX_SLOTS,
    getLimit: getLimit,
    b64encode: b64encode,
    b64decode: b64decode,
    luaMinify: luaMinify,
    luaPrettify: luaPrettify,
    slotKey: slotKey,
    cmdPrefix: cmdPrefix,
    buildCommand: buildCommand,
    parseDecodeInput: parseDecodeInput,
    mergeTweakUnits: mergeTweakUnits,
    planChunks: planChunks,
    packChunks: packChunks,
    findDuplicateDst: findDuplicateDst,
    findDuplicateDstDetails: findDuplicateDstDetails,
    resetCommands: resetCommands,
    resetAllCommands: resetAllCommands
  };
});
