"use strict";

const assert = require("node:assert/strict");
const { execFileSync } = require("node:child_process");
const fs = require("node:fs");
const os = require("node:os");
const path = require("node:path");
const test = require("node:test");

const { resolveTestFiles, resolveChangedPaths } = require("../scripts/run-changed-tests.js");

const FULL_SUITE = [];
const pagesRelated = ["tests/pure.test.js", "tests/pages-build.test.js", "tests/library-client.test.js"];
const pagesBuild = ["tests/pages-build.test.js"];
const defaultsAndPages = ["tests/default-enabled.test.js", "tests/pages-build.test.js"];
const raptorAndPages = ["tests/raptor-minibosses.test.js", "tests/pages-build.test.js"];
const scavxAndPages = ["tests/scavx-hardening.test.js", "tests/pages-build.test.js"];

function makeRepo(t) {
  const cwd = fs.mkdtempSync(path.join(os.tmpdir(), "test-changed-"));
  t.after(() => fs.rmSync(cwd, { recursive: true, force: true }));
  const git = (...args) => execFileSync("git", args, { cwd, encoding: "utf8", stdio: ["ignore", "pipe", "pipe"] }).trim();
  git("init", "-q");
  git("config", "user.email", "test@example.invalid");
  git("config", "user.name", "Test User");
  return {
    cwd,
    git,
    write(file, content) {
      const target = path.join(cwd, file);
      fs.mkdirSync(path.dirname(target), { recursive: true });
      fs.writeFileSync(target, content);
    },
    commit(message) {
      git("add", "-A");
      git("commit", "-qm", message);
      return git("rev-parse", "HEAD");
    }
  };
}

test("maps small pure, client, and server edits to their suites", () => {
  assert.deepEqual(resolveTestFiles(["app-pure.js"]), ["tests/pure.test.js"]);
  assert.deepEqual(resolveTestFiles(["app-library.js"]), ["tests/library-client.test.js"]);
  assert.deepEqual(resolveTestFiles(["server.js"]), ["tests/server.test.js"]);
});

test("generic tweak Lua outside defs selects pages build only", () => {
  assert.deepEqual(resolveTestFiles(["tweaks/example/config.lua"]), pagesBuild);
  assert.deepEqual(resolveTestFiles(["tweaks/defs/example.lua"]), pagesBuild);
});

test("state defaults and local changes select default-enabled and pages build", () => {
  assert.deepEqual(resolveTestFiles(["tweaks/state.defaults.json"]), defaultsAndPages);
  assert.deepEqual(resolveTestFiles(["tweaks/state.json"]), defaultsAndPages);
});

test("raptor miniboss tweak selects raptor-specific and pages build", () => {
  assert.deepEqual(resolveTestFiles(["tweaks/raptorx-miniboss-specialists.lua"]), raptorAndPages);
});

test("scavx hardening tweak selects scavx-specific and pages build", () => {
  assert.deepEqual(resolveTestFiles(["tweaks/scavx-unit-hardening.lua"]), scavxAndPages);
});

test("deduplicates related suites for multiple changed files", () => {
  assert.deepEqual(resolveTestFiles(["app-pure.js", "app.js", "index.html", "app-pure.js"]), pagesRelated);
});

test("test infrastructure and unknown paths request the full suite", () => {
  for (const file of ["tests/pure.test.js", "tests/helpers/factory.js", "fixtures/data.json", "package.json", "scripts/run-changed-tests.js", "README.md"]) {
    assert.deepEqual(resolveTestFiles([file]), FULL_SUITE, file);
  }
  assert.deepEqual(resolveTestFiles([]), FULL_SUITE);
});

test("normalizes Windows separators before selecting suites", () => {
  assert.deepEqual(resolveTestFiles([".\\app-pure.js"]), ["tests/pure.test.js"]);
});

test("resolves additions, modifications, and renames from a temporary git diff", (t) => {
  const repo = makeRepo(t);
  repo.write("base.txt", "initial\n");
  repo.write("rename-old.js", "same content\n");
  const base = repo.commit("base");

  repo.write("app-pure.js", "added\n");
  repo.write("base.txt", "modified\n");
  repo.git("mv", "rename-old.js", "rename-new.js");
  repo.commit("changes");

  assert.deepEqual(resolveChangedPaths(base, repo.cwd), ["app-pure.js", "base.txt", "rename-new.js"]);
});

test("includes staged, unstaged tracked, untracked, and deleted paths relative to base", (t) => {
  const repo = makeRepo(t);
  repo.write("staged.txt", "original\n");
  repo.write("unstaged.txt", "original\n");
  repo.write("deleted.txt", "original\n");
  const base = repo.commit("base");

  repo.write("staged.txt", "staged change\n");
  repo.git("add", "staged.txt");
  repo.write("unstaged.txt", "unstaged change\n");
  fs.rmSync(path.join(repo.cwd, "deleted.txt"));
  repo.write("untracked.txt", "new file\n");

  assert.deepEqual(
    resolveChangedPaths(base, repo.cwd).sort(),
    ["deleted.txt", "staged.txt", "unstaged.txt", "untracked.txt"]
  );
});

test("invalid base and empty diff have explicit behavior", (t) => {
  const repo = makeRepo(t);
  repo.write("base.txt", "initial\n");
  const base = repo.commit("base");

  assert.throws(() => resolveChangedPaths("missing-ref", repo.cwd), /Invalid diff base 'missing-ref'/);
  assert.throws(() => resolveChangedPaths("  ", repo.cwd), /No diff base specified/);
  assert.deepEqual(resolveChangedPaths(base, repo.cwd), []);
});
