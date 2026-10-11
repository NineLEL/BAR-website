"use strict";

const fs = require("fs");
const path = require("path");

const SITE_FILES = ["index.html", "styles.css", "app-pure.js", "app-library.js", "app.js"];

function luaFiles(dir, prefix) {
  let entries;
  try {
    entries = fs.readdirSync(dir, { withFileTypes: true });
  } catch (error) {
    if (error.code === "ENOENT") return [];
    throw error;
  }
  const files = [];
  entries.sort((a, b) => a.name < b.name ? -1 : a.name > b.name ? 1 : 0);
  for (const entry of entries) {
    const relative = prefix ? prefix + "/" + entry.name : entry.name;
    const fullPath = path.join(dir, entry.name);
    if (entry.isDirectory()) files.push.apply(files, luaFiles(fullPath, relative));
    else if (entry.isFile() && entry.name.toLowerCase().endsWith(".lua")) files.push(relative);
  }
  return files;
}

function buildPages(root, outputDir) {
  const tweaksDir = path.join(root, "tweaks");
  const defaultsPath = path.join(tweaksDir, "state.defaults.json");
  const state = JSON.parse(fs.readFileSync(defaultsPath, "utf8"));
  const library = { defs: [], units: [] };

  for (const kind of ["defs", "units"]) {
    for (const name of luaFiles(path.join(tweaksDir, kind), "")) {
      const content = fs.readFileSync(path.join(tweaksDir, kind, ...name.split("/")), "utf8");
      library[kind].push({ name, enabled: state[kind + "/" + name] !== false, chars: content.length, content });
    }
  }

  fs.mkdirSync(outputDir, { recursive: true });
  for (const file of SITE_FILES) fs.copyFileSync(path.join(root, file), path.join(outputDir, file));
  fs.writeFileSync(path.join(outputDir, "library.json"), JSON.stringify(library) + "\n");
  return library;
}

if (require.main === module) {
  const root = path.resolve(__dirname, "..");
  const outputDir = path.resolve(root, process.argv[2] || "dist");
  buildPages(root, outputDir);
  console.log("Built GitHub Pages site at " + path.relative(root, outputDir));
}

module.exports = { buildPages };
