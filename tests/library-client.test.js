"use strict";

const { test } = require("node:test");
const assert = require("node:assert/strict");
const api = require("../app-library");

function stubFetch(t, implementation) {
  const original = global.fetch;
  global.fetch = implementation;
  t.after(() => { global.fetch = original; });
}

test("fetchLibrary requests uncached JSON and returns the parsed payload", async (t) => {
  const payload = { defs: [{ name: "alpha.lua" }], units: [] };
  let request;
  stubFetch(t, async (url, options) => {
    request = { url, options };
    return { ok: true, json: async () => payload };
  });

  assert.deepEqual(await api.fetchLibrary(), payload, "fetchLibrary should return the server's JSON payload");
  assert.match(request.url, /^api\/tweaks\?_=/, "library request should use the versioned endpoint");
  assert.deepEqual(request.options, { cache: "no-store" }, "library request must bypass browser caching");
});

test("fetchLibrary and fetchVersion reject non-success HTTP responses", async (t) => {
  stubFetch(t, async () => ({ ok: false, status: 503 }));

  await assert.rejects(api.fetchLibrary(), /^Error: HTTP 503$/,
    "library fetch should surface the HTTP status instead of parsing an error body");
  await assert.rejects(api.fetchVersion(), /^Error: HTTP 503$/,
    "version fetch should surface the HTTP status instead of parsing an error body");
});

test("toggle sends a JSON POST and returns the response unchanged", async (t) => {
  const response = { ok: false, status: 409 };
  let request;
  stubFetch(t, async (url, options) => {
    request = { url, options };
    return response;
  });

  assert.equal(await api.toggle("defs", "economy/late game.lua", false), response,
    "toggle should let the caller handle the response status");
  assert.equal(request.url, "api/tweaks/toggle");
  assert.equal(request.options.method, "POST");
  assert.equal(request.options.headers["Content-Type"], "application/json");
  assert.deepEqual(JSON.parse(request.options.body), {
    kind: "defs", name: "economy/late game.lua", enabled: false,
  }, "toggle request must preserve the relative name and boolean state");
});

test("toggleAll sends one request per file and rejects a downstream failure", async (t) => {
  const requests = [];
  stubFetch(t, async (url, options) => {
    requests.push(JSON.parse(options.body));
    if (options.body.includes("broken.lua")) throw new Error("offline");
    return { ok: true, status: 200 };
  });

  await assert.rejects(api.toggleAll([
    { kind: "defs", name: "good.lua" },
    { kind: "units", name: "broken.lua" },
  ], true), /offline/, "bulk toggles should not hide a rejected request");
  assert.deepEqual(requests, [
    { kind: "defs", name: "good.lua", enabled: true },
    { kind: "units", name: "broken.lua", enabled: true },
  ], "bulk toggle should attempt each file with the requested boolean");
});

test("fetchVersion requests uncached version JSON", async (t) => {
  let request;
  const payload = { version: "fixture-version" };
  stubFetch(t, async (url, options) => {
    request = { url, options };
    return { ok: true, json: async () => payload };
  });

  assert.deepEqual(await api.fetchVersion(), payload);
  assert.match(request.url, /^api\/tweaks\/version\?_=/);
  assert.deepEqual(request.options, { cache: "no-store" });
});
