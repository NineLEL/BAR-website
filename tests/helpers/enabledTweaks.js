"use strict";

const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");

const root = path.join(__dirname, "..", "..");
const defaultEnabled = require("../fixtures/default-enabled-tweaks.json");

function assertDefaultEnabled(relative) {
  assert.equal(defaultEnabled[relative], true,
    `${relative}: expected enabled in the test-owned default profile`);
  const file = path.join(root, "tweaks", ...relative.split("/"));
  assert.ok(fs.existsSync(file), `${relative}: default-enabled manifest references a missing tweak`);
}

module.exports = { assertDefaultEnabled, defaultEnabled };
