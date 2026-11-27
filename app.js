"use strict";
/* BAR Tweak Packer — 100% client-side.
 * tweakdefs: arbitrary Lua run via loadstring after base64-decode.
 * tweakunits: Lua table deep-merged into UnitDefs.
 * Slots 0..29 each. Per-message cap 16384 chars incl. command. */

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
var findDuplicateDstDetails = Pure.findDuplicateDstDetails;
var findDuplicateTweakUnitKeyDetails = Pure.findDuplicateTweakUnitKeyDetails;
var splitTweakUnitsSource = Pure.splitTweakUnitsSource;
var resetAllCommands = Pure.resetAllCommands;

function $(id) { return document.getElementById(id); }

/* ---------- server library presentation ---------- */
function libFetch() {
  var request = ++libraryRequest;
  var st = $("libStatus");
  st.textContent = "Loading tweak library…";
  st.className = "status-banner is-loading";
  LibraryApi.fetchLibrary().then(function (data) {
    if (request !== libraryRequest) return;
    renderLib(data);
  }).catch(function () {
    if (request !== libraryRequest) return;
    st.textContent = "Library unavailable. Run node server.js locally, or reload the published site. Manual snippets keep working.";
    st.className = "status-banner is-error";
    if (!libraryRendered && !window._lib) {
      $("libDefs").textContent = "";
      $("libUnits").textContent = "";
    }
  });
}

var libraryRequest = 0, libraryRendered = false, librarySearchTimer = null;
var libraryToggleQueues = Object.create(null);

function toggleLibraryFile(kind, name, enabled) {
  var key = kind + "/" + name;
  var previous = libraryToggleQueues[key] || Promise.resolve();
  var current = previous.catch(function () {}).then(function () {
    return LibraryApi.toggle(kind, name, enabled);
  });
  libraryToggleQueues[key] = current;
  return current.then(function (result) {
    if (libraryToggleQueues[key] === current) delete libraryToggleQueues[key];
    return result;
  }, function (error) {
    if (libraryToggleQueues[key] === current) delete libraryToggleQueues[key];
    throw error;
  });
}

function toggleLibraryFiles(files, enabled) {
  return Promise.all(files.map(function (file) {
    return toggleLibraryFile(file.kind, file.name, enabled);
  }));
}

function updateLibHeader(data) {
  var nD = data.defs.length, nU = data.units.length;
  var eD = data.defs.filter(function (f) { return f.enabled; }).length;
  var eU = data.units.filter(function (f) { return f.enabled; }).length;
  var sourceMessage = LibraryApi.isServerMode()
    ? "Loaded from the local server; file changes reload automatically."
    : "Static published library; your enable/disable choices are saved only in this browser.";
  var st = $("libStatus");
  st.textContent = "Loaded " + nD + " defs (" + eD + " enabled) + " + nU + " units (" + eU + " enabled). " + sourceMessage + " Enabled files flow into the packer automatically.";
  st.className = "status-banner is-ready";
  var libCountEl = $("tab-library-count");
  if (libCountEl) {
    var totalEnabled = eD + eU;
    libCountEl.textContent = totalEnabled ? totalEnabled + " on" : "";
  }
}

function renderLib(data) {
  updateLibHeader(data);
  window._lib = data;
  syncLibToPacker();
  if (libraryRendered) renderLibrary();
}

function renderLibrary() {
  if (!window._lib) return;
  libraryRendered = true;
  renderLibGroup($("libDefs"), "defs", window._lib.defs);
  renderLibGroup($("libUnits"), "units", window._lib.units);
}

function renderLibGroup(el, kind, files) {
  var fragment = document.createDocumentFragment();
  var fileIndexes = Object.create(null);
  files.forEach(function (file, index) { fileIndexes[file.name] = index; });
  if (!files.length) {
    var none = document.createElement("div");
    none.className = "slot empty";
    none.textContent = "(no .lua files yet)";
    fragment.appendChild(none); el.replaceChildren(fragment);
    return;
  }
  var openByFolder = Object.create(null);
  if (el.querySelectorAll) {
    el.querySelectorAll(".library-group").forEach(function (groupEl) {
      var folderKey = groupEl.getAttribute("data-folder");
      if (folderKey !== null) openByFolder[folderKey] = !!groupEl.open;
    });
  }
  var query = ($("libSearch") ? $("libSearch").value : "").toLowerCase();
  var enabledOnly = !!($("libEnabledOnly") && $("libEnabledOnly").checked);
  var filtered = files.filter(function (f) {
    if (enabledOnly && !f.enabled) return false;
    return f.name.toLowerCase().indexOf(query) !== -1;
  });
  if (!filtered.length) {
    var none = document.createElement("div"); none.className = "slot empty";
    none.textContent = files.length ? (enabledOnly ? "No enabled filenames match your filter." : "No filenames match your search.") : "No .lua files yet.";
    fragment.appendChild(none); el.replaceChildren(fragment); return;
  }
  var groups = {};
  filtered.forEach(function (f) {
    var parts = f.name.split("/"); var folder = parts.length > 1 ? parts.slice(0, -1).join("/") : "";
    if (!groups[folder]) groups[folder] = [];
    groups[folder].push(f);
  });
  var names = Object.keys(groups).sort(function (a, b) { if (!a) return -1; if (!b) return 1; return a.toLowerCase().localeCompare(b.toLowerCase()); });
  names.forEach(function (folder) {
    var groupFiles = groups[folder].sort(function (a, b) { return a.name.toLowerCase().localeCompare(b.name.toLowerCase()); });
    var enabled = groupFiles.filter(function (f) { return f.enabled; }).length;
    var details = document.createElement("details");
    details.className = "library-group";
    details.setAttribute("data-folder", folder);
    details.open = Object.prototype.hasOwnProperty.call(openByFolder, folder) ? openByFolder[folder] : true;
    var summary = document.createElement("summary");
    var summaryTitle = document.createElement("span");
    summaryTitle.className = "library-group-title";
    summaryTitle.textContent = folder || "Root";
    var summaryCount = document.createElement("span");
    summaryCount.className = "library-group-count";
    summaryCount.textContent = enabled + "/" + groupFiles.length + " enabled";
    summary.appendChild(summaryTitle);
    summary.appendChild(summaryCount);
    var actions = document.createElement("div"); actions.className = "library-group-actions";
    [true, false].forEach(function (enable) {
      var action = document.createElement("button"); action.type = "button"; action.textContent = enable ? "Enable group" : "Disable group";
      action.onclick = function () {
        groupFiles.forEach(function (f) { f.enabled = enable; });
        if (window._lib) updateLibHeader(window._lib);
        syncLibToPacker();
        renderLibrary();
        toggleLibraryFiles(groupFiles.map(function (f) { return { kind: kind, name: f.name }; }), enable)
          .catch(function () { toast("Group toggle failed."); libFetch(); });
      };
      actions.appendChild(action);
    });
    details.appendChild(summary); details.appendChild(actions);
    groupFiles.forEach(function (f) {
    var div = document.createElement("div");
    div.className = "slot" + (f.enabled ? "" : " empty");
    var head = document.createElement("header");
    var left = document.createElement("span");
    var cb = document.createElement("input");
    cb.type = "checkbox";
    cb.checked = !!f.enabled;
    cb.title = "Enable or disable " + f.name + " (file is kept)";
    var checkboxLabel = document.createElement("label");
    checkboxLabel.className = "library-file-toggle";
    checkboxLabel.appendChild(cb);
    var nm = document.createElement("span");
    nm.className = "name";
    nm.textContent = f.name;
    checkboxLabel.appendChild(nm);
    checkboxLabel.setAttribute("aria-label", (f.enabled ? "Disable " : "Enable ") + f.name);
    cb.onchange = function () {
      var nextEnabled = !!cb.checked;
      var prevEnabled = !!f.enabled;
      f.enabled = nextEnabled;
      div.className = "slot" + (nextEnabled ? "" : " empty");
      checkboxLabel.setAttribute("aria-label", (nextEnabled ? "Disable " : "Enable ") + f.name);
      summaryCount.textContent = groupFiles.filter(function (gf) { return gf.enabled; }).length + "/" + groupFiles.length + " enabled";
      if (window._lib) updateLibHeader(window._lib);
      syncLibToPacker();
      if ($("libEnabledOnly") && $("libEnabledOnly").checked) renderLibrary();
      toggleLibraryFile(kind, f.name, nextEnabled).then(function (r) {
        if (!r || !r.ok) throw new Error("Toggle failed");
      }, function () {
        f.enabled = prevEnabled;
        cb.checked = prevEnabled;
        div.className = "slot" + (prevEnabled ? "" : " empty");
        checkboxLabel.setAttribute("aria-label", (prevEnabled ? "Disable " : "Enable ") + f.name);
        summaryCount.textContent = groupFiles.filter(function (gf) { return gf.enabled; }).length + "/" + groupFiles.length + " enabled";
        if (window._lib) updateLibHeader(window._lib);
        syncLibToPacker();
        if (libraryRendered) renderLibrary();
        toast("Toggle failed; browser storage may be unavailable.");
      });
    };
    left.appendChild(checkboxLabel);
    var st = document.createElement("span");
    st.className = "stats";
    st.textContent = f.chars + " chars";
    head.appendChild(left);
    head.appendChild(st);
    div.appendChild(head);
    var row = document.createElement("div");
    row.className = "row";
    var pv = document.createElement("button");
     pv.type = "button";
     pv.textContent = "Preview";
     pv.setAttribute("aria-expanded", "false");
     var pre = document.createElement("pre");
     pre.className = "mono output";
      pre.id = "lib-preview-" + kind + "-" + fileIndexes[f.name];
      pv.setAttribute("aria-controls", pre.id);
     pre.hidden = true;
     // Keep large library scripts out of the DOM until the user asks to see
     // them. This avoids creating hundreds of thousands of text nodes on load.
     pv.onclick = function () {
       var opening = pre.hidden;
       if (opening) {
          pre.textContent = f.content;
          pre.hidden = false;
        pv.textContent = "Hide script";
        pv.setAttribute("aria-expanded", "true");
       } else {
          pre.textContent = "";
         pre.hidden = true;
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
    fragment.appendChild(details);
  });
  el.replaceChildren(fragment);
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
  if (!onlyKind || onlyKind === "defs") data.defs.forEach(function (f) { f.enabled = enabled; files.push({ kind: "defs", name: f.name }); });
  if (!onlyKind || onlyKind === "units") data.units.forEach(function (f) { f.enabled = enabled; files.push({ kind: "units", name: f.name }); });
  if (!files.length) { toast("No library files."); return; }
  updateLibHeader(data);
  syncLibToPacker();
  if (libraryRendered) renderLibrary();
  toggleLibraryFiles(files, enabled).catch(function () { toast("Bulk toggle failed \u2014 is the server running?"); libFetch(); });
}
$("libReload").onclick = libFetch;
$("defsLibReload").onclick = libFetch;
$("unitsLibReload").onclick = libFetch;
$("libEnableAll").onclick = function () { setAllLib(true); };
$("libDisableAll").onclick = function () { setAllLib(false); };
$("libDefs").setAttribute("data-kind", "defs"); $("libUnits").setAttribute("data-kind", "units");
$("libSearch").oninput = function () { clearTimeout(librarySearchTimer); librarySearchTimer = setTimeout(function () { if (libraryRendered) renderLibrary(); }, 180); };
$("libSearchClear").onclick = function () { $("libSearch").value = ""; clearTimeout(librarySearchTimer); if (libraryRendered) renderLibrary(); $("libSearch").focus(); };
if ($("libEnabledOnly")) $("libEnabledOnly").onchange = function () { if (libraryRendered) renderLibrary(); };
var libVersion = null;
function watchLibrary() {
  if (!LibraryApi.isServerMode()) return;
  LibraryApi.fetchVersion().then(function (data) {
    if (libVersion !== null && data.version !== libVersion) libFetch();
    libVersion = data.version;
  }).catch(function () {}).finally(function () { setTimeout(watchLibrary, 2000); });
}
libFetch();
watchLibrary();

function useUrlSafe() {
  var cb = (typeof document !== "undefined") ? document.getElementById("b64url") : null;
  return !!(cb && cb.checked);
}
function getLimit() { return Pure.getLimit($("charLimit").value); }

var EDITOR_STORAGE_KEY = "bar-tweak-packer-editor-state-v1";

function editorStorage() {
  try { return typeof globalThis !== "undefined" ? globalThis.localStorage : null; } catch (error) { return null; }
}

function saveEditorState() {
  var store = editorStorage();
  if (!store) return;
  try {
    store.setItem(EDITOR_STORAGE_KEY, JSON.stringify({
      defs: defs.snippets,
      units: units.snippets,
      charLimit: $("charLimit") ? $("charLimit").value : "16384",
      b64url: useUrlSafe()
    }));
  } catch (error) {}
}

function loadEditorState() {
  var store = editorStorage();
  if (!store) return;
  try {
    var raw = store.getItem(EDITOR_STORAGE_KEY);
    if (!raw) return;
    var saved = JSON.parse(raw);
    if (!saved || typeof saved !== "object") return;
    if (Array.isArray(saved.defs) && saved.defs.length) {
      defs.snippets = saved.defs.map(function (s) { return typeof s === "string" ? s : String(s || ""); });
    }
    if (Array.isArray(saved.units) && saved.units.length) {
      units.snippets = saved.units.map(function (s) { return typeof s === "string" ? s : String(s || ""); });
    }
    if (saved.charLimit !== undefined && $("charLimit")) $("charLimit").value = String(saved.charLimit);
    if (typeof saved.b64url === "boolean" && $("b64url")) $("b64url").checked = saved.b64url;
  } catch (error) {}
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
    packed: null,
    packNotice: null,
    slotRenderTimer: null
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
    var index = g.inputsEl.children.length;
    var lock = document.createElement("div");
    lock.className = "snippet locked is-collapsed";
    var lh = document.createElement("header");
    var titleGroup = document.createElement("div");
    titleGroup.className = "snippet-title-group";
    var ll = document.createElement("span");
    ll.className = "snippet-title";
    ll.textContent = f.name;
    ll.id = "server-script-label-" + g.kind + "-" + index;
    var badge = document.createElement("span");
    badge.className = "snippet-badge snippet-badge-lib";
    badge.textContent = "Library \u00b7 " + f.text.length + " chars";
    titleGroup.appendChild(ll);
    titleGroup.appendChild(badge);
    lh.appendChild(titleGroup);
    var lt = document.createElement("textarea");
    lt.value = f.text;
    lt.readOnly = true;
    lt.hidden = true;
    lt.style.display = "none";
    lt.title = "Managed server-side in " + f.name;
    var lhbtn = document.createElement("button");
    lhbtn.type = "button";
    lhbtn.textContent = "Show script";
    lhbtn.setAttribute("aria-expanded", "false");
    lhbtn.setAttribute("aria-controls", "server-script-" + g.kind + "-" + index);
    lt.id = "server-script-" + g.kind + "-" + index;
    lt.setAttribute("aria-labelledby", ll.id);
    lhbtn.onclick = function () {
      var hidden = lt.style.display === "none";
      lt.style.display = hidden ? "block" : "none";
      lt.hidden = !hidden;
      lock.classList.toggle("is-collapsed", !hidden);
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
    var titleGroup = document.createElement("div");
    titleGroup.className = "snippet-title-group";
    var lab = document.createElement("span");
    lab.className = "snippet-title";
    lab.textContent = "Snippet " + (i + 1);
    lab.id = "manual-script-label-" + g.kind + "-" + i;
    var charBadge = document.createElement("span");
    charBadge.className = "snippet-badge snippet-chars";
    charBadge.textContent = text.length + " chars";
    titleGroup.appendChild(lab);
    titleGroup.appendChild(charBadge);
    var controls = document.createElement("div");
    controls.className = "snippet-controls";
    var del = document.createElement("button");
    del.type = "button";
    del.className = "danger-ghost";
    del.textContent = "Remove";
    del.onclick = function () {
      g.snippets.splice(i, 1);
      if (!g.snippets.length) g.snippets.push("");
      g.packed = null; g.packedNames = null;
      g.packNotice = null;
      saveEditorState();
      renderAll();
    };
    var ta = document.createElement("textarea");
    ta.value = text;
    ta.placeholder = exampleText(g.kind);
    ta.oninput = function () {
      g.snippets[i] = ta.value;
      charBadge.textContent = ta.value.length + " chars";
      g.packed = null; g.packedNames = null; g.packNotice = null;
      saveEditorState();
      scheduleRenderSlots(g, 80);
    };
    var hide = document.createElement("button");
    hide.type = "button";
    hide.textContent = "Hide script";
    hide.setAttribute("aria-expanded", "true"); hide.setAttribute("aria-controls", "manual-script-" + g.kind + "-" + i); ta.id = "manual-script-" + g.kind + "-" + i;
    ta.setAttribute("aria-labelledby", lab.id);
    hide.onclick = function () {
      var hidden = ta.style.display === "none";
      ta.style.display = hidden ? "block" : "none";
      ta.hidden = !hidden;
      box.classList.toggle("is-collapsed", !hidden);
      hide.setAttribute("aria-expanded", hidden ? "true" : "false");
      hide.textContent = hidden ? "Hide script" : "Show script";
    };
    controls.appendChild(hide);
    controls.appendChild(del);
    head.appendChild(titleGroup);
    head.appendChild(controls);
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

var slotCompileCache = Object.create(null);

function compileSlot(kind, idx, raw, urlSafe) {
  var cacheKey = kind + ":" + idx + ":" + (urlSafe ? "1" : "0");
  var cached = slotCompileCache[cacheKey];
  if (cached && cached.raw === raw) return cached;
  var entry = { raw: raw, min: null, b64: null, cmd: null, err: null };
  try {
    var min = luaMinify(raw);
    if (kind === "tweakunits") mergeTweakUnits([min]);
    var r = buildCommand(kind, idx, min, urlSafe);
    entry.min = min;
    entry.b64 = r.b64;
    entry.cmd = r.cmd;
  } catch (e) {
    entry.err = String(e);
  }
  slotCompileCache[cacheKey] = entry;
  return entry;
}

function scheduleRenderSlots(g, delayMs) {
  clearTimeout(g.slotRenderTimer);
  g.slotRenderTimer = setTimeout(function () {
    g.slotRenderTimer = null;
    renderSlots(g);
  }, delayMs || 80);
}

function renderSlots(g) {
  if (g.slotRenderTimer) {
    clearTimeout(g.slotRenderTimer);
    g.slotRenderTimer = null;
  }
  var limit = getLimit();
  var urlSafe = useUrlSafe();
  var srcs = slotSources(g);
  var usedCount = 0;
  var overCount = 0;
  var existingDetails = g.slotsEl.querySelector ? g.slotsEl.querySelector(".empty-slots-group") : null;
  var keepEmptyOpen = !!(existingDetails && existingDetails.open);
  var openCmdSlots = Object.create(null);
  var openMinSlots = Object.create(null);
  if (g.slotsEl.querySelectorAll) {
    g.slotsEl.querySelectorAll(".slot[data-slot-index]").forEach(function (slotEl) {
      var slotIdx = slotEl.getAttribute("data-slot-index");
      var cmdEl = $("command-" + g.kind + "-" + slotIdx);
      var minEl = $("minified-" + g.kind + "-" + slotIdx);
      if (cmdEl && cmdEl.style.display !== "none") openCmdSlots[slotIdx] = true;
      if (minEl && minEl.style.display !== "none") openMinSlots[slotIdx] = true;
    });
  }
  var fragment = document.createDocumentFragment();
  var emptyNodes = [];
  for (var idx = 0; idx < MAX_SLOTS; idx++) {
    var raw = srcs[idx] || "";
    var div = document.createElement("div");
    div.setAttribute("data-slot-index", String(idx));
    var has = raw.trim() !== "";
    if (has) usedCount++;
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
      var compiled = compileSlot(g.kind, idx, raw, urlSafe);
      var min = compiled.min, b64 = compiled.b64, cmd = compiled.cmd, err = compiled.err;
      if (err) {
        overCount++;
        st.textContent = "Lua input error: " + err;
        st.className = "stats bad";
        div.classList.add("over");
      } else {
        var total = cmd.length;
        var over = total > limit;
        if (over) {
          overCount++;
          div.classList.add("over");
        }
        st.innerHTML = "";
        var parts = [
          "raw " + raw.length,
          "min " + min.length,
          "b64 " + b64.length,
          "cmd " + total + "/" + limit
        ];
        st.textContent = parts.join(" · ") + (over ? " — OVER LIMIT" : " — OK");
        st.className = "stats " + (over ? "bad" : "good");
        var meter = document.createElement("div");
        meter.className = "slot-meter";
        meter.setAttribute("aria-hidden", "true");
        var meterFill = document.createElement("div");
        meterFill.className = "slot-meter-fill" + (over ? " is-over" : (total / limit >= 0.85 ? " is-warn" : ""));
        meterFill.style.width = Math.min(100, Math.round((total / limit) * 1000) / 10) + "%";
        meter.appendChild(meterFill);
        div.appendChild(meter);
        if (over) {
          var alert = document.createElement("div");
          alert.className = "limit-alert";
          alert.setAttribute("role", "alert");
          alert.textContent = "⛔ DO NOT PASTE — " + (total - limit) + " characters over the lobby limit. Use Auto-pack or remove content.";
          div.appendChild(alert);
        }
        var pre = document.createElement("div");
        pre.className = "cmd";
        var isCmdOpen = !!openCmdSlots[String(idx)];
        pre.hidden = !isCmdOpen;
        pre.style.display = isCmdOpen ? "block" : "none";
        if (isCmdOpen) pre.textContent = cmd;
        div.appendChild(pre);
        var row = document.createElement("div");
        row.className = "row";
        var cp = document.createElement("button");
        cp.type = "button";
        cp.className = "slot-copy";
        cp.textContent = "Copy";
        cp.disabled = over;
        cp.title = over ? "Blocked: this command exceeds the lobby limit" : "Copy this command";
        (function (c) {
           cp.onclick = function () { copyText(c); };
        })(cmd);
        var showCmd = document.createElement("button");
        showCmd.type = "button";
        showCmd.textContent = isCmdOpen ? "Hide command" : "Show command";
        showCmd.setAttribute("aria-expanded", isCmdOpen ? "true" : "false"); showCmd.setAttribute("aria-controls", "command-" + g.kind + "-" + idx); pre.id = "command-" + g.kind + "-" + idx;
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
        pv.type = "button";
        var isMinOpen = !!openMinSlots[String(idx)];
        pv.textContent = isMinOpen ? "Hide minified" : "Show minified";
        pv.setAttribute("aria-expanded", isMinOpen ? "true" : "false"); pv.setAttribute("aria-controls", "minified-" + g.kind + "-" + idx);
        var prev2 = document.createElement("pre");
        prev2.className = "mono output";
        prev2.id = "minified-" + g.kind + "-" + idx;
        prev2.hidden = !isMinOpen;
        prev2.style.display = isMinOpen ? "block" : "none";
        if (isMinOpen) prev2.textContent = min;
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
    if (has) fragment.appendChild(div);
    else emptyNodes.push(div);
  }
  if (emptyNodes.length) {
    var emptyDetails = document.createElement("details");
    emptyDetails.className = "empty-slots-group";
    if (keepEmptyOpen) emptyDetails.open = true;
    var emptySummary = document.createElement("summary");
    emptySummary.className = "empty-slots-summary";
    var emptyTitle = document.createElement("span");
    emptyTitle.textContent = "Unused slots (" + emptyNodes.length + " of " + MAX_SLOTS + ")";
    var emptyPill = document.createElement("span");
    emptyPill.className = "empty-slots-pill";
    emptyPill.textContent = keepEmptyOpen ? "Hide empty slots" : "Show empty slots";
    emptySummary.appendChild(emptyTitle);
    emptySummary.appendChild(emptyPill);
    emptyDetails.ontoggle = function () {
      emptyPill.textContent = emptyDetails.open ? "Hide empty slots" : "Show empty slots";
    };
    var emptyGrid = document.createElement("div");
    emptyGrid.className = "empty-slots-grid";
    emptyNodes.forEach(function (node) { emptyGrid.appendChild(node); });
    emptyDetails.appendChild(emptySummary);
    emptyDetails.appendChild(emptyGrid);
    fragment.appendChild(emptyDetails);
  }
  var summaryEl = $(g.kind === "tweakdefs" ? "defsSlotSummary" : "unitsSlotSummary");
  if (summaryEl) {
    var summaryText = usedCount + "/" + MAX_SLOTS + " active";
    if (g.packed) summaryText += " · packed";
    if (overCount) summaryText += " · " + overCount + " over limit";
    summaryEl.textContent = summaryText;
    summaryEl.className = "section-pill" + (overCount ? " is-danger" : (usedCount ? " is-active" : ""));
  }
  var tabCountEl = $(g.kind === "tweakdefs" ? "tab-defs-count" : "tab-units-count");
  if (tabCountEl) {
    tabCountEl.textContent = usedCount ? usedCount + "/" + MAX_SLOTS : "";
    tabCountEl.className = "tab-count" + (overCount ? " is-danger" : "");
  }
  var noticeHost = $(g.kind === "tweakdefs" ? "defsPackNotice" : "unitsPackNotice");
  if (noticeHost) noticeHost.replaceChildren();
  if (g.packNotice) {
    var notice = document.createElement("div");
    notice.className = "pack-notice";
    notice.setAttribute("role", "status");
    notice.textContent = g.packNotice;
    if (noticeHost) noticeHost.appendChild(notice);
    else fragment.insertBefore(notice, fragment.firstChild);
  }
  g.slotsEl.replaceChildren(fragment);
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

  function showFailure(message) {
    g.packNotice = "Auto-pack not applied — " + message + ". " + (g.packed ? "Current packed output was retained" : "Existing slot mapping was left unchanged") + "; no partial pack was applied.";
    toast("Auto-pack not applied. See the packing status above the slots.");
    renderSlots(g);
  }
  function describeError(error) {
    return error && error.message ? error.message : String(error);
  }

  var validItems = [], minis = [];
  for (var itemIndex = 0; itemIndex < items.length; itemIndex++) {
    var minified;
    try {
      minified = luaMinify(items[itemIndex].text);
      if (g.kind === "tweakunits" && minified) mergeTweakUnits([minified]);
    } catch (error) {
      showFailure(items[itemIndex].name + ": " + describeError(error));
      return;
    }
    if (minified) {
      if (g.kind === "tweakunits" && buildCommand(g.kind, MAX_SLOTS - 1, minified, useUrlSafe()).cmd.length > limit) {
        try {
          var internalDuplicates = findDuplicateTweakUnitKeyDetails([minified]);
          if (internalDuplicates.length) {
            throw new Error("contains repeated top-level unit key(s): " + internalDuplicates.map(function (detail) { return detail.key; }).join(", ") + "; cannot split without changing last-wins behavior");
          }
          var pieces = splitTweakUnitsSource(minified, limit, useUrlSafe());
          pieces.forEach(function (piece, partIndex) {
            validItems.push({ name: items[itemIndex].name + " (part " + (partIndex + 1) + "/" + pieces.length + ")", sourceName: items[itemIndex].sourceName || items[itemIndex].name, sourceIndex: items[itemIndex].sourceIndex, text: piece });
            minis.push(piece);
          });
        } catch (splitError) {
          showFailure(items[itemIndex].name + " is oversized and cannot be split safely: " + describeError(splitError));
          return;
        }
      } else {
        validItems.push(items[itemIndex]);
        minis.push(minified);
      }
    }
  }
  items = validItems;
  if (g.kind === "tweakunits") {
    var unsupportedFields = findUnsupportedTweakUnitFieldSources(minis);
    if (unsupportedFields.length) {
      showFailure("cannot verify computed or non-identifier top-level tweakunits fields in " + unsupportedFields.map(function (index) { return items[index].name; }).join(", ") + "; convert them to literal unit-name keys before packing");
      return;
    }
  }
  if (!items.length) { toast("Nothing to pack after removing comments and whitespace"); return; }

  var plan;
  try {
    plan = planChunks(g.kind, minis, limit, useUrlSafe());
  } catch (error) {
    showFailure("could not safely combine the inputs: " + describeError(error));
    return;
  }
  var idxChunks = plan.chunks;

  // Refuse any repeated literal unit key. One combined Lua table loses the
  // earlier value; separate BAR slots recursively merge, so silently changing
  // the partition would otherwise change the result rather than fix ambiguity.
  if (g.kind === "tweakunits") {
    var collisionDetails = findDuplicateTweakUnitKeyDetails(minis);
    if (collisionDetails.length) {
      var collisionSummary = collisionDetails.map(function (detail) {
        return detail.key + " in " + detail.sources.map(function (index) { return items[index].name; }).join(" + ");
      }).join("; ");
      showFailure("duplicate top-level tweakunits key(s) have partition-dependent behavior and may discard earlier table entries: " + collisionSummary + ". Separate or reconcile these definitions before packing");
      return;
    }
  }

  if (plan.oversized.length || plan.overflow.length) {
    var diagnostics = [];
    diagnostics.push("requires " + idxChunks.length + " slot(s); BAR supports " + MAX_SLOTS);
    var blockersBySource = Object.create(null);
    function sourceBlocker(index) {
      var item = items[index], key = item.sourceIndex;
      if (!blockersBySource[key]) blockersBySource[key] = { name: item.sourceName || item.name, oversized: 0, slots: [] };
      return blockersBySource[key];
    }
    plan.oversized.forEach(function (i) {
      var cmd = buildCommand(g.kind, MAX_SLOTS - 1, minis[i], useUrlSafe()).cmd;
      var blocker = sourceBlocker(i);
      blocker.oversized = Math.max(blocker.oversized, cmd.length - limit);
    });
    plan.overflow.forEach(function (i) {
      var blocker = sourceBlocker(i);
      var slot = plan.chunks.findIndex(function (chunk) { return chunk.indexOf(i) >= 0; }) + 1;
      if (blocker.slots.indexOf(slot) < 0) blocker.slots.push(slot);
    });
    var blockers = Object.keys(blockersBySource).map(function (key) {
      var blocker = blockersBySource[key], detail = blocker.name;
      if (blocker.oversized) detail += " (" + blocker.oversized + " chars over limit)";
      if (blocker.slots.length) detail += " (overflow slot(s) " + blocker.slots.join(", ") + ")";
      return detail;
    });
    if (blockers.length) diagnostics.push("blockers: " + blockers.join(", "));

    // Advisory only: estimate removal candidates by original source, never by generated split part.
    var sourceGroups = Object.create(null);
    items.forEach(function (item, index) {
      var key = item.sourceIndex;
      if (!sourceGroups[key]) sourceGroups[key] = { name: item.sourceName || item.name, indexes: [], size: 0 };
      sourceGroups[key].indexes.push(index);
      sourceGroups[key].size += buildCommand(g.kind, MAX_SLOTS - 1, minis[index], useUrlSafe()).cmd.length;
    });
    var candidates = Object.keys(sourceGroups).map(function (key) { return sourceGroups[key]; })
      .sort(function (a, b) { return b.size - a.size; });
    var removed = Object.create(null), suggestion = [];
    for (var candidateIndex = 0; candidateIndex < candidates.length; candidateIndex++) {
      var candidate = candidates[candidateIndex];
      candidate.indexes.forEach(function (index) { removed[index] = true; });
      suggestion.push(candidate.name);
      var remaining = minis.filter(function (_, index) { return !removed[index]; });
      if (!remaining.length) break;
      var trial = planChunks(g.kind, remaining, limit, useUrlSafe());
      if (!trial.oversized.length && !trial.overflow.length) break;
    }
    if (suggestion.length && suggestion.length < items.length) {
      diagnostics.push("to test a fit, consider temporarily disabling: " + suggestion.join(", ") + " (recommendation only; nothing was changed)");
    } else {
      diagnostics.push("reduce content or raise the configured character limit only if the target lobby permits it");
    }
    showFailure(diagnostics.join(". "));
    return;
  }

  var msg = "Packed " + items.length + " item(s) into " + idxChunks.length + " slot(s)";
  var duplicateSummary = "";
  if (g.kind === "tweakdefs") {
    var duplicates = findDuplicateDstDetails(minis);
    duplicateSummary = duplicates.map(function (detail) {
      var contributors = detail.sources.map(function (index) { return items[index].name; });
      return '"' + detail.dst + '" in ' + contributors.join(" + ");
    }).join("; ");
    if (duplicateSummary) msg += " — WARNING duplicate dst: " + duplicateSummary;
  }
  toast(msg);
  g.packNotice = duplicateSummary ? "Duplicate destination warning — " + duplicateSummary : null;
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
    var minified = luaMinify(srcs[idx]);
    if (g.kind === "tweakunits") mergeTweakUnits([minified]);
    cmds.push(buildCommand(g.kind, idx, minified, useUrlSafe()).cmd);
  }
  return cmds;
}
function collectCombinedCommands() {
  // Keep tweakunits first: BAR applies the table edits before tweakdefs adds
  // or modifies UnitDefs, matching the intended ScavX/EditP pipeline.
  return collectCommands(units).concat(collectCommands(defs));
}

function copyCommandSet(collect, emptyMessage) {
  try {
    var commands = collect();
    if (!commands.length) return toast(emptyMessage);
    copyText(commands.join("\n"));
  } catch (error) {
    toast("Could not build commands: " + (error && error.message ? error.message : String(error)));
  }
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
  el.textContent = msg;
  el.hidden = false;
  el.style.display = "flex";
  el.classList.remove("is-visible");
  void el.offsetWidth;
  el.classList.add("is-visible");
  clearTimeout(toastTimer);
  toastTimer = setTimeout(function () {
    el.classList.remove("is-visible");
    el.style.display = "none";
    el.hidden = true;
  }, 2400);
}

/* ---------- wiring ---------- */
function activateTab(btn, moveFocus) {
  document.querySelectorAll(".tab").forEach(function (b) { b.classList.remove("active"); b.setAttribute("aria-selected", "false"); b.setAttribute("tabindex", "-1"); });
  document.querySelectorAll(".panel").forEach(function (p) { p.classList.remove("active"); p.hidden = true; });
  btn.classList.add("active"); btn.setAttribute("aria-selected", "true"); btn.setAttribute("tabindex", "0");
  var panel = $("panel-" + btn.dataset.tab); panel.classList.add("active"); panel.hidden = false;
  if (moveFocus) btn.focus();
  if (btn.dataset.tab === "library") renderLibrary();
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

$("defsAdd").onclick = function () { defs.snippets.push(""); defs.packed = null; defs.packedNames = null; saveEditorState(); renderInputs(defs); };
$("unitsAdd").onclick = function () { units.snippets.push(""); units.packed = null; units.packedNames = null; saveEditorState(); renderInputs(units); };
$("defsPack").onclick = function () { autoPack(defs); };
$("unitsPack").onclick = function () { autoPack(units); };
$("defsClear").onclick = function () { defs.snippets = [""]; defs.packed = null; defs.packedNames = null; saveEditorState(); renderAll(); };
$("unitsClear").onclick = function () { units.snippets = [""]; units.packed = null; units.packedNames = null; saveEditorState(); renderAll(); };
$("defsCopyAll").onclick = function () {
  copyCommandSet(function () { return collectCommands(defs); }, "No tweakdefs to copy");
};
function copyCombined() {
  copyCommandSet(collectCombinedCommands, "No tweakdefs or tweakunits to copy");
}
$("defsCopyCombined").onclick = copyCombined;
$("resetAll").onclick = function () { copyText(resetAllCommands().join("\n")); };
$("unitsCopyAll").onclick = function () {
  copyCommandSet(function () { return collectCommands(units); }, "No tweakunits to copy");
};
$("unitsCopyCombined").onclick = copyCombined;
var charLimitTimer = null;
$("charLimit").oninput = function () {
  saveEditorState();
  clearTimeout(charLimitTimer);
  charLimitTimer = setTimeout(function () { renderSlots(defs); renderSlots(units); }, 120);
};
$("b64url").onchange = function () { saveEditorState(); renderAll(); };

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

loadEditorState();
renderAll();
