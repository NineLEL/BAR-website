"use strict";

const { spawnSync } = require("node:child_process");
const FULL_SUITE = [];
const TESTS = {
  pure: "tests/pure.test.js",
  client: "tests/library-client.test.js",
  server: "tests/server.test.js",
  pages: "tests/pages-build.test.js",
  tweakPages: "tests/pages-build.test.js",
  tweakDefaults: "tests/default-enabled.test.js",
  tweakSources: "tests/tweak-srcs.test.js",
  scavxHardening: "tests/scavx-hardening.test.js",
  raptorMinibosses: "tests/raptor-minibosses.test.js"
};

function runGit(args, cwd) {
  const result = spawnSync("git", args, { cwd, encoding: "utf8" });
  if (result.error) throw new Error(`Unable to run git: ${result.error.message}`);
  if (result.status !== 0) {
    const detail = (result.stderr || result.stdout || "").trim();
    throw new Error(detail || `git ${args.join(" ")} failed with exit code ${result.status}`);
  }
  return result.stdout;
}

function normalizePath(file) {
  return file.replace(/\\/g, "/").replace(/^\.\//, "");
}

function resolveChangedPaths(baseRef, cwd) {
  if (!baseRef || !baseRef.trim()) throw new Error("No diff base specified. Pass --base <ref> or set TEST_BASE_REF.");
  const base = baseRef.trim();
  // Verify the ref exists before diffing to produce a useful error for bad bases.
  try {
    runGit(["rev-parse", "--verify", `${base}^{commit}`], cwd);
  } catch (error) {
    throw new Error(`Invalid diff base '${base}'. Specify a valid commit/ref with --base <ref> or TEST_BASE_REF. ${error.message}`);
  }
  const committed = runGit(["diff", "--name-only", "--diff-filter=ACMRD", `${base}...HEAD`], cwd);
  const workingTree = runGit(["diff", "--name-only", "--diff-filter=ACMRD", "HEAD"], cwd);
  const untracked = runGit(["ls-files", "--others", "--exclude-standard"], cwd);
  return Array.from(new Set([committed, workingTree, untracked]
    .flatMap((output) => output.split(/\r?\n/).filter(Boolean))
    .map(normalizePath)));
}

function resolveTestFiles(changedPaths) {
  const paths = changedPaths.map(normalizePath);
  if (paths.some((file) => file.startsWith("tests/") || file === "package.json" || file === "scripts/run-changed-tests.js" || file.startsWith("tests/helpers/") || file.startsWith("fixtures/"))) return FULL_SUITE;

  const selected = new Set();
  const add = (...files) => files.forEach((file) => selected.add(file));
  for (const file of paths) {
    if (file === "app-pure.js") add(TESTS.pure);
    else if (file === "app-library.js") add(TESTS.client);
    else if (file === "server.js") add(TESTS.server);
    else if (file === "scripts/build-pages.js") add(TESTS.pages, TESTS.pure, TESTS.client);
    else if (["index.html", "styles.css", "app.js"].includes(file)) add(TESTS.pages, TESTS.pure, TESTS.client);
    else if (file === "tweaks/state.defaults.json" || file === "tweaks/state.json") add(TESTS.tweakDefaults, TESTS.tweakPages);
    else if (file.endsWith("raptorx-miniboss-specialists.lua")) add(TESTS.raptorMinibosses, TESTS.tweakPages);
    else if (file.endsWith("scavx-unit-hardening.lua")) add(TESTS.scavxHardening, TESTS.tweakPages);
    else if (file.startsWith("tweaks/defs/")) add(TESTS.tweakPages);
    else if (file.startsWith("tweaks/")) add(TESTS.tweakPages);
    else return FULL_SUITE;
  }
  return selected.size ? Array.from(selected) : FULL_SUITE;
}

function parseArgs(args) {
  let base;
  let all = false;
  for (let i = 0; i < args.length; i++) {
    if (args[i] === "--all") all = true;
    else if (args[i] === "--base") {
      if (!args[i + 1] || args[i + 1].startsWith("--")) throw new Error("--base requires a ref, for example --base origin/main");
      base = args[++i];
    } else throw new Error(`Unknown argument '${args[i]}'. Use --base <ref> or --all.`);
  }
  return { base: base || process.env.TEST_BASE_REF, all };
}

function defaultBase(cwd) {
  try {
    const upstream = runGit(["symbolic-ref", "--quiet", "--short", "refs/remotes/origin/HEAD"], cwd).trim();
    if (upstream) return upstream;
  } catch (_) { /* use conventional origin branches below */ }
  for (const candidate of ["origin/main", "origin/master"]) {
    try {
      runGit(["rev-parse", "--verify", `${candidate}^{commit}`], cwd);
      return candidate;
    } catch (_) { /* try next */ }
  }
  throw new Error("Unable to determine a diff base: origin/HEAD, origin/main, and origin/master are unavailable. Fetch a remote branch or pass --base <ref>.");
}

function main() {
  const cwd = process.cwd();
  try {
    const options = parseArgs(process.argv.slice(2));
    let files;
    if (options.all) files = FULL_SUITE;
    else {
      const base = options.base || defaultBase(cwd);
      const changed = resolveChangedPaths(base, cwd);
      if (!changed.length) throw new Error(`No changed files found against '${base}'. Use --all to run the full suite.`);
      files = resolveTestFiles(changed);
    }
    const result = spawnSync(process.execPath, ["--test", ...files], { cwd, stdio: "inherit" });
    if (result.error) throw new Error(`Unable to start tests: ${result.error.message}`);
    process.exitCode = result.status === null ? 1 : result.status;
  } catch (error) {
    console.error(`test-changed: ${error.message}`);
    process.exitCode = 1;
  }
}

module.exports = { resolveTestFiles, resolveChangedPaths };

if (require.main === module) main();
