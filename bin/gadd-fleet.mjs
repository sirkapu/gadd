#!/usr/bin/env node
// gadd-fleet.mjs — upstream aggregation: escaped-regression ledgers + verdict history
// across every governed repo you point it at. Read-only, deterministic, no network,
// no LLM. Writes NOTHING to disk — stdout carries one JSON object, stderr carries a
// human table. The JSON names private repo paths: it is LOCAL-ONLY, never commit it,
// never paste it into a shared doc/PR. See docs/measurement.md.
//
// ZERO-DEPENDENCY Node (ratified): node built-ins only (fs/path/process/url). This
// replaces the bash+jq substrate, which lost combinatorially to adversary review:
//   - jq -e passes on multi-document streams (exit status follows only the LAST
//     document), so a concatenated "valid doc + garbage doc" file could be admitted
//     and then split into multiple records by a later `jq -s`.
//   - `$(cat file)` (bash command substitution) silently strips NUL bytes and
//     trailing newlines, letting corrupted/binary content masquerade as valid text
//     (or a 1-byte newline-only file masquerade as "empty").
//   - Unreadable verdict dirs / ledger files were WARNed but then treated as "0
//     verdicts" / silently absent — fabricating clean zeros instead of disclosing
//     an anomaly.
// Node's whole-file JSON.parse succeeds-or-throws on the ENTIRE buffer (rejects any
// trailing content after the first value), which kills the multi-doc admission class
// by construction, and this script never uses shell command substitution to read
// file contents — raw bytes are read via fs and decoded once, explicitly.
//
// SCHEMA ADMISSION (ratified 2026-07-14): every verdict file is validated against
// spec/schemas/verdict.schema.json and every ledger line against
// spec/schemas/escaped.schema.json BEFORE aggregation. Only conformant records are
// admitted; every non-conformant record is disclosed per repo under "anomalies"
// (total + by_reason) and WARNed to stderr. A repo whose aggregation of admitted
// records succeeds is status "clean" (counts reflect admitted records only). The
// north_star rolls up escaped_total / accepted_pushes / escaped_rate over CLEAN
// repos only, and lists clean_repos + anomalous_repos.
//
// Usage: bin/gadd-fleet.mjs <governed-repo-path> [<path>...]
//   e.g. bin/gadd-fleet.mjs ~/code/acme-app ~/code/acme-admin

import fs from 'node:fs';
import path from 'node:path';
import process from 'node:process';
import { fileURLToPath } from 'node:url';

const SCRIPT_DIR = path.dirname(fileURLToPath(import.meta.url));

const ANOMALY_REASONS = [
  'unreadable',
  'empty',
  'malformed_json',
  'not_object',
  'schema_nonconformant',
  'aggregation_failed',
  'not_a_file',
];

function usage() {
  process.stderr.write(`usage: ${path.basename(process.argv[1] || 'gadd-fleet.mjs')} <governed-repo-path> [<path>...]\n`);
  process.stderr.write('  aggregates gadd/verdicts/*.json + gadd/ESCAPED.jsonl across governed repos\n');
  process.stderr.write('  output is LOCAL-ONLY (private repo names/paths) — never commit it\n');
}

function warn(msg) {
  process.stderr.write(`WARN: gadd-fleet: ${msg}\n`);
}

function fatal(msg) {
  process.stderr.write(`FATAL: gadd-fleet: ${msg}\n`);
  process.exit(1);
}

// --- schema loading -----------------------------------------------------------
// Schemas resolve relative to this script. If either is missing, exit 1 loudly:
// admission is the whole point — we do not aggregate un-validated records.
const SCHEMAS_DIR = path.join(SCRIPT_DIR, '..', 'spec', 'schemas');
const V_SCHEMA_PATH = path.join(SCHEMAS_DIR, 'verdict.schema.json');
const E_SCHEMA_PATH = path.join(SCHEMAS_DIR, 'escaped.schema.json');

function loadSchema(p, label) {
  if (!fs.existsSync(p) || !fs.statSync(p).isFile()) {
    fatal(`${label} schema missing at ${p} — refusing to run without its whitelist`);
  }
  let raw;
  try {
    raw = fs.readFileSync(p, 'utf8');
  } catch (e) {
    fatal(`${label} schema unreadable at ${p} — refusing to run without its whitelist`);
  }
  try {
    return JSON.parse(raw);
  } catch (e) {
    fatal(`${label} schema at ${p} is not valid JSON — refusing to run without its whitelist`);
  }
}

// --- schema-driven validation (mirrors the jq def used by the bash predecessor) --
function typeOk(v, t) {
  if (t == null) return true;
  switch (t) {
    case 'string': return typeof v === 'string';
    case 'object': return typeof v === 'object' && v !== null && !Array.isArray(v);
    case 'array': return Array.isArray(v);
    case 'number': return typeof v === 'number';
    case 'integer': return typeof v === 'number';
    case 'boolean': return typeof v === 'boolean';
    default: return false;
  }
}

function checkObj(doc, schema) {
  const required = schema.required || [];
  for (const key of required) {
    if (!Object.prototype.hasOwnProperty.call(doc, key)) return false;
  }
  const properties = schema.properties || {};
  for (const [key, propSchema] of Object.entries(properties)) {
    if (Object.prototype.hasOwnProperty.call(doc, key)) {
      if (!typeOk(doc[key], propSchema.type)) return false;
      if (propSchema.enum && !propSchema.enum.includes(doc[key])) return false;
    }
  }
  return true;
}

function isPlainObject(v) {
  return typeof v === 'object' && v !== null && !Array.isArray(v);
}

// validateVerdict: doc is an already-parsed JSON object. Returns true iff it
// conforms to verdict.schema.json — including: findings is an array, and every
// finding is an object meeting findings.items required/enums/types.
function validateVerdict(doc, schema) {
  if (!checkObj(doc, schema)) return false;
  if (!Array.isArray(doc.findings)) return false;
  const itemsSchema = (schema.properties && schema.properties.findings && schema.properties.findings.items) || {};
  for (const finding of doc.findings) {
    if (!isPlainObject(finding)) return false;
    if (!checkObj(finding, itemsSchema)) return false;
  }
  return true;
}

// validateEscaped: doc is an already-parsed JSON object. Returns true iff it
// conforms to escaped.schema.json (required[], property types, severity enum).
function validateEscaped(doc, schema) {
  return checkObj(doc, schema);
}

// mtime -> YYYY-MM-DD (local time, matching the bash predecessor's `stat` default).
function mtimeDate(date) {
  const y = date.getFullYear();
  const m = String(date.getMonth() + 1).padStart(2, '0');
  const d = String(date.getDate()).padStart(2, '0');
  return `${y}-${m}-${d}`;
}

function emptyAnomalies() {
  const by_reason = {};
  for (const r of ANOMALY_REASONS) by_reason[r] = 0;
  return { total: 0, by_reason };
}

function totalAnomalies(by_reason) {
  return ANOMALY_REASONS.reduce((sum, r) => sum + (by_reason[r] || 0), 0);
}

function nullRepoObj(repoArg, by_reason) {
  return {
    path: repoArg,
    status: 'anomalous',
    verdicts_total: null,
    pass_count: null,
    fail_count: null,
    findings: { CRITICAL: null, MAJOR: null, MINOR: null },
    escaped_total: null,
    escaped_by_check: {},
    window: { first: null, last: null },
    anomalies: { total: totalAnomalies(by_reason), by_reason },
  };
}

// --- per-repo processing --------------------------------------------------------
function processRepo(repoArg, vSchema, eSchema) {
  const anomalies = emptyAnomalies();
  const by_reason = anomalies.by_reason;

  // --- verdicts ---
  const verdictsDir = path.join(repoArg, 'gadd', 'verdicts');
  const validVerdicts = [];
  const dates = [];
  let verdictsDirUnreadable = false;

  let dirents = null;
  try {
    dirents = fs.readdirSync(verdictsDir, { withFileTypes: true });
  } catch (e) {
    if (e && e.code === 'ENOENT') {
      warn(`${verdictsDir} missing — treating as 0 verdicts`);
      dirents = [];
    } else {
      warn(`${verdictsDir} not readable — repo marked anomalous, counts null (unreadable)`);
      verdictsDirUnreadable = true;
      by_reason.unreadable += 1;
      dirents = [];
    }
  }

  if (!verdictsDirUnreadable) {
    // shell glob `*.json` (no dotglob): skip dotfiles, only names ending .json
    const candidates = dirents
      .filter((d) => d.name.endsWith('.json') && !d.name.startsWith('.'))
      .sort((a, b) => a.name.localeCompare(b.name));

    for (const dirent of candidates) {
      const f = path.join(verdictsDir, dirent.name);

      if (dirent.isDirectory()) {
        by_reason.not_a_file += 1;
        warn(`${f} is a directory, not a file — anomaly (not_a_file)`);
        continue;
      }

      let buf;
      try {
        buf = fs.readFileSync(f);
      } catch (e) {
        by_reason.unreadable += 1;
        warn(`${f} verdict file unreadable — anomaly (unreadable)`);
        continue;
      }

      if (buf.length === 0) {
        by_reason.empty += 1;
        warn(`${f} verdict file empty — anomaly (empty)`);
        continue;
      }

      const text = buf.toString('utf8');
      let parsed;
      try {
        parsed = JSON.parse(text);
      } catch (e) {
        by_reason.malformed_json += 1;
        warn(`${f} is malformed JSON — anomaly (malformed_json)`);
        continue;
      }

      if (!isPlainObject(parsed)) {
        by_reason.not_object += 1;
        warn(`${f} verdict is not a JSON object — anomaly (not_object)`);
        continue;
      }

      if (!validateVerdict(parsed, vSchema)) {
        by_reason.schema_nonconformant += 1;
        warn(`${f} verdict fails verdict.schema.json — anomaly (schema_nonconformant)`);
        continue;
      }

      // ADMITTED
      validVerdicts.push(parsed);
      try {
        const st = fs.statSync(f);
        dates.push(mtimeDate(st.mtime));
      } catch (e) {
        // mtime unavailable; window simply omits this record's date
      }
    }
  }

  let first = null;
  let last = null;
  if (dates.length > 0) {
    const sorted = [...dates].sort();
    first = sorted[0];
    last = sorted[sorted.length - 1];
  }

  // --- escaped-regression ledger ---
  const ledger = path.join(repoArg, 'gadd', 'ESCAPED.jsonl');
  const validEscaped = [];
  let ledgerUnreadable = false;
  let ledgerBuf = null;

  try {
    ledgerBuf = fs.readFileSync(ledger);
  } catch (e) {
    if (e && e.code === 'ENOENT') {
      warn(`${ledger} missing — escaped counted as 0`);
      ledgerBuf = null;
    } else {
      ledgerUnreadable = true;
      by_reason.unreadable += 1;
      warn(`${ledger} unreadable — anomaly (unreadable), escaped counts unavailable from it`);
      ledgerBuf = null;
    }
  }

  if (ledgerBuf !== null && ledgerBuf.length > 0) {
    const text = ledgerBuf.toString('utf8');
    const lines = text.split('\n');
    for (const rawLine of lines) {
      const line = rawLine.endsWith('\r') ? rawLine.slice(0, -1) : rawLine;
      if (line.length === 0) continue; // blank lines (incl. trailing newline artifact) are not anomalies
      let parsed;
      try {
        parsed = JSON.parse(line);
      } catch (e) {
        by_reason.malformed_json += 1;
        warn(`${ledger} has a malformed JSONL line — anomaly (malformed_json)`);
        continue;
      }
      if (!isPlainObject(parsed)) {
        by_reason.not_object += 1;
        warn(`${ledger} has a non-object JSONL line — anomaly (not_object)`);
        continue;
      }
      if (!validateEscaped(parsed, eSchema)) {
        by_reason.schema_nonconformant += 1;
        warn(`${ledger} has a line failing escaped.schema.json — anomaly (schema_nonconformant)`);
        continue;
      }
      validEscaped.push(parsed);
    }
  }
  // empty (0-byte, existing) ledger file = healthy zero, no anomaly

  // --- aggregate ---
  const status = (verdictsDirUnreadable || ledgerUnreadable) ? 'anomalous' : 'clean';

  if (verdictsDirUnreadable) {
    // ALL numeric counts null — never fabricate zeros for an unreadable dir.
    anomalies.total = totalAnomalies(by_reason);
    return {
      path: repoArg,
      status,
      verdicts_total: null,
      pass_count: null,
      fail_count: null,
      findings: { CRITICAL: null, MAJOR: null, MINOR: null },
      escaped_total: null,
      escaped_by_check: {},
      window: { first: null, last: null },
      anomalies,
    };
  }

  const verdicts_total = validVerdicts.length;
  const pass_count = validVerdicts.filter((v) => v.verdict === 'PASS').length;
  const fail_count = validVerdicts.filter((v) => v.verdict === 'FAIL').length;
  const findingsAll = validVerdicts.flatMap((v) => (Array.isArray(v.findings) ? v.findings : []));
  const findings = {
    CRITICAL: findingsAll.filter((f) => f && f.severity === 'CRITICAL').length,
    MAJOR: findingsAll.filter((f) => f && f.severity === 'MAJOR').length,
    MINOR: findingsAll.filter((f) => f && f.severity === 'MINOR').length,
  };

  let escaped_total;
  let escaped_by_check;
  if (ledgerUnreadable) {
    escaped_total = null;
    escaped_by_check = {};
  } else {
    escaped_total = validEscaped.length;
    // Null-prototype accumulator: check names like "__proto__", "toString", or
    // "constructor" must land as OWN data properties. On a plain {} object,
    // "__proto__" assignment vanishes (silent loss) and "toString"/"constructor"
    // read inherited function values, fabricating garbage counts.
    escaped_by_check = Object.create(null);
    for (const e of validEscaped) {
      const key = String(e.check ?? 'unknown');
      escaped_by_check[key] = (escaped_by_check[key] || 0) + 1;
    }
  }

  anomalies.total = totalAnomalies(by_reason);

  return {
    path: repoArg,
    status,
    verdicts_total,
    pass_count,
    fail_count,
    findings,
    escaped_total,
    escaped_by_check,
    window: { first, last },
    anomalies,
  };
}

// --- main ------------------------------------------------------------------------
function main() {
  const args = process.argv.slice(2);
  if (args.length === 0) {
    usage();
    process.exit(1);
  }

  const vSchema = loadSchema(V_SCHEMA_PATH, 'verdict');
  const eSchema = loadSchema(E_SCHEMA_PATH, 'escaped');

  const seen = new Set();
  const repoObjs = [];

  for (const repoArg of args) {
    // Dedup keys on the REAL path (symlinks resolved): path.resolve alone lets a
    // symlink alias admit the same repo twice and double-count the north star.
    // realpathSync failure (e.g. broken link, EACCES) falls back to resolved.
    const resolved = path.resolve(repoArg);
    let realKey;
    try {
      realKey = fs.realpathSync(resolved);
    } catch (e) {
      realKey = resolved;
    }
    if (seen.has(realKey)) {
      warn(`duplicate path '${repoArg}' — skipping repeated argument (counted once)`);
      continue;
    }
    seen.add(realKey);

    // Errno discipline: ONLY ENOENT means skip/absent. Any other errno (EACCES,
    // EPERM, ELOOP, EIO, ...) must never make a given repo vanish from repos[] —
    // it is emitted as anomalous with all-null counts and an `unreadable` anomaly.
    const emitUnreadable = (what, e) => {
      const code = (e && e.code) || 'unknown-errno';
      warn(`${what} not statable (${code}) — repo emitted as anomalous, counts null (unreadable)`);
      const by_reason = emptyAnomalies().by_reason;
      by_reason.unreadable += 1;
      repoObjs.push(nullRepoObj(repoArg, by_reason));
    };

    let stat;
    try {
      stat = fs.statSync(repoArg);
    } catch (e) {
      if (e && e.code === 'ENOENT') {
        warn(`'${repoArg}' does not exist — skipping`);
        continue;
      }
      emitUnreadable(`'${repoArg}'`, e);
      continue;
    }
    if (!stat.isDirectory()) {
      warn(`'${repoArg}' is not a directory — skipping`);
      continue;
    }

    const gaddDir = path.join(repoArg, 'gadd');
    let gaddStat = null;
    try {
      gaddStat = fs.statSync(gaddDir);
    } catch (e) {
      if (!(e && e.code === 'ENOENT')) {
        emitUnreadable(`'${gaddDir}'`, e);
        continue;
      }
    }
    if (!gaddStat || !gaddStat.isDirectory()) {
      warn(`'${repoArg}' has no gadd/ — skipping (not a governed repo?)`);
      continue;
    }

    let repoObj;
    try {
      repoObj = processRepo(repoArg, vSchema, eSchema);
    } catch (e) {
      // Safety net: an internal aggregation failure must never make a repo vanish.
      warn(`aggregation failed for ${repoArg} — emitted as anomalous, counts null (aggregation_failed)`);
      const by_reason = emptyAnomalies().by_reason;
      by_reason.aggregation_failed += 1;
      repoObj = nullRepoObj(repoArg, by_reason);
    }
    repoObjs.push(repoObj);
  }

  // NORTH STAR over CLEAN repos only.
  const cleanRepos = repoObjs.filter((r) => r.status === 'clean');
  const anomalousRepos = repoObjs.filter((r) => r.status === 'anomalous');
  const escapedTotalSum = cleanRepos.reduce((sum, r) => sum + (r.escaped_total || 0), 0);
  const acceptedPushes = cleanRepos.reduce((sum, r) => sum + (r.pass_count || 0), 0);
  const escapedRate = acceptedPushes === 0 ? 'unmeasured' : String(escapedTotalSum / acceptedPushes);

  const output = {
    generated_note: 'local-only, do not commit',
    repos: repoObjs,
    north_star: {
      clean_repos: cleanRepos.length,
      anomalous_repos: anomalousRepos.map((r) => r.path),
      escaped_total: escapedTotalSum,
      accepted_pushes: acceptedPushes,
      escaped_rate: escapedRate,
    },
  };

  process.stdout.write(`${JSON.stringify(output)}\n`);

  // --- human table (stderr) ---
  const fmt = (v) => (v === null || v === undefined ? '' : String(v));
  const pad = (s, width) => s.padEnd(width, ' ');
  const padNum = (s, width) => s.padStart(width, ' ');

  process.stderr.write('\n');
  process.stderr.write('gadd-fleet — LOCAL-ONLY, do not commit\n');
  process.stderr.write(
    `${pad('repo', 46)} ${padNum('verdicts', 8)} ${padNum('pass', 6)} ${padNum('fail', 6)} ${padNum('escaped', 9)} ${padNum('CRIT', 6)} ${padNum('MAJ', 6)} ${padNum('MIN', 6)} ${padNum('status', 10)} ${padNum('anomalies', 10)}\n`
  );
  for (const r of repoObjs) {
    process.stderr.write(
      `${pad(r.path, 46)} ${padNum(fmt(r.verdicts_total), 8)} ${padNum(fmt(r.pass_count), 6)} ${padNum(fmt(r.fail_count), 6)} ${padNum(fmt(r.escaped_total), 9)} ${padNum(fmt(r.findings.CRITICAL), 6)} ${padNum(fmt(r.findings.MAJOR), 6)} ${padNum(fmt(r.findings.MINOR), 6)} ${padNum(r.status, 10)} ${padNum(fmt(r.anomalies.total), 10)}\n`
    );
  }
  process.stderr.write('\n');
  process.stderr.write(
    `north star — clean_repos=${cleanRepos.length} anomalous_repos=${anomalousRepos.length} escaped_total=${escapedTotalSum} accepted_pushes=${acceptedPushes} escaped_rate=${escapedRate}\n`
  );

  process.exit(0);
}

main();
