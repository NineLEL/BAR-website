
/* ---------- server library (tweaks/ folder) ---------- */
function libFetch() {
  var st = $("libStatus");
  fetch("api/tweaks").then(function (r) {
    if (!r.ok) throw new Error("HTTP " + r.status);
    return r.json();
  }).then(function (data) {
    renderLib(data);
  }).catch(function () {
    st.innerHTML = "<p><strong>Server library offline.</strong> Run <code>node server.js</code> and open <code>http://localhost:8080</code> to use <code>.lua</code> files from <code>tweaks/defs</code> and <code>tweaks/units</code>. Manual snippets keep working.</p>";
    $("libDefs").innerHTML = "";
    $("libUnits").innerHTML = "";
  });
}

function renderLib(data) {
  var nD = data.defs.length, nU = data.units.length;
  var eD = data.defs.filter(function (f) { return f.enabled; }).length;
  var eU = data.units.filter(function (f) { return f.enabled; }).length;
  $("libStatus").innerHTML = "<p>Serving <strong>" + nD + " defs</strong> (" + eD + " enabled) + <strong>" + nU + " units</strong> (" + eU + " enabled) from <code>tweaks/</code>. Drop <code>.lua</code> files in the folder, hit Reload. Untick to disable without deleting — enabled files flow into the packer automatically.</p>";
  window._lib = data;
  renderLibGroup($("libDefs"), "defs", data.defs);
  renderLibGroup($("libUnits"), "units", data.units);
  syncLibToPacker();
}

function renderLibGroup(el, kind, files) {
  el.innerHTML = "";
  if (!files.length) {
    var none = document.createElement("div");
    none.className = "slot empty";
    none.textContent = "(no .lua files yet)";
    el.appendChild(none);
    return;
  }
  files.forEach(function (f) {
    var div = document.createElement("div");
    div.className = "slot" + (f.enabled ? "" : " empty");
    var head = document.createElement("header");
    var left = document.createElement("span");
    var cb = document.createElement("input");
    cb.type = "checkbox";
    cb.checked = !!f.enabled;
    cb.title = "enable/disable (stored server-side, file is kept)";
    cb.onchange = function () {
      fetch("api/tweaks/toggle", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ kind: kind, name: f.name, enabled: cb.checked })
      }).then(function (r) {
        if (!r.ok) throw new Error("HTTP " + r.status);
        libFetch();
      }, function () { toast("Toggle failed — is the server running?"); });
    };
    var nm = document.createElement("span");
    nm.className = "name";
    nm.textContent = " " + f.name;
    left.appendChild(cb);
    left.appendChild(nm);
    var st = document.createElement("span");
    st.className = "stats";
    st.textContent = f.chars + " chars";
    head.appendChild(left);
    head.appendChild(st);
    div.appendChild(head);
    var row = document.createElement("div");
    row.className = "row";
    var pv = document.createElement("button");
    pv.textContent = "Preview";
    var pre = document.createElement("pre");
    pre.className = "mono output";
    pre.style.display = "none";
    pre.textContent = f.content;
    pv.onclick = function () { pre.style.display = pre.style.display === "none" ? "block" : "none"; };
    row.appendChild(pv);
    div.appendChild(row);
    div.appendChild(pre);
    el.appendChild(div);
  });
}

function syncLibToPacker() {
  var data = window._lib;
  if (!data) return;
  defs.serverSnippets = data.defs.filter(function (f) { return f.enabled; })
    .map(function (f) { return { name: "tweaks/defs/" + f.name, text: f.content }; });
  units.serverSnippets = data.units.filter(function (f) { return f.enabled; })
    .map(function (f) { return { name: "tweaks/units/" + f.name, text: f.content }; });
  defs.packed = null; defs.packedNames = null;
  units.packed = null; units.packedNames = null;
  renderAll();
}

$("libReload").onclick = libFetch;
$("defsLibReload").onclick = libFetch;
$("unitsLibReload").onclick = libFetch;

function setAllLib(enabled) {
  var data = window._lib;
  if (!data) { toast("Library not loaded yet."); return; }
  var files = [];
  data.defs.forEach(function (f) { files.push({ kind: "defs", name: f.name }); });
  data.units.forEach(function (f) { files.push({ kind: "units", name: f.name }); });
  if (!files.length) { toast("No library files."); return; }
  Promise.all(files.map(function (f) {
    return fetch("api/tweaks/toggle", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ kind: f.kind, name: f.name, enabled: enabled })
    });
  })).then(function () { libFetch(); }, function () { toast("Bulk toggle failed \u2014 is the server running?"); libFetch(); });
}
$("libEnableAll").onclick = function () { setAllLib(true); };
$("libDisableAll").onclick = function () { setAllLib(false); };
libFetch();
"use strict";
/* BAR Tweak Packer — 100% client-side.
 * tweakdefs: arbitrary Lua run via loadstring after base64-decode.
 * tweakunits: Lua table deep-merged into UnitDefs.
 * Slots 0..9 each. Per-message cap 16384 chars incl. "!bset tweakdefsN ". */

var MAX_SLOTS = 10;

function $(id) { return document.getElementById(id); }

function getLimit() {
  var v = parseInt($("charLimit").value, 10);
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
function useUrlSafe() {
  var cb = (typeof document !== "undefined") ? document.getElementById("b64url") : null;
  return !!(cb && cb.checked);
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

  var out = "";
  for (var ti = 0; ti < tokens.length; ti++) {
    if (ti > 0 && needsSpace(tokens[ti - 1], tokens[ti])) out += " ";
    out += tokens[ti].text;
  }
  return out;
}

/* ---------- slot command ---------- */
function slotKey(kind, idx) { return idx === 0 ? kind : kind + idx; }
function cmdPrefix(kind, idx) { return "!bset " + slotKey(kind, idx) + " "; }
function buildCommand(kind, idx, minified, urlSafe) {
  var b64 = b64encode(minified, urlSafe);
  return { b64: b64, cmd: cmdPrefix(kind, idx) + b64 };
}

/* ---------- state ---------- */
function makeGroup(kind, inputsEl, slotsEl) {
  return {
    kind: kind,
    snippets: [""],
    inputsEl: inputsEl,
    slotsEl: slotsEl,
    serverSnippets: [],
    // packed lua per slot after Auto-pack; null = 1:1 mapping snippet[i] -> slot[i]
    packed: null
  };
}
var defs = makeGroup("tweakdefs", $("defsInputs"), $("defsSlots"));
var units = makeGroup("tweakunits", $("unitsInputs"), $("unitsSlots"));

function exampleText(kind) {
  if (kind === "tweakdefs") {
    return "-- example: double metal cost of all T2 units\nfor name,ud in pairs(UnitDefs) do\n  local tech = ud.customparams and ud.customparams.techlevel or 1\n  if tech >= 2 then ud.metalcost = (ud.metalcost or 0) * 2 end\nend";
  }
  return "-- example tweakunits table\n{\n  armpw = { metalcost = 10, energycost = 10, },\n  corak = { metalcost = 10, energycost = 10, },\n}";
}

/* Merge several tweakunits table sources into one table source.
 * Strips outer braces of each and comma-joins the innards. */
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

function renderInputs(g) {
  g.inputsEl.innerHTML = "";
  (g.serverSnippets || []).forEach(function (f) {
    var lock = document.createElement("div");
    lock.className = "snippet locked";
    var lh = document.createElement("header");
    var ll = document.createElement("span");
    ll.textContent = f.name + " (server, " + f.text.length + " chars)";
    lh.appendChild(ll);
    var lt = document.createElement("textarea");
    lt.value = f.text;
    lt.readOnly = true;
    lt.title = "Managed server-side in " + f.name;
    lock.appendChild(lh); lock.appendChild(lt);
    g.inputsEl.appendChild(lock);
  });
  g.snippets.forEach(function (text, i) {
    var box = document.createElement("div");
    box.className = "snippet";
    var head = document.createElement("header");
    var lab = document.createElement("span");
    lab.textContent = "Snippet " + (i + 1);
    var del = document.createElement("button");
    del.textContent = "Remove";
    del.onclick = function () {
      g.snippets.splice(i, 1);
      if (!g.snippets.length) g.snippets.push("");
      g.packed = null; g.packedNames = null;
      renderAll();
    };
    head.appendChild(lab); head.appendChild(del);
    var ta = document.createElement("textarea");
    ta.value = text;
    ta.placeholder = exampleText(g.kind);
    ta.oninput = function () { g.snippets[i] = ta.value; g.packed = null; g.packedNames = null; renderSlots(g); };
    box.appendChild(head); box.appendChild(ta);
    g.inputsEl.appendChild(box);
  });
}

/* Resolve the lua source per slot: packed (after auto-pack) or 1:1 snippets. */
function slotSources(g) {
  if (g.packed) return g.packed.slice();
  var fromServer = (g.serverSnippets || []).map(function (f) { return f.text; })
    .filter(function (s) { return s.trim() !== ""; });
  var manual = g.snippets.filter(function (s) { return s.trim() !== ""; });
  return fromServer.concat(manual).slice(0, MAX_SLOTS);
}

function renderSlots(g) {
  var limit = getLimit();
  var srcs = slotSources(g);
  g.slotsEl.innerHTML = "";
  for (var idx = 0; idx < MAX_SLOTS; idx++) {
    var raw = srcs[idx] || "";
    var div = document.createElement("div");
    var has = raw.trim() !== "";
    div.className = "slot" + (has ? "" : " empty");
    var head = document.createElement("header");
    var nm = document.createElement("span");
    nm.className = "name";
    nm.textContent = "!bset " + slotKey(g.kind, idx);
    if (g.packed && g.packedNames && g.packedNames[idx]) {
      nm.textContent += " \u2190 " + g.packedNames[idx].join(" + ");
      nm.title = g.packedNames[idx].join("\n");
    }
    var st = document.createElement("span");
    st.className = "stats";
    head.appendChild(nm); head.appendChild(st);
    div.appendChild(head);

    if (!has) {
      st.textContent = "(empty)";
      var clr = document.createElement("div");
      clr.className = "cmd";
      clr.textContent = "—";
      div.appendChild(clr);
    } else {
      var min, b64, cmd, err = null;
      try {
        var toMin = (g.kind === "tweakunits" && g.packed) ? raw : raw;
        min = luaMinify(toMin);
        var r = buildCommand(g.kind, idx, min, useUrlSafe());
        b64 = r.b64; cmd = r.cmd;
      } catch (e) { err = String(e); }
      if (err) {
        st.textContent = "encode error: " + err;
        div.classList.add("over");
      } else {
        var total = cmd.length;
        var over = total > limit;
        if (over) div.classList.add("over");
        st.innerHTML = "";
        var parts = [
          "raw " + raw.length,
          "min " + min.length,
          "b64 " + b64.length,
          "cmd " + total + "/" + limit
        ];
        st.textContent = parts.join(" · ") + (over ? " — OVER LIMIT" : " — OK");
        st.className = "stats " + (over ? "bad" : "good");
        var pre = document.createElement("div");
        pre.className = "cmd";
        pre.textContent = cmd;
        div.appendChild(pre);
        var row = document.createElement("div");
        row.className = "row";
        var cp = document.createElement("button");
        cp.textContent = "Copy";
        (function (c) {
          cp.onclick = function () { copyText(c); };
        })(cmd);
        var pv = document.createElement("button");
        pv.textContent = "Show minified";
        (function (m, box) {
          pv.onclick = function () {
            box.style.display = box.style.display === "none" ? "block" : "none";
          };
        })(min, null);
        var prev2 = document.createElement("pre");
        prev2.className = "mono output";
        prev2.style.display = "none";
        prev2.textContent = min;
        pv.onclick = function () {
          prev2.style.display = prev2.style.display === "none" ? "block" : "none";
        };
        row.appendChild(cp); row.appendChild(pv);
        div.appendChild(row);
        div.appendChild(prev2);
      }
    }
    g.slotsEl.appendChild(div);
  }
}

function renderAll() { renderInputs(defs); renderInputs(units); renderSlots(defs); renderSlots(units); }

/* ---------- auto-pack: order-preserving optimal packing ---------- */
/* Pure core (no DOM — unit-tested via loadPure): greedy first-fit over minified
 * sources. Returns chunks of indices into `minis`. tweakdefs chunks join with
 * "\n" (files must be self-contained: locals inside do/end or loop scope, only
 * UnitDefs mutated — concatenation then preserves behaviour and order).
 * tweakunits chunks merge into one table via mergeTweakUnits. A single item
 * that alone exceeds the limit is kept solo (caller warns). */
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
  function fits(list) { return sizeOf(joined(list)) <= limit; }
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
/* Pure helper: find UnitDefs `dst` keys claimed by 2+ sources. tweakdefs only —
 * same dst in two files means last-writer-wins, so the packer warns (packs anyway). */
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
function joinChunk(g, minis, idxs) {
  var items = idxs.map(function (k) { return minis[k]; });
  if (g.kind === "tweakdefs") return items.join("\n");
  return mergeTweakUnits(items);
}
function autoPack(g) {
  var limit = getLimit();
  // Pack everything flowing into the slots: enabled tweaks/ library files first, then manual snippets.
  var items = (g.serverSnippets || []).map(function (f) { return { name: f.name, text: f.text }; });
  g.snippets.forEach(function (s, i) { items.push({ name: "Snippet " + (i + 1), text: s }); });
  items = items.filter(function (it) { return it.text.trim() !== ""; });
  if (!items.length) { toast("Nothing to pack"); return; }
  if (items.length > 60) { toast("Too many snippets"); return; }

  var minis = items.map(function (it) { return luaMinify(it.text); });
  var idxChunks = packChunks(g.kind, minis, limit, useUrlSafe());

  var msg = "Packed " + items.length + " item(s) into " + idxChunks.length + " slot(s)";
  if (idxChunks.length > MAX_SLOTS) {
    var omitted = [];
    for (var oi = MAX_SLOTS; oi < idxChunks.length; oi++) idxChunks[oi].forEach(function (k) { omitted.push(items[k].name); });
    msg += " — exceeds 10-slot limit; omitted: " + omitted.join(", ");
  }
  if (g.kind === "tweakdefs") {
    var dups = findDuplicateDst(minis);
    if (dups.length) msg += " — WARNING duplicate dst (last wins): " + dups.join(", ");
  }
  toast(msg);
  g.packed = idxChunks.slice(0, MAX_SLOTS).map(function (idxs) { return joinChunk(g, minis, idxs); });
  g.packedNames = idxChunks.slice(0, MAX_SLOTS).map(function (idxs) {
    return idxs.map(function (k) { return items[k].name; });
  });
  renderSlots(g);
}

/* Reset commands: setting a slot's value to 0 clears it lobby-side. */
function resetCommands(kind) {
  var cmds = [];
  for (var idx = 0; idx < MAX_SLOTS; idx++) cmds.push(cmdPrefix(kind, idx) + "0");
  return cmds;
}
function collectCommands(g) {
  var srcs = slotSources(g);
  var cmds = [];
  for (var idx = 0; idx < srcs.length && idx < MAX_SLOTS; idx++) {
    if (!srcs[idx].trim()) continue;
    cmds.push(buildCommand(g.kind, idx, luaMinify(srcs[idx]), useUrlSafe()).cmd);
  }
  return cmds;
}

function copyText(t) {
  function done() { toast("Copied (" + t.length + " chars)"); }
  if (navigator.clipboard && navigator.clipboard.writeText) {
    navigator.clipboard.writeText(t).then(done, function () { fallback(); });
  } else fallback();
  function fallback() {
    var ta = document.createElement("textarea");
    ta.value = t; document.body.appendChild(ta); ta.select();
    try { document.execCommand("copy"); done(); } catch (e) { toast("Copy failed — select manually"); }
    document.body.removeChild(ta);
  }
}

var toastTimer = null;
function toast(msg) {
  var el = $("toast");
  if (!el) {
    el = document.createElement("div");
    el.id = "toast"; el.className = "toast";
    document.body.appendChild(el);
  }
  el.textContent = msg; el.style.display = "block";
  clearTimeout(toastTimer);
  toastTimer = setTimeout(function () { el.style.display = "none"; }, 2200);
}

/* ---------- wiring ---------- */
document.querySelectorAll(".tab").forEach(function (btn) {
  btn.onclick = function () {
    document.querySelectorAll(".tab").forEach(function (b) { b.classList.remove("active"); });
    document.querySelectorAll(".panel").forEach(function (p) { p.classList.remove("active"); });
    btn.classList.add("active");
    $("panel-" + btn.dataset.tab).classList.add("active");
  };
});

$("defsAdd").onclick = function () { defs.snippets.push(""); defs.packed = null; defs.packedNames = null; renderInputs(defs); };
$("unitsAdd").onclick = function () { units.snippets.push(""); units.packed = null; units.packedNames = null; renderInputs(units); };
$("defsPack").onclick = function () { autoPack(defs); };
$("unitsPack").onclick = function () { autoPack(units); };
$("defsClear").onclick = function () { defs.snippets = [""]; defs.packed = null; defs.packedNames = null; renderAll(); };
$("unitsClear").onclick = function () { units.snippets = [""]; units.packed = null; units.packedNames = null; renderAll(); };
$("defsCopyAll").onclick = function () {
  var c = collectCommands(defs);
  if (!c.length) return toast("No tweakdefs to copy");
  copyText(c.join("\n"));
};
$("defsReset").onclick = function () { copyText(resetCommands("tweakdefs").join("\n")); };
$("unitsCopyAll").onclick = function () {
  var c = collectCommands(units);
  if (!c.length) return toast("No tweakunits to copy");
  copyText(c.join("\n"));
};
$("unitsReset").onclick = function () { copyText(resetCommands("tweakunits").join("\n")); };
$("charLimit").oninput = function () { renderSlots(defs); renderSlots(units); };
$("b64url").onchange = function () { renderAll(); };

$("decodeBtn").onclick = function () {
  var raw = $("decodeInput").value.trim();
  var m = raw.match(/!bset\s+(tweak\w+)\s+([\s\S]+)/i);
  var b64 = m ? m[2].trim() : raw.split(/\s+/).pop();
  var key = m ? m[1] : "(unknown key)";
  try {
    var lua = b64decode(b64);
    $("decodeOutput").textContent = "-- " + key + " — " + b64.length + " b64 chars → " + lua.length + " lua chars\n\n" + lua;
  } catch (e) {
    $("decodeOutput").textContent = "Could not base64-decode that input: " + e;
  }
};

renderAll();
