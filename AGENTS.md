## Mandatory Tool Selection and Precedence

Use the following rules for every task. The goal is to use the most specialized available tool, minimize context usage, and avoid unnecessary subprocesses.

1. **CodeGraph first:** If `.codegraph/` exists at the repository root, use `codegraph_explore` when available, or `codegraph explore` through `bash` otherwise, before using grep, glob, or broad file reads to understand or locate code.
2. **Structure before content:** Use `aft_outline` to locate symbols and understand file structure, then `aft_zoom` to inspect specific implementations. Use `read` for content that symbol inspection cannot provide.
3. **Choose the correct search tool:**
   - `aft_search`: semantic or conceptual code discovery.
   - `aft_grep`: use only if this exact tool is registered; otherwise use AFT-backed `grep` for indexed textual searches.
   - `grep`: exact text and regex searches, plus OMP device searches such as `xd://` resources when applicable.
   - `glob`: indexed file and path discovery.
   - `ast_grep_search`: structural searches using AST patterns.
4. **Choose the correct editing tool:**
   - `edit`: targeted modifications to existing files and supported symbol-level edits.
   - `apply_patch`: coordinated multi-file patches with atomic rollback.
   - `ast_grep_replace`: syntax-aware pattern replacements.
   - `aft_refactor`: supported cross-file symbol moves, function extraction, and inlining.
   - `aft_import`: language-aware import management.
   - `write`: creating files or intentionally replacing complete contents.
5. **Use dedicated safety tools:** `aft_safety` for checkpoints and recovery, `aft_conflicts` for Git conflict inspection, `aft_delete` for backed-up deletion, and `aft_move` for backed-up moves. Check that optional tools are enabled before using them.
6. **Diagnostics and debugging:** Prefer `lsp_diagnostics` and `aft_inspect` for supported static diagnostics. Use `debug` when a live DAP session is available and runtime state needs inspection. Use `security_scan` when security analysis is relevant and the tool is registered.
7. **Execution:** Use `bash` for builds, tests, package managers, scripts, and operations without a dedicated tool. Prefer in-process utilities when the harness provides them. Do not use shell commands to duplicate dedicated file, search, editing, or recovery tools.
8. **External repositories:** Use `github` for supported GitHub operations. Use `ghq get` through `bash` only when a repository must be cloned locally for inspection or execution. Do not repeatedly query remote APIs when a local checkout or supported GitHub tool can provide the required information.
9. **Tool availability:** Names in this document describe intended capabilities, not guaranteed availability. Inspect the current tool registry and schemas. Never substitute a similarly named tool without confirming that it exists.
10. **No unnecessary workarounds:** If a dedicated tool can perform the operation, do not implement the same operation using shell commands, custom scripts, or manual text processing. Exceptions are allowed when the dedicated tool cannot handle the resource, operation, or required validation.

<unified_tool_matrix>

To maximize execution speed, maintain workspace integrity, and optimize context token usage, you must select the correct tool for every task. You are strictly prohibited from using raw shell commands or custom scripting when a dedicated tool exists.

---

## 📂 1. Files & Search

| Tool | Primary Purpose | Replaced Anti-pattern (❌ DO NOT USE) |
| :--- | :--- | :--- |
| **`aft_read`** | Loads and summarizes files, directories, archives, SQLite tables, PDFs, notebooks, URLs, and PR paths. | ❌ `cat <file>`, `head`, `tail`, or custom Python reading loops (causes context bloat and lacks automatic token clipping). |
| **`aft_write`** | Atomically creates or overwrites a file or archive entry with auto-backup and formatting. | ❌ `echo "..." > file` or scripting file-writes (lacks diagnostics, validation, and automated rollback). |
| **`aft_patch`** | Applies precise updates using Hashline patches with content-hash anchors and stale-anchor recovery. | ❌ `sed`, `awk`, or writing full-file rewrites to make minor changes (fragile, prone to line-drift and merge conflicts). |
| **`aft_grep`** | Performs trigram-indexed parallel regex searches across files and globs. | ❌ Shell `grep`, `rg`, or nested directory parsing scripts (slow, unindexed, serial). |
| **`grep`** | Use to search OMP devices, like xd://, | using aft_grep or shell grep with :// urls |
| **`glob`** | Instant path and file matching using a persistent, ignore-aware trigram index. | ❌ `find . -name <pattern>` or recursive `ls -R` (triggers slow process-forking and ignores `.gitignore`). |
| **`aft_delete`** | Safely delete one or more files with backup | ❌ Manually using rm |
| **`aft_move`** | Safely move files and directories with backup | ❌ Manually using mv |
| **`aft_safety`** | Use to snapshot and restore files being edited | ❌ Misapplying a patch, garbleing it and having to rewrite it. |

---

## 👁️ 2. Searching for code

| Tool | Primary Purpose | Replaced Anti-pattern (❌ DO NOT USE) |
| :--- | :--- | :--- |
| **`aft_outline`** | Maps all classes, functions, nested members, and line ranges in a file, directory, or URL. | ❌ Manually reading entire source files to extract structure or identify symbol locations. |
| **`aft_zoom`** | Isolates and extracts a specific class, function, or type definition (with optional inline caller annotations). | ❌ Spawning a full file read just to inspect a single sub-component. |
| **`aft_search`** | Semantic and lexical hybrid code search over the indexed workspace. | ❌ Complex keyword-regex scripts when searching for conceptual or logical matches (e.g. searching "database pooling"). |
| **`ast_grep_search`** | Tree sitter grep | ❌ Grepping through code bases |
| **`ast_grep_replace`** | Tree sitter sed | ❌ Execing sed through code bases |
| **`aft_callgraph`** | Traces callers, callees, data flows, and impact paths across symbols. | ❌ Manually executing recursive keyword searches to reconstruct a call tree or dependency hierarchy. |
| **`aft_inspect`** | Generates an on-demand codebase health report (compiler diagnostics, dead code, duplicated exports). | ❌ Manually running standalone linters or compiling files just to catch diagnostic warnings or dead paths. |
| **`github`** | Wrapper for gh | ❌ Manually calling `gh` or `git` |
| **`bash: ghq get`** | One bash exception, using `ghq get` to pull a repo down locally | ❌ Making repeated calls to Github API to look at a repository and getting rate limited |

---

## ✋ 3. Code refactoring beyond the basics

| Tool | Primary Purpose | Replaced Anti-pattern (❌ DO NOT USE) |
| :--- | :--- | :--- |
| **`apply_patch`** | Performs multi-file transaction patches with atomic rollback upon validation failure. | ❌ Writing custom shell or Python scripts to run raw unified diffs (lacks safety gates and rollback capability). |
| **`aft_refactor`** | Executes workspace-wide symbol moves or function extractions, automatically rewriting reference imports. | ❌ Multi-file search-and-replace to rename symbols (breaks imports, re-exports, and relative paths). |
| **`aft_import`** | Language-aware import addition, deletion, and organization. | ❌ Manually editing file import blocks (prone to syntax errors, orphaned variables, and broken dependencies). |
| **`ast_grep`** | Performs structural syntax searches using tree-sitter AST patterns. | ❌ Complex regex queries with variable-spacing assumptions to find nested language blocks. |
| **`ast_edit`** | Previews and applies structural syntax rewrites via AST replacements. | ❌ Running fragile text-based string replacements across variable nested constructs. |
| **`aft_conflicts`** | Show all git conflicts | ❌ Using git CLI |
| **`aft_grep_replace`** | AST aware rpelacement of code paterns | ❌ Using sed |
| **`aft_import`** | Manage code imports | ❌ Using packag managers manually |

---

## ⚙️ 4. Runtime & Intelligence (Oh My Pi! Runtime & Shell)

| Tool | Primary Purpose | Replaced Anti-pattern (❌ DO NOT USE) |
| :--- | :--- | :--- |
| **`bash`** | Spawns execution commands. Uses `pi-builtins` to run **46 core utilities in-process** (no fork/exec overhead). | ❌ Forking standard shell subprocesses to run basic system utils (`sort`, `jq`, `ls`, `grep`). |
| **`eval`** | Runs persistent Python, Julia and JavaScript cells sharing a stateful prelude with loopback tool access. | ❌ running `python -c` or `node` scripts from scratch or doing maths in your head. |
| **`lsp`** | Direct LSP integration for diagnostics, symbol navigation, code actions, and raw server queries. | ❌ Static regex-based jump-to-definition searches or directory-level string renames. |
| **`debug`** | Controls active DAP sessions (breakpoints, stepping, thread inspection, variable state). | ❌ Sprinkling printing commands (`console.log`, `print`) across source files to trace runtime errors or deadlocks. |
| **`security_scan`** | Executes automated security and threat reviews of workspace files. | ❌ Manually scanning file directories looking for vulnerability patterns. |

---

## 💡 Quick Integration Rules

1. **Understand Structure First:** Never read a full source file to locate a definition. Call `aft_outline` to locate symbols, then use `aft_zoom` or `read` on precise line ranges.
2. **Prefer Symbols Over Lines:** Use `edit` or `ast_edit` for precise edits. Avoid full-file writes (`write`) when targeting specific blocks.
3. **Use In-Process Shell Built-ins:** When running scripts via the `bash` tool, rely on the built-in commands. Do not write complex wrapper loops to process text outputs when `pi-builtins` (like `sed`, `xargs`, or `jq`) can execute them directly in-process.
4. **Leverage the Debugger:** If a program fails or crashes, do not add logging statements. Attach `debug` to inspect the live thread stacks and variable heaps directly.
</unified_tool_matrix>

<!-- CODEGRAPH_START -->
## CodeGraph

In repositories indexed by CodeGraph (a `.codegraph/` directory exists at the repo root), reach for it BEFORE grep/find or reading files when you need to understand or locate code:

- **MCP tool** (when available): `codegraph_explore` answers most code questions in one call — the relevant symbols' verbatim source plus the call paths between them, including dynamic-dispatch hops grep can't follow. Name a file or symbol in the query to read its current line-numbered source. If it's listed but deferred, load it by name via tool search.
- **Shell** (always works): `codegraph explore "<symbol names or question>"` prints the same output.

If there is no `.codegraph/` directory, skip CodeGraph entirely — indexing is the user's decision.
<!-- CODEGRAPH_END -->
## Mandatory BAR research requirements

Before making any change involving BAR units, unit definitions, weapons, movement, build options, game mechanics, or engine behavior, you MUST verify the relevant facts against authoritative sources. Do not guess, rely only on memory, or assume a unit or mechanic behaves as its name suggests.

- Inspect the BAR repository and, where engine behavior is involved or BAR does not answer the question, the Recoil Engine and/or Spring Engine repositories.
- For unit definitions, check https://gex.honu.pw/ and, when needed, the full definitions API: https://gex.honu.pw/api/unit/all-defs.
- An offline copy of the full Gex definitions API may be available at `C:\Users\acer\AppData\Local\Temp\opencode\bar-unit-all-defs.json`. When present, use it for targeted lookups if the API is unavailable; the JSON is a large array of records, with unit identifiers in each record's `unit` field. Search only for the needed unit identifiers rather than dumping the full file, and do not treat the copy as authoritative if it may be stale.
- Verify details that affect the change (including unit availability, supported weapon slots, scripts, and behavior) in the source data/code.
- If these sources do not establish the needed facts, stop and ask for clarification rather than inventing details.
- In your final response, briefly identify the sources checked; do not claim verification you did not perform.
