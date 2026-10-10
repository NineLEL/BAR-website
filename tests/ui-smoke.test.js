"use strict";

const { test } = require("node:test");
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");

const html = fs.readFileSync(path.join(__dirname, "..", "index.html"), "utf8");

function elementsById(source) {
  const elements = new Map();
  const allElements = [];
  // This smoke test deliberately supports static HTML only: comments, quoted
  // attributes (single/double quotes), and ordinary start/end tags. Fail on
  // malformed or unsupported tag syntax rather than silently skipping it.
  let index = 0;
  while (index < source.length) {
    const opening = source.indexOf("<", index);
    if (opening < 0) break;
    if (source.startsWith("<!--", opening)) {
      const endComment = source.indexOf("-->", opening + 4);
      assert.notEqual(endComment, -1, "unterminated HTML comment");
      index = endComment + 3;
      continue;
    }
    const end = scanTagEnd(source, opening);
    const raw = source.slice(opening + 1, end);
    index = end + 1;
    if (/^\s*\//.test(raw) || /^\s*!/.test(raw) || /^\s*\?/.test(raw)) continue;
    const parsed = parseStartTag(raw);
    if (!parsed) continue;
    const { tag, attrs } = parsed;
    const element = { tag, attrs };
    allElements.push(element);
    if (attrs.has("id")) {
      const id = attrs.get("id");
      assert.ok(!elements.has(id), `duplicate id #${id}`);
      elements.set(id, element);
    }
  }
  elements.allElements = allElements;
  return elements;
}

function scanTagEnd(source, start) {
  let quote = null;
  for (let i = start + 1; i < source.length; i++) {
    const char = source[i];
    if (quote) {
      if (char === quote) quote = null;
    } else if (char === '"' || char === "'") quote = char;
    else if (char === ">") return i;
  }
  assert.fail(`unsupported or unterminated tag beginning at offset ${start}`);
}

function parseStartTag(raw) {
  const head = raw.match(/^\s*([a-z][\w:-]*)(?=\s|\/|$)/i);
  if (!head) assert.fail(`unsupported start tag: <${raw.slice(0, 80)}>`);
  const tag = head[1].toLowerCase();
  const attrs = new Map();
  let rest = raw.slice(head[0].length);
  while (rest.trim()) {
    rest = rest.replace(/^\s+/, "");
    if (rest === "/") break;
    const attr = rest.match(/^([a-z_:][\w:.-]*)(?:\s*=\s*(?:"([^"]*)"|'([^']*)'|([^\s/>]+)))?/i);
    if (!attr) assert.fail(`unsupported attribute syntax in <${raw}>`);
    const name = attr[1].toLowerCase();
    assert.ok(!attrs.has(name), `duplicate attribute ${name} in <${raw}>`);
    attrs.set(name, attr[2] ?? attr[3] ?? attr[4] ?? "");
    rest = rest.slice(attr[0].length);
  }
  return { tag, attrs };
}

function attr(element, name) { return element.attrs.get(name.toLowerCase()); }
function hasAccessibleName(element) {
  if (attr(element, "aria-label")?.trim()) return true;
  const labelledBy = attr(element, "aria-labelledby")?.trim();
  if (labelledBy && labelledBy.split(/\s+/).every((id) => elements.has(id))) return true;
  const id = attr(element, "id");
  return elements.allElements.some((candidate) =>
    candidate.tag === "label" && attr(candidate, "for") === id && candidate.labelText?.trim());
}
function assertActionable(id, tags, { enabled = false } = {}) {
  const element = elements.get(id);
  assert.ok(element, `missing control #${id}`);
  assert.ok(tags.includes(element.tag), `#${id} must be ${tags.join("/")}, not <${element.tag}>`);
  if (enabled) assert.equal(element.attrs.has("disabled"), false, `#${id} must be enabled`);
}

const elements = elementsById(html);

// Retain label text for explicit <label for="..."> associations.
for (const match of html.matchAll(/<label\b([^>]*)>([\s\S]*?)<\/label\s*>/gi)) {
  const parsed = parseStartTag(`label ${match[1]}`);
  const label = elements.allElements.find((element) =>
    element.tag === "label" && attr(element, "for") === parsed.attrs.get("for"));
  if (label) label.labelText = match[2].replace(/<[^>]*>/g, "").trim();
}

test("JavaScript-hooked UI elements keep their stable IDs", () => {
  const ids = [
    "charLimit", "b64url", "toast",
    "defsInputs", "defsSlots", "unitsInputs", "unitsSlots",
    "libStatus", "libSearch", "libSearchClear", "libReload", "libEnableAll",
    "libDisableAll", "libDefs", "libUnits",
    "decodeInput", "decodeBtn", "decodeOutput",
    "utilityInput", "utilityOutput", "utilityStatus", "utilityUrlSafe",
  ];
  const controls = {
    charLimit: ["input"], b64url: ["input"], toast: ["div"],
    defsInputs: ["div"], defsSlots: ["div"], unitsInputs: ["div"], unitsSlots: ["div"],
    libStatus: ["div"], libSearch: ["input"], libSearchClear: ["button"], libReload: ["button"],
    libEnableAll: ["button"], libDisableAll: ["button"], libDefs: ["div"], libUnits: ["div"],
    decodeInput: ["textarea"], decodeBtn: ["button"], decodeOutput: ["pre"],
    utilityInput: ["textarea"], utilityOutput: ["textarea"],
  };
  for (const id of ids) {
    if (controls[id]) assertActionable(id, controls[id]);
    else assert.ok(elements.has(id), `missing JavaScript-hooked #${id}`);
  }
  for (const id of ["libSearchClear", "libReload", "libEnableAll", "libDisableAll", "decodeBtn"])
    assertActionable(id, ["button"], { enabled: true });
});

test("each tab controls an existing panel labelled by that tab", () => {
  const tabs = [...elements].filter(([, element]) => element.tag === "button" && attr(element, "role") === "tab");
  assert.ok(tabs.length > 0, "expected tab controls");

  for (const [id, tab] of tabs) {
    const panelId = attr(tab, "aria-controls");
    assert.ok(id, "every tab must have an ID");
    assert.ok(panelId, `tab #${id} must declare aria-controls`);
    const panel = elements.get(panelId);
    assert.ok(panel, `tab #${id} controls missing #${panelId}`);
    assert.equal(attr(panel, "role"), "tabpanel", `#${panelId} must be a tabpanel`);
    assert.equal(attr(panel, "aria-labelledby"), id, `#${panelId} must be labelled by #${id}`);
    assert.equal(attr(panel, "id"), panelId, `tab #${id} must control the declared panel`);
  }
  for (const [panelId, panel] of elements) {
    if (attr(panel, "role") !== "tabpanel") continue;
    const tabId = attr(panel, "aria-labelledby");
    assert.ok(tabId, `tabpanel #${panelId} must declare aria-labelledby`);
    const tab = elements.get(tabId);
    assert.ok(tab && attr(tab, "role") === "tab", `tabpanel #${panelId} must reference an existing tab`);
    assert.equal(attr(tab, "aria-controls"), panelId, `tab #${tabId} must control #${panelId}`);
  }
});

test("key static inputs have an accessible label association", () => {
  for (const id of ["decodeInput", "b64url", "libSearch"]) {
    const element = elements.get(id);
    assert.ok(element, `missing input #${id}`);
    assert.ok(hasAccessibleName(element),
      `#${id} must have a non-empty label[for], aria-label, or valid aria-labelledby association`);
  }
});

test("tweakdefs and tweakunits retain their core editing, packing, and copy actions", () => {
  for (const id of [
    "defsAdd", "defsPack", "defsCopyAll", "defsCopyCombined", "defsClear", "defsLibReload",
    "unitsAdd", "unitsPack", "unitsCopyAll", "unitsCopyCombined", "unitsClear", "unitsLibReload",
    "resetAll",
  ]) assertActionable(id, ["button"], { enabled: true });
});

test("library, decode, and utility controls remain exposed", () => {
  for (const id of ["libReload", "libSearch", "libSearchClear", "libEnableAll", "libDisableAll",
    "decodeInput", "decodeBtn", "decodeOutput",
    "utilityInput", "utilityOutput", "utilityEncode", "utilityDecode", "utilityMinify",
    "utilityPrettify", "utilityClear", "utilityUseOutput", "utilityCopy"]) {
    assertActionable(id, ["libReload", "libSearchClear", "libEnableAll", "libDisableAll", "decodeBtn",
      "utilityEncode", "utilityDecode", "utilityMinify", "utilityPrettify", "utilityClear", "utilityUseOutput", "utilityCopy"].includes(id)
      ? ["button"] : id === "decodeInput" || id === "utilityInput" || id === "utilityOutput" ? ["textarea"] : ["input", "pre"],
      { enabled: !["utilityCopy"].includes(id) });
  }
});
