"use strict";

/* Compatibility adapter for older data-contract tests and the existing
 * package syntax-check command. Pure functions are imported directly; no
 * source extraction or VM evaluation occurs. */
const pure = require("../../app-pure");
function loadPure() { return pure; }
module.exports = { loadPure, PURE_FNS: Object.keys(pure).filter((name) => typeof pure[name] === "function") };
