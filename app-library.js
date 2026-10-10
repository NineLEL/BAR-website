"use strict";

/* Network boundary for the optional local tweak library. UI rendering and
 * status messaging remain in app.js; this module owns only HTTP requests. */
(function (root, createApi) {
  var api = createApi();
  if (typeof module === "object" && module.exports) module.exports = api;
  else root.BARLibraryApi = api;
})(typeof globalThis !== "undefined" ? globalThis : this, function () {
  function fetchLibrary() {
    return fetch("api/tweaks?_=" + Date.now(), { cache: "no-store" }).then(function (response) {
      if (!response.ok) throw new Error("HTTP " + response.status);
      return response.json();
    });
  }

  function toggle(kind, name, enabled) {
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
    return fetch("api/tweaks/version?_=" + Date.now(), { cache: "no-store" }).then(function (response) {
      if (!response.ok) throw new Error("HTTP " + response.status);
      return response.json();
    });
  }

  return {
    fetchLibrary: fetchLibrary,
    toggle: toggle,
    toggleAll: toggleAll,
    fetchVersion: fetchVersion
  };
});
