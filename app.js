"use strict";
/* BAR Tweak Packer — 100% client-side.
 * tweakdefs: arbitrary Lua run via loadstring after base64-decode.
 * tweakunits: Lua table deep-merged into UnitDefs.
 * Slots 0..9 each. Per-message cap 16384 chars incl. command. */

var Pure = BARAppPure;
var LibraryApi = BARLibraryApi;
var MAX_SLOTS = Pure.MAX_SLOTS;
var b64encode = Pure.b64encode;
var b64decode = Pure.b64decode;
var luaMinify = Pure.luaMinify;
var luaPrettify = Pure.luaPrettify;
var slotKey = Pure.slotKey;
var cmdPrefix = Pure.cmdPrefix;
var buildCommand = Pure.buildCommand;
var mergeTweakUnits = Pure.mergeTweakUnits;
var planChunks = Pure.planChunks;
var findDuplicateDst = Pure.findDuplicateDst;
var resetAllCommands = Pure.resetAllCommands;

function $(id) { return document.getElementById(id); }

/* ---------- server library presentation ---------- */
function libFetch() {
  var st = $("libStatus");
  st.textContent = "Loading server library…";
  LibraryApi.fetchLibrary().then(function (data) {
    renderLib(data);
  }).catch(function () {
    st.textContent = "Server library offline. Run node server.js and open http://localhost:8080 to use .lua files from tweaks/defs and tweaks/units. Manual snippets keep working.";
    $("libDefs").textContent = "";
    $("libUnits").textContent = "";
  });
}

function renderLib(data) {
  var nD = data.defs.length, nU = data.units.length;
  var eD = data.defs.filter(function (f) { return f.enabled; }).length;
  var eU = data.units.filter(function (f) { return f.enabled; }).length;
  $("libStatus").textContent = "Serving " + nD + " defs (" + eD + " enabled) + " + nU + " units (" + eU + " enabled) from tweaks/. Changes reload automatically while server.js is running. Enabled files flow into the packer automatically.";
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
  var query = ($("libSearch") ? $("libSearch").value : "").toLowerCase();
  var filtered = files.filter(function (f) { return f.name.toLowerCase().indexOf(query) !== -1; });
  if (!filtered.length) {
    var none = document.createElement("div"); none.className = "slot empty";
    none.textContent = files.length ? "No filenames match your search." : "No .lua files yet.";
    el.appendChild(none); return;
  }
  var groups = {};
  filtered.forEach(function (f) {
    var parts = f.name.split("/"); var folder = parts.length > 1 ? parts.slice(0, -1).join("/") : "";
    if (!groups[folder]) groups[folder] = [];
    groups[folder].push(f);
  });
  var names = Object.keys(groups).sort(function (a, b) { if (!a) return -1; if (!b) return 1; return a.toLowerCase().localeCompare(b.toLowerCase()); });
  names.forEach(function (folder, groupIndex) {
    var groupFiles = groups[folder].sort(function (a, b) { return a.name.toLowerCase().localeCompare(b.name.toLowerCase()); });
    var enabled = groupFiles.filter(function (f) { return f.enabled; }).length;
    var details = document.createElement("details"); details.className = "library-group"; details.open = true;
    var summary = document.createElement("summary"); summary.textContent = (folder || "Root") + " — " + enabled + "/" + groupFiles.length + " enabled";
    var actions = document.createElement("span"); actions.className = "library-group-actions";
    [true, false].forEach(function (enable) {
      var action = document.createElement("button"); action.type = "button"; action.textContent = enable ? "Enable group" : "Disable group";
      action.onclick = function (event) { event.preventDefault(); event.stopPropagation(); LibraryApi.toggleAll(groupFiles.map(function (f) { return { kind: kind, name: f.name }; }), enable).then(libFetch, function () { toast("Group toggle failed — is the server running?"); libFetch(); }); };
      actions.appendChild(action);
    });
    summary.appendChild(actions); details.appendChild(summary);
    groupFiles.forEach(function (f) {
    var div = document.createElement("div");
    div.className = "slot" + (f.enabled ? "" : " empty");
    var head = document.createElement("header");
    var left = document.createElement("span");
    var cb = document.createElement("input");
    cb.type = "checkbox";
    cb.checked = !!f.enabled;
    cb.title = "Enable or disable " + f.name + " (file is kept)";
    cb.setAttribute("aria-label", "Enable " + f.name);
    cb.onchange = function () {
      LibraryApi.toggle(kind, f.name, cb.checked).then(function (r) {
        if (!r.ok) throw new Error("HTTP " + r.status);
        libFetch();
      }, function () { toast("Toggle failed — is the server running?"); });
    };
    head.onclick = function (event) {
      if (event.target === cb || event.target.tagName === "BUTTON" || event.target.tagName === "INPUT") return;
      cb.checked = !cb.checked;
      if (typeof Event === "function") cb.dispatchEvent(new Event("change", { bubbles: true }));
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
     pv.setAttribute("aria-expanded", "false");
     var pre = document.createElement("pre");
     pre.className = "mono output";
      pre.id = "lib-preview-" + kind + "-" + files.indexOf(f);
      pv.setAttribute("aria-controls", pre.id);
     pre.style.display = "none";
     // Keep large library scripts out of the DOM until the user asks to see
     // them. This avoids creating hundreds of thousands of text nodes on load.
     pv.onclick = function () {
       var opening = pre.style.display === "none";
       if (opening) {
          pre.textContent = f.content;
          pre.hidden = false;
         pre.style.display = "block";
        pv.textContent = "Hide script";
        pv.setAttribute("aria-expanded", "true");
       } else {
          pre.textContent = "";
          pre.hidden = true;
         pre.style.display = "none";
        pv.textContent = "Preview";
        pv.setAttribute("aria-expanded", "false");
       }
     };
     row.appendChild(pv);
     var cp = document.createElement("button"); cp.type = "button"; cp.textContent = "Copy raw Lua"; cp.onclick = function () { copyText(f.content); }; row.appendChild(cp);
    div.appendChild(row);
    div.appendChild(pre);
    details.appendChild(div);
    });
    var bulk = document.createElement("div"); bulk.className = "library-group-bulk";
    [true, false].forEach(function (enable) {
      var button = document.createElement("button"); button.type = "button"; button.textContent = (enable ? "Enable all " : "Disable all ") + kind;
      button.onclick = function () { setAllLib(enable, kind); };
      bulk.appendChild(button);
    });
    details.appendChild(bulk);
    el.appendChild(details);
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
  defs.packNotice = null;
  units.packNotice = null;
  renderAll();
}

function setAllLib(enabled, onlyKind) {
  var data = window._lib;
  if (!data) { toast("Library not loaded yet."); return; }
  var files = [];
  if (!onlyKind || onlyKind === "defs") data.defs.forEach(function (f) { files.push({ kind: "defs", name: f.name }); });
  if (!onlyKind || onlyKind === "units") data.units.forEach(function (f) { files.push({ kind: "units", name: f.name }); });
  if (!files.length) { toast("No library files."); return; }
  LibraryApi.toggleAll(files, enabled).then(function () { libFetch(); }, function () { toast("Bulk toggle failed \u2014 is the server running?"); libFetch(); });
}
$("libReload").onclick = libFetch;
$("defsLibReload").onclick = libFetch;
$("unitsLibReload").onclick = libFetch;
$("libEnableAll").onclick = function () { setAllLib(true); };
$("libDisableAll").onclick = function () { setAllLib(false); };
$("libDefs").setAttribute("data-kind", "defs"); $("libUnits").setAttribute("data-kind", "units");
$("libSearch").oninput = function () { if (window._lib) { renderLibGroup($("libDefs"), "defs", window._lib.defs); renderLibGroup($("libUnits"), "units", window._lib.units); } };
$("libSearchClear").onclick = function () { $("libSearch").value = ""; $("libSearch").focus(); $("libSearch").oninput(); };
$("libDefs").setAttribute("data-kind", "defs"); $("libUnits").setAttribute("data-kind", "units");
libFetch();
var libVersion = null;
function watchLibrary() {
  LibraryApi.fetchVersion().then(function (data) {
    if (libVersion !== null && data.version !== libVersion) libFetch();
    libVersion = data.version;
  }).catch(function () {}).finally(function () { setTimeout(watchLibrary, 2000); });
}
watchLibrary();

function useUrlSafe() {
  var cb = (typeof document !== "undefined") ? document.getElementById("b64url") : null;
  return !!(cb && cb.checked);
}
function getLimit() { return Pure.getLimit($("charLimit").value); }

/* ---------- state ---------- */
function makeGroup(kind, inputsEl, slotsEl) {
  return {
    kind: kind,
    snippets: [""],
    inputsEl: inputsEl,
    slotsEl: slotsEl,
    serverSnippets: [],
    // packed lua per slot after Auto-pack; null = 1:1 mapping snippet[i] -> slot[i]
    packed: null,
    packNotice: null
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

function renderInputs(g) {
  g.inputsEl.innerHTML = "";
  (g.serverSnippets || []).forEach(function (f) {
    var lock = document.createElement("div");
    lock.className = "snippet locked";
    var lh = document.createElement("header");
    var ll = document.createElement("span");
    ll.textContent = f.name + " (server, " + f.text.length + " chars)";
    ll.id = "server-script-label-" + g.kind + "-" + g.inputsEl.children.length;
    lh.appendChild(ll);
     var lt = document.createElement("textarea");
    lt.value = f.text;
    lt.readOnly = true;
    lt.title = "Managed server-side in " + f.name;
     var lhbtn = document.createElement("button");
     lhbtn.textContent = "Hide script";
     lhbtn.setAttribute("aria-expanded", "true");
     lhbtn.setAttribute("aria-controls", "server-script-" + g.kind + "-" + g.inputsEl.children.length);
    lt.id = "server-script-" + g.kind + "-" + g.inputsEl.children.length;
    lt.setAttribute("aria-labelledby", ll.id);
     lhbtn.onclick = function () {
       var hidden = lt.style.display === "none";
        lt.style.display = hidden ? "block" : "none";
        lt.hidden = !hidden;
        lhbtn.setAttribute("aria-expanded", hidden ? "true" : "false");
       lhbtn.textContent = hidden ? "Hide script" : "Show script";
     };
     lh.appendChild(lhbtn);
     lock.appendChild(lh); lock.appendChild(lt);
    g.inputsEl.appendChild(lock);
  });
  g.snippets.forEach(function (text, i) {
    var box = document.createElement("div");
    box.className = "snippet";
    var head = document.createElement("header");
    var lab = document.createElement("span");
    lab.textContent = "Snippet " + (i + 1);
    lab.id = "manual-script-label-" + g.kind + "-" + i;
     var del = document.createElement("button");
    del.textContent = "Remove";
    del.onclick = function () {
      g.snippets.splice(i, 1);
      if (!g.snippets.length) g.snippets.push("");
      g.packed = null; g.packedNames = null;
      g.packNotice = null;
      renderAll();
     };
     var ta = document.createElement("textarea");
    ta.value = text;
    ta.placeholder = exampleText(g.kind);
     ta.oninput = function () { g.snippets[i] = ta.value; g.packed = null; g.packedNames = null; g.packNotice = null; renderSlots(g); };
     var hide = document.createElement("button");
     hide.textContent = "Hide script";
    hide.setAttribute("aria-expanded", "true"); hide.setAttribute("aria-controls", "manual-script-" + g.kind + "-" + i); ta.id = "manual-script-" + g.kind + "-" + i;
    ta.setAttribute("aria-labelledby", lab.id);
     hide.onclick = function () {
       var hidden = ta.style.display === "none";
        ta.style.display = hidden ? "block" : "none";
        ta.hidden = !hidden;
        hide.setAttribute("aria-expanded", hidden ? "true" : "false");
       hide.textContent = hidden ? "Hide script" : "Show script";
     };
     head.appendChild(lab); head.appendChild(hide); head.appendChild(del);
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
        if (over) {
          var alert = document.createElement("div");
          alert.className = "limit-alert";
          alert.setAttribute("role", "alert");
          alert.textContent = "⛔ DO NOT PASTE — " + (total - limit) + " characters over the lobby limit. Use Auto-pack or remove content.";
          div.appendChild(alert);
        }
        var pre = document.createElement("div");
        pre.className = "cmd";
        pre.style.display = "none";
        div.appendChild(pre);
        var row = document.createElement("div");
        row.className = "row";
        var cp = document.createElement("button");
        cp.textContent = "Copy";
        cp.disabled = over;
        cp.title = over ? "Blocked: this command exceeds the lobby limit" : "Copy this command";
        (function (c) {
           cp.onclick = function () { copyText(c); };
        })(cmd);
        var showCmd = document.createElement("button");
        showCmd.textContent = "Show command";
        showCmd.setAttribute("aria-expanded", "false"); showCmd.setAttribute("aria-controls", "command-" + g.kind + "-" + idx); pre.id = "command-" + g.kind + "-" + idx;
         showCmd.onclick = (function (command, output, button) {
           return function () {
             var opening = output.style.display === "none";
             if (opening) {
        output.textContent = command;
        output.hidden = false;
               output.style.display = "block";
                button.textContent = "Hide command";
                button.setAttribute("aria-expanded", "true");
             } else {
        output.textContent = "";
        output.hidden = true;
               output.style.display = "none";
                button.textContent = "Show command";
                button.setAttribute("aria-expanded", "false");
             }
           };
         })(cmd, pre, showCmd);
        row.appendChild(showCmd);
        var pv = document.createElement("button");
        pv.textContent = "Show minified";
        pv.setAttribute("aria-expanded", "false"); pv.setAttribute("aria-controls", "minified-" + g.kind + "-" + idx);
        var prev2 = document.createElement("pre");
        prev2.className = "mono output";
        prev2.id = "minified-" + g.kind + "-" + idx;
        prev2.style.display = "none";
         pv.onclick = (function (source, output, button) {
           return function () {
             var opening = output.style.display === "none";
             if (opening) {
                output.textContent = source;
                output.hidden = false;
               output.style.display = "block";
                button.textContent = "Hide minified";
                button.setAttribute("aria-expanded", "true");
             } else {
                output.textContent = "";
                output.hidden = true;
               output.style.display = "none";
                button.textContent = "Show minified";
                button.setAttribute("aria-expanded", "false");
             }
           };
         })(min, prev2, pv);
        row.appendChild(cp); row.appendChild(pv);
        div.appendChild(row);
        div.appendChild(prev2);
      }
    }
    g.slotsEl.appendChild(div);
  }
  if (g.packNotice) {
    var notice = document.createElement("div");
    notice.className = "pack-notice";
    notice.setAttribute("role", "status");
    notice.textContent = g.packNotice;
    g.slotsEl.appendChild(notice);
  }
}

function renderAll() { renderInputs(defs); renderInputs(units); renderSlots(defs); renderSlots(units); }

/* ---------- auto-pack: DOM orchestration ---------- */
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
  var plan = planChunks(g.kind, minis, limit, useUrlSafe());
  var idxChunks = plan.chunks;

  if (plan.oversized.length || plan.overflow.length) {
    var failures = [];
    if (plan.oversized.length) {
      failures.push("over character limit: " + plan.oversized.map(function (i) { return items[i].name; }).join(", "));
    }
    if (plan.overflow.length) {
      failures.push("beyond the " + MAX_SLOTS + "-slot limit: " + plan.overflow.map(function (i) { return items[i].name; }).join(", "));
    }
    g.packNotice = "Auto-pack incomplete — " + failures.join("; ") + ". " + (g.packed ? "Current packed output was retained" : "Existing slot mapping was left unchanged") + "; no partial pack was applied.";
    toast("Auto-pack incomplete. See the packing status below the slots.");
    renderSlots(g);
    return;
  }

  var msg = "Packed " + items.length + " item(s) into " + idxChunks.length + " slot(s)";
  if (g.kind === "tweakdefs") {
    var dups = findDuplicateDst(minis);
    if (dups.length) msg += " — WARNING duplicate dst (last wins): " + dups.join(", ");
  }
  toast(msg);
  g.packNotice = null;
  g.packed = idxChunks.map(function (idxs) { return joinChunk(g, minis, idxs); });
  g.packedNames = idxChunks.map(function (idxs) {
    return idxs.map(function (k) { return items[k].name; });
  });
  renderSlots(g);
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
function collectCombinedCommands() {
  // Keep tweakunits first: BAR applies the table edits before tweakdefs adds
  // or modifies UnitDefs, matching the intended ScavX/EditP pipeline.
  return collectCommands(units).concat(collectCommands(defs));
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
  if (!el) { el = document.createElement("div"); el.id = "toast"; el.className = "toast"; el.setAttribute("role", "status"); el.setAttribute("aria-live", "polite"); document.body.appendChild(el); }
  el.textContent = msg; el.hidden = false; el.style.display = "block";
  clearTimeout(toastTimer);
  toastTimer = setTimeout(function () { el.style.display = "none"; el.hidden = true; }, 2200);
}

/* ---------- wiring ---------- */
function activateTab(btn, moveFocus) {
  document.querySelectorAll(".tab").forEach(function (b) { b.classList.remove("active"); b.setAttribute("aria-selected", "false"); b.setAttribute("tabindex", "-1"); });
  document.querySelectorAll(".panel").forEach(function (p) { p.classList.remove("active"); p.hidden = true; });
  btn.classList.add("active"); btn.setAttribute("aria-selected", "true"); btn.setAttribute("tabindex", "0");
  var panel = $("panel-" + btn.dataset.tab); panel.classList.add("active"); panel.hidden = false;
  if (moveFocus) btn.focus();
}
document.querySelectorAll(".tab").forEach(function (btn) {
  btn.onclick = function () { activateTab(btn, false); };
  btn.onkeydown = function (event) {
    var tabs = Array.prototype.slice.call(document.querySelectorAll(".tab")), i = tabs.indexOf(btn), next = i;
    if (event.key === "ArrowRight") next = (i + 1) % tabs.length;
    else if (event.key === "ArrowLeft") next = (i + tabs.length - 1) % tabs.length;
    else if (event.key === "Home") next = 0;
    else if (event.key === "End") next = tabs.length - 1;
    else return;
    event.preventDefault(); activateTab(tabs[next], true);
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
function copyCombined() {
  var c = collectCombinedCommands();
  if (!c.length) return toast("No tweakdefs or tweakunits to copy");
  copyText(c.join("\n"));
}
$("defsCopyCombined").onclick = copyCombined;
$("resetAll").onclick = function () { copyText(resetAllCommands().join("\n")); };
$("unitsCopyAll").onclick = function () {
  var c = collectCommands(units);
  if (!c.length) return toast("No tweakunits to copy");
  copyText(c.join("\n"));
};
$("unitsCopyCombined").onclick = copyCombined;
$("charLimit").oninput = function () { renderSlots(defs); renderSlots(units); };
$("b64url").onchange = function () { renderAll(); };

$("decodeBtn").onclick = function () {
  var parsed = Pure.parseDecodeInput($("decodeInput").value);
  var b64 = parsed.b64;
  var key = parsed.key;
  try {
    var lua = b64decode(b64);
    $("decodeOutput").textContent = "-- " + key + " — " + b64.length + " b64 chars → " + lua.length + " lua chars\n\n" + lua;
  } catch (e) {
    $("decodeOutput").textContent = "Could not base64-decode that input: " + e;
  }
};

function utilitySetStatus(message, error) {
  var el = $("utilityStatus");
  el.textContent = message;
  el.className = "utility-status" + (message ? (error ? " error" : " success") : "");
}
function utilitySetOutput(value) {
  $("utilityOutput").value = value;
  $("utilityCopy").disabled = value.length === 0;
}
function utilityRun(operation, successMessage) {
  var input = $("utilityInput").value;
  try {
    var output = operation(input);
    utilitySetOutput(output);
    utilitySetStatus(successMessage(output, input));
  } catch (e) {
    utilitySetOutput("");
    utilitySetStatus("Operation failed: " + (e && e.message ? e.message : "Please check the input."), true);
  }
}
$("utilityEncode").onclick = function () {
  utilityRun(function (input) { return b64encode(input, $("utilityUrlSafe").checked); }, function (output) { return output.length + " Base64 characters encoded."; });
};
$("utilityDecode").onclick = function () {
  utilityRun(function (input) { return b64decode(input); }, function (output) { return output.length + " UTF-8 characters decoded."; });
};
$("utilityMinify").onclick = function () {
  utilityRun(luaMinify, function (output, input) { return (input.length - output.length) + " characters removed."; });
};
$("utilityPrettify").onclick = function () {
  utilityRun(luaPrettify, function () { return "Lua prettified."; });
};
$("utilityClear").onclick = function () {
  $("utilityInput").value = "";
  utilitySetOutput("");
  utilitySetStatus("Input and output cleared.");
};
$("utilityUseOutput").onclick = function () {
  var output = $("utilityOutput").value;
  if (!output) {
    utilitySetStatus("There is no output to use as input.", true);
    return;
  }
  $("utilityInput").value = output;
  $("utilityInput").focus();
  utilitySetStatus("Output moved to input.");
};
$("utilityCopy").onclick = function () {
  var output = $("utilityOutput").value;
  if (!output) {
    utilitySetStatus("There is no output to copy.", true);
    return;
  }
  function copied() { utilitySetStatus("Output copied to clipboard."); }
  function fallbackCopy() {
    var field = document.createElement("textarea");
    field.value = output;
    field.setAttribute("readonly", "");
    field.style.position = "fixed";
    field.style.opacity = "0";
    document.body.appendChild(field);
    field.select();
    var succeeded = false;
    try { succeeded = document.execCommand("copy"); } catch (e) { succeeded = false; }
    document.body.removeChild(field);
    if (succeeded) copied();
    else utilitySetStatus("Could not copy output. Select it and copy manually.", true);
  }
  if (navigator.clipboard && navigator.clipboard.writeText) {
    try { navigator.clipboard.writeText(output).then(copied, fallbackCopy); }
    catch (e) { utilitySetStatus("Could not copy output. Select it and copy manually.", true); }
  } else fallbackCopy();
};

renderAll();
