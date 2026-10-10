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
  function luaMinify(src) {
    var tokens = [];
    var i = 0, n = src.length;
    var operators = ["...", "..", "==", "~=", "<=", ">=", "//", "<<", ">>", "::", "+", "-", "*", "/", "%", "^", "#", "&", "~", "|", "<", ">", "=", "(", ")", "{", "}", "[", "]", ";", ":", ",", "."];
    var compound = ["...", "..", "==", "~=", "<=", ">=", "//", "<<", ">>", "::", "--"];

    function longOpen(at) {
      var m = src.slice(at).match(/^\[(=*)\[/);
      return m ? { open: m[0], close: "]" + m[1] + "]" } : null;
    }
    function push(text, kind) { tokens.push({ text: text, kind: kind }); }
    function scanQuoted(at) {
      var q = src[at], j = at + 1;
      while (j < n) {
        if (src[j] === "\\") { j += 2; continue; }
        if (src[j] === q) return Math.min(j + 1, n);
        j++;
      }
      return n;
    }
    function scanLong(at, bracket) {
      var end = src.indexOf(bracket.close, at + bracket.open.length);
      return end < 0 ? n : end + bracket.close.length;
    }

    while (i < n) {
      var c = src[i];
      if (/\s/.test(c)) { i++; continue; }

      if (c === "-" && src[i + 1] === "-") {
        var comment = longOpen(i + 2);
        if (comment) i = scanLong(i + 2, comment);
        else {
          var newline = src.indexOf("\n", i + 2);
          i = newline < 0 ? n : newline + 1;
        }
        continue;
      }

      if (c === "'" || c === '"') {
        var qEnd = scanQuoted(i);
        push(src.slice(i, qEnd), "string");
        i = qEnd;
        continue;
      }

      var bracket = c === "[" ? longOpen(i) : null;
      if (bracket) {
        var longEnd = scanLong(i, bracket);
        push(src.slice(i, longEnd), "string");
        i = longEnd;
        continue;
      }

      if (/[A-Za-z_]/.test(c)) {
        var idEnd = i + 1;
        while (idEnd < n && /[A-Za-z0-9_]/.test(src[idEnd])) idEnd++;
        push(src.slice(i, idEnd), "word");
        i = idEnd;
        continue;
      }

      if (/[0-9]/.test(c) || (c === "." && /[0-9]/.test(src[i + 1] || ""))) {
        var num = src.slice(i).match(/^(?:0[xX][0-9A-Fa-f]+(?:\.(?!\.)[0-9A-Fa-f]*)?(?:[pP][+-]?[0-9]+)?|[0-9]+(?:\.(?!\.)[0-9]*)?(?:[eE][+-]?[0-9]+)?|\.[0-9]+(?:[eE][+-]?[0-9]+)?)/);
        if (num) { push(num[0], "number"); i += num[0].length; continue; }
      }

      var op = null;
      for (var oi = 0; oi < operators.length; oi++) {
        if (src.slice(i, i + operators[oi].length) === operators[oi]) { op = operators[oi]; break; }
      }
      if (op) { push(op, "symbol"); i += op.length; }
      else { push(c, "symbol"); i++; }
    }

    function needsSpace(a, b) {
      var left = a.text, right = b.text;
      var last = left[left.length - 1], first = right[0];
      if (/[A-Za-z0-9_]/.test(last) && /[A-Za-z0-9_]/.test(first)) return true;
      // Keep numeral/decimal-point boundaries intact (e.g. `1 .. 2`, `. .5`).
      if ((a.kind === "number" && first === ".") || (a.text === "." && b.kind === "number")) return true;
      for (var ci = 0; ci < compound.length; ci++) {
        var token = compound[ci];
        for (var split = 1; split < token.length; split++) {
          if (left.slice(-split) === token.slice(0, split) && right.slice(0, token.length - split) === token.slice(split)) return true;
        }
      }
      return false;
    }

    // Lua permits a final statement separator before block terminators and at
    // EOF. Remove only those semicolons; separators between statements remain.
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
    var compact = luaMinify(src), tokens = [], i = 0, n = compact.length;
    var multi = ["...", "..", "==", "~=", "<=", ">=", "//", "<<", ">>", "::"];
    function add(text, kind) { tokens.push({ text: text, kind: kind }); }
    function quoted(at) {
      var q = compact[at], j = at + 1;
      while (j < n) { if (compact[j] === "\\") { j += 2; continue; } if (compact[j] === q) return j + 1; j++; }
      return n;
    }
    function longAt(at) {
      var m = compact.slice(at).match(/^\[(=*)\[/);
      if (!m) return null;
      var close = "]" + m[1] + "]", end = compact.indexOf(close, at + m[0].length);
      return { end: end < 0 ? n : end + close.length };
    }
    while (i < n) {
      var c = compact[i], lb = c === "[" ? longAt(i) : null;
      if (c === "'" || c === '"') { var qe = quoted(i); add(compact.slice(i, qe), "literal"); i = qe; continue; }
      if (lb) { add(compact.slice(i, lb.end), "literal"); i = lb.end; continue; }
      if (/[A-Za-z_]/.test(c)) { var e = i + 1; while (e < n && /[A-Za-z0-9_]/.test(compact[e])) e++; add(compact.slice(i, e), "word"); i = e; continue; }
      if (/[0-9]/.test(c) || (c === "." && /[0-9]/.test(compact[i + 1] || ""))) { var nm = compact.slice(i).match(/^(?:0[xX][0-9A-Fa-f]+(?:\.(?!\.)[0-9A-Fa-f]*)?(?:[pP][+-]?[0-9]+)?|[0-9]+(?:\.(?!\.)[0-9]*)?(?:[eE][+-]?[0-9]+)?|\.[0-9]+(?:[eE][+-]?[0-9]+)?)/); if (nm) { add(nm[0], "number"); i += nm[0].length; continue; } }
      var op = null;
      for (var k = 0; k < multi.length; k++) if (compact.slice(i, i + multi[k].length) === multi[k]) { op = multi[k]; break; }
      add(op || c, "symbol"); i += (op || c).length;
    }
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

  /* Merge several tweakunits table sources into one table source. */
  function mergeTweakUnits(sources) {
    var inners = [];
    sources.forEach(function (s) {
      var t = s.trim().replace(/--\[\[[\s\S]*?\]\]/g, "");
      // drop full-line -- comments
      t = t.split("\n").filter(function (ln) { return ln.trim().slice(0, 2) !== "--"; }).join("\n");
      var a = t.indexOf("{"), b = t.lastIndexOf("}");
      if (a >= 0 && b > a) inners.push(t.slice(a + 1, b).trim().replace(/,+$/, ""));
      else if (t) inners.push(t);
    });
    return "{ " + inners.filter(Boolean).join(", ") + " }";
  }

  /* Pure core: order-preserving optimal packing. */
  function packChunks(kind, minis, limit, urlSafe) {
    var n = minis.length;
    if (!n) return [];
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
    return chunks;
  }

  /* Duplicate UnitDefs destinations are warnings, not pack blockers. */
  function findDuplicateDst(minis) {
    var seen = {};
    var dups = [];
    minis.forEach(function (m) {
      var re = /dst\s*=\s*"([^"]+)"/g;
      var mt, local = {};
      while ((mt = re.exec(m))) local[mt[1]] = 1;
      Object.keys(local).forEach(function (k) {
        if (seen[k]) { if (dups.indexOf(k) < 0) dups.push(k); }
        else seen[k] = 1;
      });
    });
    return dups;
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
    packChunks: packChunks,
    findDuplicateDst: findDuplicateDst,
    resetCommands: resetCommands,
    resetAllCommands: resetAllCommands
  };
});
