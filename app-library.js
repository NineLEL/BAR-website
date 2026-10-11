"use strict";

/* Network boundary for the tweak library. Local runs use the server API;
 * static deployments load a bundled library and keep selections in this browser. */
(function (root, createApi) {
  var api = createApi();
  if (typeof module === "object" && module.exports) module.exports = api;
  else root.BARLibraryApi = api;
})(typeof globalThis !== "undefined" ? globalThis : this, function () {
  var staticLibrary = null;
  var staticStorageKey = "bar-tweak-packer-library-state-v1";

  function storage() {
    try { return typeof globalThis !== "undefined" ? globalThis.localStorage : null; } catch (error) { return null; }
  }

  function applySavedState(data) {
    var saved;
    try { saved = JSON.parse(storage().getItem(staticStorageKey) || "{}"); }
    catch (error) { saved = {}; }
    ["defs", "units"].forEach(function (kind) {
      data[kind].forEach(function (file) {
        var key = kind + "/" + file.name;
        if (Object.prototype.hasOwnProperty.call(saved, key)) file.enabled = saved[key];
      });
    });
    return data;
  }

  function saveStaticState(kind, name, enabled) {
    var store = storage();
    if (!store) return Promise.reject(new Error("Browser storage is unavailable"));
    var saved = {};
    try { saved = JSON.parse(store.getItem(staticStorageKey) || "{}"); } catch (error) {}
    saved[kind + "/" + name] = enabled;
    try { store.setItem(staticStorageKey, JSON.stringify(saved)); }
    catch (error) { return Promise.reject(error); }
    return Promise.resolve({ ok: true, status: 200 });
  }

  function fetchStaticLibrary() {
    return fetch("library.json?_=" + Date.now(), { cache: "no-store" }).then(function (response) {
      if (!response.ok) throw new Error("HTTP " + response.status);
      return response.json();
    }).then(function (data) {
      staticLibrary = applySavedState(data);
      return staticLibrary;
    });
  }

  function fetchLibrary() {
    return fetch("api/tweaks?_=" + Date.now(), { cache: "no-store" }).then(function (response) {
      if (!response.ok) throw new Error("HTTP " + response.status);
      return response.json();
    }).catch(function () {
      return fetchStaticLibrary();
    });
  }

  function toggle(kind, name, enabled) {
    if (staticLibrary) return saveStaticState(kind, name, enabled);
    return fetch("api/tweaks/toggle", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ kind: kind, name: name, enabled: enabled })
    });
  }

  function toggleAll(files, enabled) {
    return Promise.all(files.map(function (file) {
      return toggle(file.kind, file.name, enabled);
    }));
  }

  function fetchVersion() {
    if (staticLibrary) return Promise.resolve({ version: "static" });
    return fetch("api/tweaks/version?_=" + Date.now(), { cache: "no-store" }).then(function (response) {
      if (!response.ok) throw new Error("HTTP " + response.status);
      return response.json();
    });
  }

  return {
    fetchLibrary: fetchLibrary,
    toggle: toggle,
    toggleAll: toggleAll,
    fetchVersion: fetchVersion,
    isServerMode: function () { return !staticLibrary; }
  };
});
