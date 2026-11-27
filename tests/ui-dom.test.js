"use strict";

const { test } = require("node:test");
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const vm = require("node:vm");
const pure = require("../app-pure");

function createClassList(el) {
  function list() {
    return (el._className || "").trim().split(/\s+/).filter(Boolean);
  }
  return {
    add: (...names) => {
      const next = new Set(list());
      names.forEach((n) => next.add(n));
      el._className = Array.from(next).join(" ");
    },
    remove: (...names) => {
      const drop = new Set(names);
      el._className = list().filter((n) => !drop.has(n)).join(" ");
    },
    toggle: (name, force) => {
      const has = list().includes(name);
      const want = force === undefined ? !has : !!force;
      if (want) el.classList.add(name);
      else el.classList.remove(name);
      return want;
    },
    contains: (name) => list().includes(name),
  };
}

function matchesSimpleSelector(el, selector) {
  if (!selector) return false;
  if (selector.startsWith(".")) {
    const bracket = selector.indexOf("[");
    if (bracket === -1) return el.classList.contains(selector.slice(1));
    const cls = selector.slice(1, bracket);
    const attr = selector.slice(bracket + 1, -1);
    return el.classList.contains(cls) && el.attributes.has(attr);
  }
  if (selector.startsWith("#")) return el.id === selector.slice(1);
  return el.tagName.toLowerCase() === selector.toLowerCase();
}

function createElement(doc, tagName) {
  const el = {
    tagName: String(tagName).toUpperCase(),
    _id: "",
    _className: "",
    _textContent: "",
    attributes: new Map(),
    dataset: {},
    style: {},
    children: [],
    parentNode: null,
    hidden: false,
    disabled: false,
    checked: false,
    readOnly: false,
    open: false,
    value: "",
    type: "",
    title: "",
    placeholder: "",
    classList: null,
    get id() { return this._id; },
    set id(v) {
      if (this._id && doc._byId.get(this._id) === this) doc._byId.delete(this._id);
      this._id = String(v);
      if (this._id) doc._byId.set(this._id, this);
    },
    get className() { return this._className; },
    set className(v) { this._className = String(v || ""); },
    get textContent() {
      if (this.children.length === 0) return this._textContent;
      return this._textContent + this.children.map((c) => c.textContent).join("");
    },
    set textContent(v) {
      this._textContent = String(v ?? "");
      this.children = [];
    },
    get innerHTML() { return ""; },
    set innerHTML(v) {
      if (v === "") {
        this.children = [];
        this._textContent = "";
      }
    },
    get offsetWidth() { return 100; },
    appendChild(child) {
      if (!child) return child;
      if (child.isFragment) {
        child.children.slice().forEach((c) => this.appendChild(c));
        child.children = [];
        return child;
      }
      child.parentNode = this;
      this.children.push(child);
      return child;
    },
    insertBefore(child, ref) {
      if (!ref) return this.appendChild(child);
      const index = this.children.indexOf(ref);
      if (index === -1) return this.appendChild(child);
      child.parentNode = this;
      this.children.splice(index, 0, child);
      return child;
    },
    removeChild(child) {
      const idx = this.children.indexOf(child);
      if (idx >= 0) this.children.splice(idx, 1);
      child.parentNode = null;
      return child;
    },
    replaceChildren(...nodes) {
      this.children = [];
      this._textContent = "";
      nodes.forEach((n) => this.appendChild(n));
    },
    setAttribute(name, value) {
      const str = String(value);
      this.attributes.set(name, str);
      if (name === "id") this.id = str;
      if (name.startsWith("data-")) this.dataset[name.slice(5)] = str;
    },
    getAttribute(name) {
      return this.attributes.has(name) ? this.attributes.get(name) : null;
    },
    querySelectorAll(selector) {
      const out = [];
      function walk(node) {
        for (const child of node.children) {
          if (matchesSimpleSelector(child, selector)) out.push(child);
          walk(child);
        }
      }
      walk(this);
      return out;
    },
    querySelector(selector) {
      return this.querySelectorAll(selector)[0] || null;
    },
    focus() { doc.activeElement = this; },
    select() {},
  };
  el.classList = createClassList(el);
  return el;
}

function mountApp(options = {}) {
  const storageMap = options.storageMap || new Map();
  const doc = {
    _byId: new Map(),
    activeElement: null,
    body: null,
    createElement(tag) { return createElement(doc, tag); },
    createDocumentFragment() {
      return {
        isFragment: true,
        children: [],
        appendChild(c) { this.children.push(c); return c; },
      };
    },
    getElementById(id) { return doc._byId.get(id) || null; },
    querySelectorAll(selector) { return doc.body.querySelectorAll(selector); },
    querySelector(selector) { return doc.body.querySelector(selector); },
  };
  doc.body = createElement(doc, "body");

  function addEl(tag, id, attrs = {}) {
    const el = doc.createElement(tag);
    if (id) el.id = id;
    Object.entries(attrs).forEach(([k, v]) => {
      if (k === "class") el.className = v;
      else if (k === "checked") el.checked = !!v;
      else if (k === "value") el.value = String(v);
      else if (k === "disabled") el.disabled = !!v;
      else if (k === "hidden") el.hidden = !!v;
      else el.setAttribute(k, v);
    });
    doc.body.appendChild(el);
    return el;
  }

  addEl("input", "charLimit", { value: "16384" });
  addEl("input", "b64url", { checked: true });

  const tabSpecs = [
    ["defs", true],
    ["units", false],
    ["library", false],
    ["decode", false],
    ["utilities", false],
  ];
  tabSpecs.forEach(([name, active]) => {
    const btn = addEl("button", `tab-${name}`, {
      class: active ? "tab active" : "tab",
      "data-tab": name,
      "aria-selected": active ? "true" : "false",
      tabindex: active ? "0" : "-1",
    });
    btn.appendChild(addEl("span", `tab-${name}-count`, { class: "tab-count" }));
    addEl("section", `panel-${name}`, {
      class: active ? "panel active" : "panel",
      hidden: !active,
    });
  });

  [
    "resetAll", "defsAdd", "unitsAdd", "defsPack", "unitsPack",
    "defsClear", "unitsClear", "defsCopyAll", "defsCopyCombined",
    "unitsCopyAll", "unitsCopyCombined", "defsLibReload", "unitsLibReload",
    "libReload", "libEnableAll", "libDisableAll", "libSearchClear",
    "decodeBtn", "utilityEncode", "utilityDecode", "utilityMinify",
    "utilityPrettify", "utilityClear", "utilityUseOutput", "utilityCopy",
  ].forEach((id) => addEl("button", id));

  [
    "defsInputs", "defsPackNotice", "defsSlots",
    "unitsInputs", "unitsPackNotice", "unitsSlots",
    "libDefs", "libUnits",
  ].forEach((id) => addEl("div", id));

  ["defsSlotSummary", "unitsSlotSummary"].forEach((id) => addEl("span", id, { class: "section-pill" }));
  addEl("div", "libStatus", { class: "status-banner" });
  addEl("input", "libSearch", { value: "" });
  addEl("input", "libEnabledOnly", { checked: false });
  ["decodeInput", "utilityInput", "utilityOutput"].forEach((id) => addEl("textarea", id));
  addEl("pre", "decodeOutput");
  addEl("input", "utilityUrlSafe", { checked: false });
  addEl("p", "utilityStatus");
  addEl("div", "toast", { class: "toast", hidden: true });

  const libData = options.libData || {
    defs: [
      { name: "economy/alpha.lua", enabled: true, chars: 19, content: "local a = 1\nreturn a" },
      { name: "scav/beta.lua", enabled: false, chars: 11, content: "local b = 2" },
    ],
    units: [
      { name: "arm/pawns.lua", enabled: true, chars: 26, content: "{ armpw = { maxthisunit = 1 } }" },
    ],
  };

  let fetchCalls = 0;
  let toggleCalls = [];
  const timers = new Map();
  let nextTimerId = 1;

  const libraryApi = {
    isServerMode: () => false,
    fetchLibrary: () => {
      fetchCalls++;
      return Promise.resolve(structuredClone(libData));
    },
    toggle: (kind, name, enabled) => {
      toggleCalls.push({ kind, name, enabled });
      return Promise.resolve({ ok: true, status: 200 });
    },
    fetchVersion: () => Promise.resolve({ version: "static" }),
  };

  const sandbox = {
    BARAppPure: pure,
    BARLibraryApi: libraryApi,
    document: doc,
    window: {},
    navigator: {},
    localStorage: {
      getItem: (k) => (storageMap.has(k) ? storageMap.get(k) : null),
      setItem: (k, v) => storageMap.set(k, String(v)),
    },
    setTimeout(fn) {
      const id = nextTimerId++;
      timers.set(id, fn);
      return id;
    },
    clearTimeout(id) {
      timers.delete(id);
    },
    globalThis: null,
  };
  sandbox.globalThis = sandbox;
  sandbox.window = sandbox;

  const appSource = fs.readFileSync(path.join(__dirname, "..", "app.js"), "utf8");
  vm.createContext(sandbox);
  vm.runInContext(appSource, sandbox, { filename: "app.js" });

  return {
    doc,
    sandbox,
    storageMap,
    getFetchCalls: () => fetchCalls,
    getToggleCalls: () => toggleCalls,
    flushTimers: () => {
      for (const [id, fn] of Array.from(timers.entries())) {
        timers.delete(id);
        fn();
      }
    },
  };
}

test("UI boots with collapsed library snippets, collapsed empty slots, and live tab counts", async () => {
  const app = mountApp();
  await Promise.resolve();

  const locked = app.doc.getElementById("defsInputs").querySelectorAll(".snippet").filter((el) => el.classList.contains("locked"));
  assert.equal(locked.length, 1);
  assert.equal(locked[0].classList.contains("is-collapsed"), true);
  const lockedTextarea = locked[0].querySelector("textarea");
  assert.equal(lockedTextarea.hidden, true);
  assert.equal(lockedTextarea.style.display, "none");

  assert.equal(app.doc.getElementById("tab-defs-count").textContent, "1/30");
  assert.equal(app.doc.getElementById("tab-units-count").textContent, "1/30");
  assert.equal(app.doc.getElementById("tab-library-count").textContent, "2 on");

  const defsSlots = app.doc.getElementById("defsSlots");
  const allSlotCards = defsSlots.querySelectorAll(".slot");
  assert.equal(allSlotCards.length, 30);
  const emptyDetails = defsSlots.querySelector(".empty-slots-group");
  assert.ok(emptyDetails);
  assert.equal(emptyDetails.open, false);
  assert.equal(emptyDetails.querySelectorAll(".slot").length, 29);
});

test("UI surfaces autoPack errors above slots and preserves expanded command previews", async () => {
  const app = mountApp();
  await Promise.resolve();

  const slotZero = app.doc.getElementById("defsSlots").querySelector(".slot");
  const showCmdBtn = slotZero.querySelectorAll("button")[0];
  showCmdBtn.onclick();
  assert.equal(app.doc.getElementById("command-tweakdefs-0").style.display, "block");

  const manualBox = app.doc.getElementById("defsInputs").querySelectorAll(".snippet").find((el) => !el.classList.contains("locked"));
  const ta = manualBox.querySelector("textarea");
  ta.value = 'local broken = "unterminated';
  ta.oninput();
  app.flushTimers();

  assert.equal(app.doc.getElementById("command-tweakdefs-0").style.display, "block", "re-render should keep command preview open");

  app.doc.getElementById("defsPack").onclick();
  const noticeHost = app.doc.getElementById("defsPackNotice");
  assert.equal(noticeHost.querySelectorAll(".pack-notice").length, 1);
  assert.match(noticeHost.textContent, /Auto-pack not applied/);
});

test("UI quick actions format Lua, load examples, and restore persisted editor drafts", async () => {
  const storageMap = new Map();
  const app = mountApp({ storageMap });
  await Promise.resolve();

  const manualBox = app.doc.getElementById("defsInputs").querySelectorAll(".snippet").find((el) => !el.classList.contains("locked"));
  const buttons = manualBox.querySelectorAll("button");
  const prettifyBtn = buttons.find((b) => b.textContent === "Prettify");
  const exampleBtn = buttons.find((b) => b.textContent === "Load example");
  const ta = manualBox.querySelector("textarea");

  exampleBtn.onclick();
  assert.match(ta.value, /UnitDefs/);

  ta.value = "for k,v in pairs(UnitDefs) do v.metalcost=1 end";
  ta.oninput();
  prettifyBtn.onclick();
  assert.ok(ta.value.includes("\n"), "Prettify should format single-line Lua into multi-line indented code");

  const charLimit = app.doc.getElementById("charLimit");
  charLimit.value = "12000";
  charLimit.oninput();

  const b64url = app.doc.getElementById("b64url");
  b64url.checked = false;
  b64url.onchange();

  const rebooted = mountApp({ storageMap });
  await Promise.resolve();
  assert.equal(rebooted.doc.getElementById("charLimit").value, "12000");
  assert.equal(rebooted.doc.getElementById("b64url").checked, false);
  const restoredTa = rebooted.doc.getElementById("defsInputs").querySelectorAll(".snippet").find((el) => !el.classList.contains("locked")).querySelector("textarea");
  assert.equal(restoredTa.value, ta.value);
});

test("Library tab toggles optimistically without refetching and filters enabled items", async () => {
  const app = mountApp();
  await Promise.resolve();
  const initialFetches = app.getFetchCalls();

  const libTab = app.doc.getElementById("tab-library");
  libTab.onclick();
  assert.equal(libTab.getAttribute("aria-selected"), "true");
  assert.equal(app.doc.getElementById("panel-library").hidden, false);

  const libDefs = app.doc.getElementById("libDefs");
  assert.equal(libDefs.querySelectorAll(".slot").length, 2);

  const enabledOnly = app.doc.getElementById("libEnabledOnly");
  enabledOnly.checked = true;
  enabledOnly.onchange();
  assert.equal(libDefs.querySelectorAll(".slot").length, 1);

  const cb = libDefs.querySelector("input");
  cb.checked = false;
  cb.onchange();
  await new Promise((resolve) => setImmediate(resolve));

  assert.equal(app.getFetchCalls(), initialFetches, "optimistic toggle should not re-fetch the full library");
  assert.equal(app.getToggleCalls().length, 1);
  assert.equal(app.doc.getElementById("tab-library-count").textContent, "1 on");
  assert.equal(libDefs.querySelectorAll("input").length, 0);
  assert.match(libDefs.textContent, /No enabled filenames match your filter/);

  let prevented = false;
  app.doc.getElementById("tab-defs").onkeydown({ key: "ArrowRight", preventDefault: () => { prevented = true; } });
  assert.equal(prevented, true);
  assert.equal(app.doc.getElementById("tab-units").getAttribute("aria-selected"), "true");
});
