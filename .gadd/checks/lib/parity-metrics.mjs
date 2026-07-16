#!/usr/bin/env node
// parity-metrics.mjs — zero-dependency (node: built-ins only) measurement engine for
// upstream ratchet metric parity (docs/metric-parity.md). Invoked with the repo root
// as cwd. Prints exactly one JSON object to stdout. Writes nothing to disk.
//
// Contract:
//   - no src/ dir            -> {"available": false, "reason": "no src"} , exit 0
//   - otherwise               -> {available:true, gating:{...}, trend:{...}} , exit 0
//   - a configured-but-unavailable tool (eslint/tsc not installed/resolvable) reports
//     its metric(s) as null — never fabricated as 0. Gating on that null is a decision
//     made by the caller (10-ratchet-parity.sh), not by this engine.
//
// Not copied from any reference implementation; independently written to the metric
// definitions in docs/metric-parity.md.

import { spawnSync } from "node:child_process";
import { readFileSync, readdirSync, existsSync } from "node:fs";
import { join, relative, sep } from "node:path";

const ROOT = process.cwd();
const SRC_DIR = join(ROOT, "src");

const DEFAULT_CEILINGS = { tsx: 300, ts: 200 };

function loadParityConfig() {
  const p = join(ROOT, "gadd", "BASELINE.json");
  if (!existsSync(p)) return {};
  try {
    const data = JSON.parse(readFileSync(p, "utf8"));
    return (data && typeof data === "object" && data.parity && typeof data.parity === "object")
      ? data.parity
      : {};
  } catch {
    return {};
  }
}

function toolAvailable(bin) {
  return existsSync(join(ROOT, "node_modules", ".bin", bin));
}

function resolveTsconfig() {
  if (existsSync(join(ROOT, "tsconfig.app.json"))) return "tsconfig.app.json";
  if (existsSync(join(ROOT, "tsconfig.json"))) return "tsconfig.json";
  return null;
}

// --- source set --------------------------------------------------------------------

function isExempt(relPath, exemptPrefixes) {
  if (relPath.endsWith(".d.ts")) return true;
  // Match on segment boundary: exempt "src/legacy" must cover src/legacy/** and the
  // exact path itself, but never a sibling like src/legacy_v2/ that merely shares the
  // string prefix.
  return exemptPrefixes.some(
    (prefix) =>
      relPath === prefix ||
      relPath.startsWith(prefix.endsWith("/") ? prefix : prefix + "/"),
  );
}

function sourceFiles(exemptPrefixes) {
  const out = [];
  const walk = (dir) => {
    let entries;
    try {
      entries = readdirSync(dir, { withFileTypes: true });
    } catch {
      return;
    }
    for (const entry of entries) {
      const p = join(dir, entry.name);
      if (entry.isDirectory()) {
        walk(p);
      } else if (entry.isFile() && /\.(ts|tsx)$/.test(entry.name)) {
        const rel = relative(ROOT, p).split(sep).join("/");
        if (!isExempt(rel, exemptPrefixes)) out.push(rel);
      }
    }
  };
  walk(SRC_DIR);
  return out.sort();
}

// --- gating: eslint / tsc (tool-dependent, null when unavailable) ------------------

function eslintCounts() {
  if (!toolAvailable("eslint")) return { errors: null, warnings: null };
  const res = spawnSync("npx", ["--no-install", "eslint", ".", "--format", "json"], {
    cwd: ROOT,
    encoding: "utf8",
    maxBuffer: 64 * 1024 * 1024,
  });
  const out = res.stdout || "";
  const start = out.indexOf("[");
  if (start === -1) return { errors: null, warnings: null };
  try {
    const results = JSON.parse(out.slice(start));
    if (!Array.isArray(results)) return { errors: null, warnings: null };
    let errors = 0;
    let warnings = 0;
    for (const r of results) {
      errors += r.errorCount || 0;
      warnings += r.warningCount || 0;
    }
    return { errors, warnings };
  } catch {
    return { errors: null, warnings: null };
  }
}

function tscErrorCount(tsconfigPath, strict) {
  if (!toolAvailable("tsc") || !tsconfigPath) return null;
  const args = ["--no-install", "tsc", "-p", tsconfigPath, "--noEmit"];
  if (strict) args.push("--strict");
  const res = spawnSync("npx", args, {
    cwd: ROOT,
    encoding: "utf8",
    maxBuffer: 64 * 1024 * 1024,
  });
  // A tsc that failed to run at all (spawn error, or terminated without an exit
  // status — e.g. a stale node_modules/.bin/tsc symlink or npx resolution failure)
  // produces empty output that the regex would falsely match to 0. Report null so
  // the caller gates it as unmeasurable rather than fabricating a clean zero.
  if (res.error || res.status === null) return null;
  const combined = (res.stdout || "") + (res.stderr || "");
  const matches = combined.match(/error TS\d+/g);
  // A tsc that ran but CRASHED (non-zero exit with zero parsed `error TS` diagnostics,
  // e.g. a stack trace) is unmeasurable, never a clean zero. A non-zero exit WITH
  // parsed diagnostics is the normal type-error path and reports the count.
  if (res.status !== 0 && !matches) return null;
  return matches ? matches.length : 0;
}

// --- gating: pure-scan metrics (no external tooling required) ----------------------

const ANY_PATTERN = /(:\s*any\b|<any>|\bas any\b|\bany\[\])/g;
const DISABLE_PATTERN = /eslint-disable/g;
const TRIVIAL_LINE = /^(import |\/\/|\/?\*|[}\])];,]*$)/;

function ceilingFor(relPath, ceilings) {
  const isTsxOrHook = /\.tsx$/.test(relPath) || relPath.startsWith("src/hooks/");
  return isTsxOrHook ? ceilings.tsx : ceilings.ts;
}

function scanCounts(files, ceilings) {
  let anyCount = 0;
  let disables = 0;
  let oversized = 0;
  const windowCounts = new Map();

  for (const f of files) {
    let text;
    try {
      text = readFileSync(join(ROOT, f), "utf8");
    } catch {
      continue;
    }
    const lines = text.split("\n");

    anyCount += (text.match(ANY_PATTERN) || []).length;
    disables += (text.match(DISABLE_PATTERN) || []).length;

    if (lines.length > ceilingFor(f, ceilings)) oversized++;

    const normalized = lines
      .map((l) => l.trim())
      .filter((l) => l.length > 3 && !TRIVIAL_LINE.test(l));
    for (let i = 0; i + 6 <= normalized.length; i++) {
      const key = normalized.slice(i, i + 6).join(" ");
      windowCounts.set(key, (windowCounts.get(key) || 0) + 1);
    }
  }

  let duplicateWindows = 0;
  for (const n of windowCounts.values()) {
    if (n > 1) duplicateWindows += n - 1;
  }

  return { anyCount, disables, oversized, duplicateWindows };
}

// --- main ----------------------------------------------------------------------------

function main() {
  if (!existsSync(SRC_DIR)) {
    process.stdout.write(JSON.stringify({ available: false, reason: "no src" }) + "\n");
    process.exit(0);
  }

  const parityConfig = loadParityConfig();
  const exemptPrefixes = Array.isArray(parityConfig.exempt) ? parityConfig.exempt : [];
  const ceilings = {
    tsx: Number.isInteger(parityConfig.ceilings?.tsx) ? parityConfig.ceilings.tsx : DEFAULT_CEILINGS.tsx,
    ts: Number.isInteger(parityConfig.ceilings?.ts) ? parityConfig.ceilings.ts : DEFAULT_CEILINGS.ts,
  };

  const files = sourceFiles(exemptPrefixes);
  const lint = eslintCounts();
  const scan = scanCounts(files, ceilings);
  const tsconfigPath = resolveTsconfig();

  const result = {
    available: true,
    gating: {
      eslint_errors: lint.errors,
      eslint_warnings: lint.warnings,
      tsc_errors: tscErrorCount(tsconfigPath, false),
      any_count: scan.anyCount,
      eslint_disables: scan.disables,
      oversized_files: scan.oversized,
      duplicate_windows: scan.duplicateWindows,
    },
    trend: {
      tsc_strict_errors: tscErrorCount(tsconfigPath, true),
      test_files: files.filter((f) => /\.(test|spec)\.tsx?$/.test(f)).length,
      source_file_count: files.length,
    },
  };

  process.stdout.write(JSON.stringify(result) + "\n");
  process.exit(0);
}

main();
