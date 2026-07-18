# 🏮 Lantern — gadd state ledger

Live state snapshot for work on gadd itself. Read at session start; update before ending
a session or handing off context. This file is only ever NOW — history lives in the log
below (append-only) and in git.

## Current state

| Field | Value |
|---|---|
| Version | v0.2 + v0.3 phase 1 CLOSED (2026-07-14, incl. the human push step) — next: /mission-loop on phases 1b + 2 |
| Coverage proxy | **2** — MEASURED 2026-07-16: (1) first deployment live on upstream gadd (origin tip `6b25ef5`); (2) gadd itself governed — dogfood merge `8a3f679` pushed and `gadd-ratchet` ran on origin, completed success (run 29474552876; `gadd-redteam` chained, success/keyless-degrade). Same criterion as deployment 1: the ratchet workflow runs on its pushes |
| Active mission branch | RUN-30 TWO PACKETS MERGE-READY at the operator's buttons (2026-07-18): (1) `mission/run-30-th-echo` tip `221f5d4` — TEST_HONESTY.md scratch-copy echo line (Trivial per operator ratification; Director edit, always-on CONTRACT_FIDELITY PASS, fingerprint clean, gate designed-FAIL {signer MINOR + fence CRITICAL naming RED_TEAM/TEST_HONESTY.md}; Ratifier APPROVE-CONDITIONAL — adversary definitions operator-only regardless of class, operator ratification IS the authorization; 7 receipts + 7 STOPs; post-merge accept = operator's own hands, prepared line accepted_sha → `221f5d4d3583bbd9853236a99091a0a676a39513` subject "gadd: accept 221f5d4", DELIVERED UNPROMPTED in the brief per the custody amendment). (2) `mission/run-30-loop-lease` tip `340a6bc` — A3 loop-lock lease hardening (Standard; lease-mtime-vs-TTL staleness, pid-death retired to advisory display, `refresh` subcommand, fail-closed TTL parsing + unreadable-mtime refuse + future-lease clamp; bench net 2/2 after 1 repair round — TH FAIL r1 exit-4-race-untested → PASS r2, SECURITY PASS r1 w/ 2 specified guards applied; 57-assert NEW corpus, 9 suites green, gate PASS-one-MINOR, ZERO fence paths → NO ACCEPT DUE; Ratifier APPROVE-CONDITIONAL — mission-loop.md step-0 doc sync ruled IN-SCOPE, SECURITY n3 refresh-ownership parked to standing queue; 5 receipts + 6 STOPs incl. never-co-merge). Merges order-independent, each --no-ff, operator's buttons; push separate word. A2 rolls to run #31 FIRST PICK (Major, heartbeat 37.9% at close prep). Both branches retained until push confirmed. Local main = origin + 3 (run-29 chain-live + run-30 declare/close). PRIOR: RUN-29 CHAIN LIVE ON ORIGIN (2026-07-18 system clock; operator: accept executed own-hands `43d896c` "gadd: accept 08b2d81" — FOURTH accept under the custody ruling, prepared line delivered unprompted per the freshly ratified custody amendment, executed via the `!` own-hands mechanism — then push on the operator's separate word): gate flipped FAIL-designed-CRITICAL → PASS-one-MINOR live on the real tree (base now `08b2d81`), residue clean pre-push (12 patterns, 0 hits, engine canary passed), push `24c24bc..43d896c` hook-gated PASS (pre-push gate fired live: PASS, only the standing signer MINOR). ORIGIN CI ALL GREEN on `43d896c`: gadd-ratchet SUCCESS · gadd-tests SUCCESS (bench-guard 53 asserts now running on origin for the first time) · gadd-redteam SUCCESS. `mission/run-29-bench-isolation` deleted (`-d`, push confirmed) per the retain-until-push-confirmed rule. The scratch-copy mutation discipline, `bin/bench-tree-guard.sh` instrument, and 5 adapter echoes are LIVE on origin main; the foreign docs rider `76bc039` rode as ratified — honest receipt in public history. All prior lantern records rode this push (origin == `43d896c` at push time); local main = origin + 1 chain-live lantern commit (rides next push). No open buttons; next work = run #30 queue, ratified order: (1) `RED_TEAM/TEST_HONESTY.md` echo line (Trivial, FIRST) · (2) A3 loop-lock lease hardening (Standard/Trivial, bin/** lane) · (3) A2 swallowed-error hardening · standing queues; morning-brief flags pending: custody-amendment first autonomous execution + A3 first execution. PRIOR: RUN-29 MERGE EXECUTED — ACCEPT WAS THE OPERATOR'S OPEN BUTTON (2026-07-17 evening, resumption session after all prior interactive sessions terminated; Mesa GADD resumption dispatch verified against the tree and found STALE — it described tip `5537ee5` mid-build, real state was MERGE-READY `08b2d81` closed 20:18; discrepancy reported, operator ruled): merge `f893d5b` --no-ff (operator: "Approve granted for the run-29 merge: execute it"; rider path MERGE AS RATIFIED, the dispatch's rebase order RESCINDED — its "before merge prep" precondition expired in flight; `76bc039` stays as the honest receipt of the incident). ALL 6 STOPS HONORED + RECEIPT-7 VERIFIED AT THE MERGE COMMIT: parents `a6fe226`+`08b2d81`, tip full-SHA exact pre-merge, exactly 5 branch commits in range, clean auto-merge probed pre-merge (`git merge-tree`, no content conflict), first-parent surface exactly the 9 declared files (only fence path `RED_TEAM/gate-matrix.md`; no other RED_TEAM/**, no .gadd/checks/**, no BASELINE.json — STOP-6 clear) ✓ · receipt-2 re-run: all 8 suites green at merge HEAD 53/20/32/81/69/8/40/69 ✓ · receipt-3 re-run: gate at merge commit base `e18ce5b` FAIL BY DESIGN, EXACTLY {standing signer MINOR + one CRITICAL naming `RED_TEAM/gate-matrix.md`} ✓ · zero `gadd: accept` subjects in range — NO ACCEPT RODE ✓ · remote UNTOUCHED ✓. A3 LOOP-LOCK LEASE HARDENING RATIFIED (same operator message): timestamped lease refreshed at phase boundaries, stale = lease age past threshold, NEVER pid-death alone; Standard/Trivial, bin/** lane, normal ceremony; QUEUE POSITION run #30 AFTER the TEST_HONESTY.md echo line and BEFORE A2 (operator rationale: isolation-breach classes do not wait behind hardening items); first execution flagged in the morning brief + reviewed at the next retro. RESUMPTION BOOTSTRAP receipts: peer-liveness quiet (only self-transcript active, next-most-recent idle 55 min; no repo-writing process; loop lock FREE — the pid-77809 lock dir already gone), lock acquired with long-lived session pid 15867. NEXT (operator's own hands, in order): (1) accept commit — accepted_sha → `08b2d81be70169903d1373cb89e6a6886eb927c2`, subject "gadd: accept 08b2d81" — flips the gate to PASS-one-MINOR (fourth accept under the custody ruling); (2) push, on the operator's separate word. Branch `mission/run-29-bench-isolation` retained until push confirmed. PRIOR: RUN-29 A1 MERGE-READY at the operator's button (2026-07-17 system clock): `mission/run-29-bench-isolation` tip `08b2d81` (off main `7e6b157`; 5 commits: foreign docs rider `76bc039` + `1db61ff` feat + `5537ee5` tests + `40052ab` fix-r1 + `08b2d81` fix-r2) — A1 BENCH SCRATCH-COPY MUTATION-DISCIPLINE BUILT (Major, operator-directed first pick): RED_TEAM/gate-matrix.md isolation ¶ tightened (restore-and-verify license REVOKED — bench members never write any tracked path even transiently; executed mutation tests on scratch copies under mktemp ONLY; prohibited verbs extended with `git update-index`/assume-unchanged/skip-worktree; dispatcher fingerprint-tripwire duty added; transient-write invisibility of the guard disclosed truthfully) + NEW instrument `bin/bench-tree-guard.sh` (components: HEAD · porcelain -z · diff HEAD --binary · diff --cached --binary · untracked-incl-ignored content w/ symlink-target/type-marker handling + die2-on-embedded-repo-dir · ls-files -v marker stream; exit 0 only on exact match, exit 2 on delta/cannot-measure/malformed — never fail-open; final sha256 `a41d236f`) + `tests/bench-guard-fixtures.sh` 53 asserts w/ executed mutation-bite receipts (CI tests/*.sh glob picks it up, no workflow edit) + one echo line in each of the 5 adapter agent files. BENCH (full, Major, isolated; the NEW guard ran snapshot/verify CLEAN around every round — first live enforcement of the discipline it installs): r1 CONTRACT_FIDELITY+TEST_HONESTY+REGRESSION PASS, SECURITY FAIL (ignored-path residue fail-open, empirically reproduced) + DATA_INTEGRITY FAIL (staged-index content masked by worktree, reproduced) → Fixer r1 `40052ab` → r2 SECURITY PASS, DI FAIL (assume-unchanged/skip-worktree cloak, reproduced) → Fixer r2 `08b2d81` AT CAP → r3 DI PASS (residual honestly scoped: pre-set bit = compromised-dispatcher precondition, set-bit-mid-round self-trips); NET 5/5, every hole closed with both-direction receipts (pre-fix rc0 repro → post-fix rc2). All 8 suites green at tip: bench-guard 53 · brief 20 · failclosed 32 · fleet 81 · heartbeat 69 · inapplicability 8 · parity 40 · signer 69. Gate at tip (base accepted_sha `e18ce5b`): FAIL BY DESIGN — exactly {standing signer MINOR + one fenced CRITICAL naming RED_TEAM/gate-matrix.md}; flips to PASS-one-MINOR on the operator's post-merge accept (run-24/28 shape). RATIFIER APPROVE-CONDITIONAL — item-6 L-CLASS by own-hands receipts (EIGHTH, run-16/24/28 lineage; SR-8 wording flag logged: "bench contracts operator-only" vs "L-class receipt-gated" tension is outcome-identical under the custody design, no park), custody CONFIRMED: post-merge accept = operator's own hands, prepared accepted_sha → `08b2d81be70169903d1373cb89e6a6886eb927c2` subject "gadd: accept 08b2d81", handed only when the merge lands; 7 receipts verified own-hands + 6 STOPs named for the --no-ff merge (incl. STOP-6 tier-3 auto-park if any RED_TEAM/** beyond gate-matrix.md or any .gadd/checks/** logic or BASELINE value beyond the accept advance appears in the merge). FOREIGN RIDER RULING: `76bc039` merges AS-IS, disclosed (docs-only duplicate run-29 declaration from the session collision, gate-neutral, out of product surface; in-loop rebase removal classifier-denied; SR-4 reconciliation: the rider's declared TEST_HONESTY.md wording line was NOT built — the 5 adapter echoes landed instead; a matching echo line in RED_TEAM/TEST_HONESTY.md itself queued as Trivial candidate). ANOMALY A3 (disclosed, resolved): CONCURRENT-LOOP COLLISION — a second mission-loop session stale-reclaimed the loop lock at 19:22 (bin/loop-lock.sh liveness check is blind to this harness's transient shell pids: every holder pid dies at Bash-call end — a DEMONSTRATED flaw in a ratified monotonic guard), committed the duplicate declaration `76bc039` on this branch at 19:24 mid-executor-build, then SELF-DETECTED the race and YIELDED cleanly (its final status: completed nothing; its corrective reset and lock release were both classifier-denied); this session re-acquired the lock with its live long-lived pid 61713 (self-healing — newcomers now correctly get exit 3). QUEUE PROPOSAL awaiting operator ratification (loop-law surface, stop-condition-2 discipline): harden loop-lock to long-lived-pid + lease/heartbeat design. ANOMALY A4 (explained clean): executor observed the peer's uncommitted LANTERN.md edit at session start (` M`, later committed by the peer as the rider) — no tree damage, fingerprint discipline held all rounds. Merge = operator's button; push = separate word. PRIOR: RUN-28 CHAIN LIVE ON ORIGIN (2026-07-17 system clock; operator: accept executed own-hands `145eb77` "gadd: accept e18ce5b" — third accept under the custody ruling — then push on the already-given word): gate flipped FAIL-designed-CRITICAL → PASS-one-MINOR live on the real tree (base now `e18ce5b`), push `6ac72d4..145eb77` hook-gated PASS (pre-push gate fired live: verdict PASS, only the standing signer MINOR), residue clean pre-push. ORIGIN CI ALL GREEN on `145eb77`: gadd-ratchet SUCCESS · gadd-tests SUCCESS (signer 69/69 incl. S19–S21 now running on origin) · gadd-redteam SUCCESS. `mission/run-28-ditype-wording` deleted (`-d`, push confirmed) per the retain-until-push-confirmed rule. The h3 type-named wording fix is LIVE on origin main, both copies. No open buttons; next work = run #29 queue — A1 SCRATCH-COPY MUTATION-DISCIPLINE FIRST PICK (operator directive, verbatim intent: isolation-breach class closed before the next Major runs a bench) · A2 swallowed-error hardening candidate · standing queues. Local main == origin == `145eb77`, fully synced. PRIOR: RUN-28 MERGE EXECUTED (2026-07-17 system clock; operator verbatim: "approve — execute the --no-ff merge of mission/run-28-ditype-wording at e18ce5b honoring all 5 STOPs, including the STOP-2 pre-merge byte-identity guard"): merge `8a0fe21` --no-ff, lock re-acquired pid-fresh 59736. STOP-5 FIRED BY ITS LETTER (main had advanced `1c680ae`→`50aa758` by exactly the run-28 close lantern commit, LANTERN.md only +33/-1) — Director HALTED with the merge untouched and invoked the named remedy: re-ratification in the SAME Ratifier context. Ratifier verified the delta own-hands (docs-only, zero fence paths, accepted_sha unchanged `d0845e5`, tip/ancestry intact, STOP-2 committed-tip-blobs reading CONFIRMED) → PROCEED at first-parent `50aa758`, receipt-3 re-pinned to the merge commit, receipts 1/2/4/5 + STOPs verbatim. ALL RECEIPTS VERIFIED AT THE MERGE COMMIT: parents `50aa758`+`e18ce5b`, tip ancestor, only the 2 branch commits in range ✓ · surface exactly the 3 declared files first-parent ✓ · both copies `87ddc7e2` at merge HEAD ✓ · all 7 suites green (signer 69 · failclosed 32 · parity 40 · fleet 81 · heartbeat 69 · inapplicability 8 · brief 20) ✓ · gate at merge commit base `d0845e5`: FAIL by design, EXACTLY {standing signer MINOR + one fenced CRITICAL naming `.gadd/checks/02-lane-violation.sh`}, no accept-authorship CRITICAL ✓ · accepted_sha unchanged — NO ACCEPT RODE ✓ · remote UNTOUCHED ✓. NEXT (operator's own hands, in order): (1) accept commit — accepted_sha → `e18ce5bc708c7626e19f693bbd73c8acd93ae96c`, subject "gadd: accept e18ce5b" — flips the gate to PASS-one-MINOR; (2) push, on the operator's separate word. Branch `mission/run-28-ditype-wording` retained until push confirmed. OPERATOR DIRECTIVE (same approval message, verbatim intent): A1 scratch-copy mutation-discipline item PROMOTED from standing queue to RUN #29 FIRST PICK — "a bench member writing to the tracked tree, even transiently and self-reverted, is an isolation-breach class I want closed before the next Major runs a bench." PRIOR: RUN-28 DITYPE-WORDING MERGE-READY at the operator's button (2026-07-17 system clock): `mission/run-28-ditype-wording` tip `e18ce5b` (`bb5875c` fix both copies + `e18ce5b` tests, off main `1c680ae`) — h3 DI WORDING NOTE BUILT (Major — gate change, always Major; run-21 bench-note lineage): the base-BASELINE.json guard now branches on `jq -e .`'s exit-code taxonomy (1 = valid-but-falsy top level → type-named message; 4/5/other = empty stream or genuine syntax error → "does not parse"), so valid-JSON top-level `null`/`false` bases emit `top level is a JSON null/boolean, not an object` instead of the parse wording — WORDING-ONLY, verdict-preserving both directions (DATA_INTEGRITY truth table over 13 input classes: base_baseline_malformed VALUE identical pre/post in every class, no 1→0 fail-open, no 0→1 undisclosed change; empty/whitespace stream can never reach `jq -r 'type'` and surface a blank-typed message). Surface exactly 3 files: both `02-lane-violation.sh` copies byte-identical (`87ddc7e2`) + `tests/signer-fixtures.sh` additive S19 null / S20 false / S21 whitespace-only (60→69, S1–S18 untouched). All 7 suites green at tip (signer 69 · failclosed 32 · parity 40 · fleet 81 · heartbeat 69 · inapplicability 8 · brief 20), Director-reproduced own-hands. Both-direction receipt reproduced independently by executor, Director, and Ratifier. Gate at tip (base accepted_sha `d0845e5`): FAIL BY DESIGN — exactly the standing signer MINOR + ONE governed-fence CRITICAL naming `.gadd/checks/02-lane-violation.sh` (the ratified task itself; flips to PASS-one-MINOR on the operator's post-merge accept, run-24 shape; adapters/lv copy and tests/ draw no fence finding). BENCH 5/5 ROUND 1 zero blockers, isolated (CONTRACT_FIDELITY · TEST_HONESTY mutation battery 3/3 killed · SECURITY empirical exit-code enumeration + NDJSON injection defeated end-to-end · DATA_INTEGRITY 13-class truth table · REGRESSION per-class OLD-vs-NEW byte-compare, no downstream matcher keys on the old wording). RATIFIER APPROVE-CONDITIONAL — item-6 L-CLASS by its own hands (SEVENTH L-class; O-class considered and REJECTED: hunks lie inside the finding-computation block; not forced tier-3: zero verdict deltas, taxonomy unchanged, message-only), custody CONFIRMED: post-merge accept = operator's own hands, prepared accepted_sha → `e18ce5bc708c7626e19f693bbd73c8acd93ae96c` subject "gadd: accept e18ce5b", handed only when the merge lands; 5 receipts reproduced own-hands + 5 STOPs named for the --no-ff merge (1 all-receipts-at-merge-commit · 2 A1 phantom-edit guard: tree clean AND both copies == `87ddc7e2` immediately pre-merge · 3 gate at merge commit = exactly {one signer MINOR, one fenced CRITICAL} · 4 accept = operator's hands, never rides · 5 main-advanced → re-ratify, run-27 STOP-1 precedent). ANOMALIES disclosed: A1 transient unstaged `-eq 1`→`-ne 1` edit on the `.gadd` copy observed by REGRESSION mid-bench, self-reverted, in no commit — attribution uncertain (SR-4; plausibly a bench member mutating the tracked grader instead of a scratch copy — SR-7 discipline breach, queued: harden mutation harness to scratch-copy-only), Director re-verified tree clean + byte-identity post-bench, Ratifier ruled CONDITION (STOP-2) + LOG, not a block; A2 pre-existing swallowed-error class (transient jq/git failure under load can fabricate a type-named finding inside an already-CRITICAL path, hits main and HEAD equally) — LOG + hardening-run queue candidate. Merge = operator's button; push = separate word. PRIOR: RUN-27 CHAIN LIVE ON ORIGIN (2026-07-17 system clock; operator: "Push"): push `500a35b..6ac72d4` hook-gated PASS (6 commits: run-26 chain-live + relaunch-declined lantern ×2, run-27 declare/close, merge `220c398` + merge-executed lantern; pre-push gate PASS with only the standing signer MINOR, base `d0845e5`). ORIGIN CI ALL GREEN on `6ac72d4` — gadd-ratchet SUCCESS · gadd-tests SUCCESS · gadd-redteam SUCCESS. `mission/run-27-installer-ux` deleted (`-d`, push confirmed). The installer REFUSED-on-non-directory fix + hardlink comment are LIVE on origin main. No open buttons; next work = run #28 queue (h3 DI wording FIRST PICK, Major, spec pinned · standing queues). Local main = origin + 1 chain-live lantern commit (rides next push). PRIOR: RUN-27 MERGE EXECUTED (2026-07-17 system clock; operator: bench-confirmation condition satisfied — SECURITY+REGRESSION PASS r1 zero blockers stated in-line — then "approve — execute the merge of mission/run-27-installer-ux at 8576a34 (--no-ff, honoring all 7 Ratifier STOPs; no accept due)"): merge `220c398` --no-ff, lock re-acquired pid-fresh 99215. STOP-1 FIRED AND CLEARED BY ITS NAMED REMEDY: main HEAD was `3506ae9` (the run-27 close lantern commit, LANTERN.md only +43/-1) not the pinned `4349451` — Director halted pre-merge, sent the delta to the SAME Ratifier context; Ratifier verified own-hands (docs-only, zero fence paths in `4349451..main`, tip/parent/ancestry intact) and ruled PROCEED with receipt-1 amended to HEAD==`3506ae9`, all other receipts/STOPs verbatim. ALL RECEIPTS VERIFIED AT THE MERGE COMMIT: (1) parents `3506ae9`+`8576a34`, tip ancestor, pre-merge HEAD==main==3506ae9 + tip-parent==4349451 + 500a35b-ancestor all checked ✓; (2) surface `4 0 adapters/cc/bin/install.sh` both branch range and first-parent merge diff ✓; (3) --no-ff, only `8576a34` entered the range ✓; (4) gate at `220c398` vs `500a35b` → verdict PASS, findings [] ✓; (5) brief 20/20 · failclosed 32/32 · parity 40/40 at merge HEAD ✓; (6) zero fence/accept paths in `3506ae9..220c398` — NO ACCEPT RODE ✓; (7) remote UNTOUCHED — push = the operator's separate word ✓. Branch `mission/run-27-installer-ux` retained until push confirmed. Local main = origin `500a35b` + 6 commits (4 lantern + branch commit via merge + merge commit). PRIOR: RUN-27 INSTALLER-UX MERGE-READY at the operator's button (2026-07-17 system clock): `mission/run-27-installer-ux` tip `8576a34` (single commit off main `4349451`) — run-22 UX notes BUILT (Standard): explicit `REFUSED (context exists but is not a directory — left untouched)` branch in `adapters/cc/bin/install.sh` (previously a raw `mkdir -p` crash exit 1 mid-install under set -euo pipefail) + the hardlink-case comment; one file +4/-0, ZERO fence paths in range. Bench 2/2 ROUND 1 zero blockers, isolated (SECURITY: 9 crafted fixtures incl. symlink→secret/FIFO/hardlink-to-secret, no write-through, new branch refuses-only; REGRESSION: all 7 suites green at tip 32/81/69/8/40/60/20, pre-existing installer paths output byte-IDENTICAL main↔tip). RATIFIER APPROVE-CONDITIONAL — item-6 OUT OF SCOPE by its own hands (fence globs RED_TEAM/** · .gadd/checks/** · gadd/BASELINE.json · OWNERSHIP.md — none in range) → **NO ACCEPT COMMIT DUE**; 7 receipts reproduced own-hands (surface +4/-0 · bash -n · both-direction crash→REFUSED · symlink-to-dir still branch-1 · brief 20/20 + failclosed 32/32 + parity 40/40 · gate PASS findings [] vs `500a35b` · ancestry linear), 6 merge receipts + 7 STOPs named for the --no-ff merge (HEAD==4349451 at merge time · surface unchanged zero fence paths · gate PASS at merge commit · suites ≥20/32/40 · --no-ff no extra commits · no accept rides · push = separate word). Gate at tip vs origin base `500a35b`: PASS findings []. Residue clean. h3 NOT STARTED (heartbeat 29.5% at close prep; Major ceremony ≈17 pts by run-24 precedent would cross the 40% wall) — rolls to run #28 FIRST PICK w/ root cause pinned: `jq -e .` exits nonzero on valid-JSON top-level `null`/`false`, routing them to the "does not parse" wording instead of the type-named branch (both 02-lane-violation.sh copies byte-identical at declaration). Local main = origin `500a35b` + 4 lantern commits (run-26 chain-live ×2, run-27 declare + close), rides next push. Merge = operator's button. PRIOR: RUN-26 CHAIN LIVE ON ORIGIN (2026-07-17 system clock): push `479051f..500a35b` hook-gated PASS (4 commits: run-26 declare/close, merge `a32bb15` + merge-executed lantern), residue clean; ORIGIN CI ALL GREEN on `500a35b` — gadd-ratchet SUCCESS · gadd-tests SUCCESS (brief corpus 20/20 now running on origin) · gadd-redteam SUCCESS. `mission/run-26-briefcheck` deleted (`-d`, push confirmed). `bin/brief-check.sh` + the amended close law are LIVE on main — every future run close is brief-freshness-gated. No open buttons; next work = run #27 queue (run-22 UX notes · h3 · standing queues). Local main = origin + 1 chain-live lantern commit (rides next push). PRIOR: RUN-26 MERGE EXECUTED (2026-07-17 system clock; operator verbatim: "approve — execute the merge of mission/run-26-briefcheck at 6ea61a1 (--no-ff, honoring all 7 Ratifier STOPs; no accept due), then push on my word: push"): merge `a32bb15` --no-ff, HEAD==main verified pre-merge (`002a09c`), lock re-acquired pid-fresh 79823. ALL 7 STOPS VERIFIED at the merge commit — (1) two parents `002a09c`+`6ea61a1`, both `6ea61a1` and `6474e60` ancestors ✓; (2) first-parent surface exactly M mission-loop.md + A bin/brief-check.sh + A tests/brief-fixtures.sh, ZERO fence paths in range ✓; (3) brief corpus 20/20 at merge HEAD ✓; (4) sibling suites green at merge HEAD 32/81/69/8/40/60 ✓; (5) brief-check PASS (fresh direction) at merge HEAD ✓; (6) live gate at `a32bb15` vs origin base `479051f` → verdict PASS, findings [] — NO ACCEPT FORCED ✓; (7) close-law line 56 byte-identical to the judged clause ✓. Push executing on the operator's same-message word. PRIOR: RUN-26 BRIEFCHECK MERGE-READY at the operator's button (2026-07-17 system clock): `mission/run-26-briefcheck` tip `6ea61a1` (`6474e60` instrument + `99ed6f3` corpus + `6ea61a1` close-law line) — brief-freshness close-check BUILT per the operator's decision-2 spec (§5 of `audits/brief-freshness-eval-v1.md`): header-anchored criterion, N from the lantern's topmost DECLARED entry (fail-closed exit 2), 20-assert corpus incl. the rolls-to-vacuity pin, close-law line byte-exact to the ratified text. Bench 2/2 ROUND 1 zero blockers (SECURITY + TEST_HONESTY, isolated; TH mutation battery 4/5 killed, the 5th — word-boundary-class removal — proven EXTENSIONALLY EQUIVALENT by Director receipt, unkillable, disclosed not queued). RATIFIER APPROVE-CONDITIONAL — item-6 OUT OF SCOPE by its own hands (fence globs RED_TEAM/** · .gadd/checks/** · gadd/BASELINE.json · OWNERSHIP.md, none in range; instrument wired into no acceptance path) → **NO ACCEPT COMMIT DUE**; 7 receipts reproduced own-hands, 7 STOPs named for the --no-ff merge. LIVE BOTH-DIRECTION RECEIPT: stale bite on the real tree mid-run (run-25 header vs closing #26 → exit 1 naming both) AND the fresh direction at this very close (BRIEF.md regenerated → brief-check PASS before the close commit — the new close law's FIRST enforcement). Origin CI ALL GREEN on `479051f` measured this run (ratchet · tests · redteam). Local main = origin + declaration/close lantern commits; merge + push = the operator's buttons. PRIOR: RUN-25 CHAIN LIVE ON ORIGIN (2026-07-17 system clock): push `17fe0bc..db6b2f1` hook-gated PASS (8 commits: run-24 lantern ×2, run-25 declare/close/merge-executed, merge `d1d5a65` + its 2 branch commits); ORIGIN CI ALL GREEN on the pushed tip — gadd-ratchet SUCCESS · gadd-tests SUCCESS (heartbeat 69/69 now running on origin) · gadd-redteam SUCCESS. `mission/run-25-heartbeat` deleted (`-d`, push confirmed). NO ACCEPT COMMIT in this chain — first governed merge under the custody ruling where none was due. No open buttons; next work = run #26 queue (brief-check build RATIFIED FIRST PICK · run-22 UX notes · h3 · standing queues). Local main = origin + 1 chain-live lantern commit (rides next push). EXECUTION DETAIL: RUN-25 MERGE EXECUTED (operator: "approve decision 1 — execute the merge … honoring all 5 STOPs" + mid-turn "push"): `mission/run-25-heartbeat` merged --no-ff → `d1d5a65`, ALL 5 RATIFIER STOPS VERIFIED at the merge commit — (1) two parents `3b39e0b`+`ef267ca`, ef267ca ancestor ✓; (2) first-parent surface exactly the 2 declared files, zero fence/accept paths in range ✓; (3) six suites green at merge HEAD: heartbeat 69 · failclosed 32 · fleet 81 · inapplicability 8 · parity 40 · signer 60 ✓; (4) R1 both-direction reproduced at merge commit (pre-fix `9188ec4` copy under residual-class fake jq → exit 0 + 0 stdout bytes, the fail-open LIVE; merge tip → exit 2 + one-line fail-closed JSON + loud stderr) ✓; (5) live gate at merge tip vs origin base `17fe0bc` → verdict PASS, findings [] (no accept forced; NO ACCEPT COMMIT in this chain, first governed merge without one, per the Ratifier's out-of-scope fence verification) ✓. DECISION 2 RATIFIED same message (see log entry). PRIOR: RUN-25 MERGE-READY at the operator's button (2026-07-17 system clock): `mission/run-25-heartbeat` tip `ef267ca` (`b7c6a62` fix + `ef267ca` tests) — h1/h2 heartbeat emission-exit hardening (Standard; closes the run-17 DI r3 stay-open note): all three status-mode jq emission sites guard their OWN exit status (capture-then-print atomic, static fail-closed JSON + exit 2, never 0/empty), probe proxy RETIRED; corpus 52→69 additive w/ mutation-bite receipts. Bench 2/2 ROUND 1 zero blockers (TEST_HONESTY + DATA_INTEGRITY, isolated). RATIFIER APPROVE-CONDITIONAL — item-6 classified OUT OF SCOPE by its own hands (instrument + additive corpus; NEITHER file under the governed fence, verified against the fence globs — **NO ACCEPT COMMIT EXPECTED**, first such packet since the custody ruling), 5 receipts reproduced + 5 STOPs named for the --no-ff merge. ALSO: BRIEF-FRESHNESS CLOSE-CHECK EVALUATION DONE (operator-queued run-25 pick) — `audits/brief-freshness-eval-v1.md` (local-private): literal anywhere-in-file criterion proven VACUOUS by receipt (the stale run-24 brief already mentioned "run #25" twice via its rolls-to section); proposal = header-anchored criterion + run number derived from the lantern's topmost DECLARED entry + `bin/brief-check.sh` + `tests/brief-fixtures.sh` + ONE close-law line in mission-loop.md — PARKED FOR RATIFICATION (stop condition 2; the close-law line is the enforcement). Local main = origin `17fe0bc` + 4 unpushed commits (2 run-24 lantern + run-25 declare + run-25 close); next push carries them. PRIOR: RUN-24 CHAIN LIVE ON ORIGIN (2026-07-17 UTC): operator executed the accept with their own hands (`17fe0bc`, "gadd: accept d0845e5" — second accept under the custody ruling), gate flipped FAIL-designed-CRITICAL → PASS-one-MINOR live (both directions now proven on the real tree, not just the scratch sim), push `9fa136b..17fe0bc` hook-gated PASS; ORIGIN CI ALL GREEN on the pushed tip within ~25s — gadd-ratchet SUCCESS · gadd-tests SUCCESS (S15–S18 running on origin under the run-23 fetch-depth repair) · gadd-redteam SUCCESS. `mission/run-24-ditype` deleted (`-d`, push confirmed). No open buttons; next work = run #25 queue (h1/h2 · run-22 UX notes · h3 wording note). EXECUTION DETAIL: merge `272742b` --no-ff (operator: "approve merge run-24"), ALL 6 RATIFIER STOPS VERIFIED at the merge commit (byte identity `3b66e001…` both copies · six suites green 32/81/52/8/40/60 · merge introduces exactly the 3 declared files, tests/ additive, RED_TEAM+spec clean · 2 parents w/ `d0845e5` ancestor · no accept rode · gate = designed FAIL w/ governed-fence CRITICAL + standing MINOR only). PRIOR detail (superseded by execution): `mission/run-24-ditype` tip `d0845e5` was MERGE-READY at the operator's button (run-24 ITEM 1: DI wrong-TYPE base guard — Major gate tightening, bench 5/5 net after one SR-1 repair round, Ratifier APPROVE-CONDITIONAL, SIXTH item-6 L-class, 6 receipts + 6 STOPs; post-merge accept = operator's own hands per the standing custody ruling, prepared accepted_sha → `d0845e54c1216f4364587407cca88de6259c07bd` subject "gadd: accept d0845e5", handed only when the merge lands). Local main = origin `9fa136b` + unpushed lantern commits (run-23-chain close, run-24 declare + close); next push carries them. PRIOR: FULL CHAIN LIVE ON ORIGIN (2026-07-17 UTC): operator executed the accept with their own hands (`9fa136b`, "gadd: accept 9673960" — first accept under the new custody ruling), gate flipped to PASS-one-MINOR base `9673960`, push `8c8a248..9fa136b` gated live by the pre-push hook PASS; ORIGIN CI ALL GREEN on the pushed tip — gadd-tests SUCCESS (**the origin red guard is closed: failure on `8c8a248` → success on `9fa136b`, the fetch-depth-0 repair proven live**), gadd-ratchet SUCCESS, gadd-redteam SUCCESS. All four `mission/run-22-*`/`run-23-*` branches deleted (`-d`, push confirmed). No open buttons; next work = run #24 queue. EXECUTION DETAIL: ALL FOUR MERGES EXECUTED on local main (operator: "approve merge chain as suggested … honoring all STOPs", 2026-07-16): `5136c70` run-22-ubc (SHA pin `03dcee0e` at merge HEAD, two-file surface, gate PASS one MINOR) → `ded81cb` run-22-ubc-installer (ubc.md `e7dcc663` at tip, installer-only delta, residue 0 hits, gate PASS one MINOR) → `b2794b6` run-23-ci (byte pins `fa61f624`/`f6142fdf` both copies each, signer 48/48 at merge HEAD, gate PASS one MINOR) → `ec40e40` run-23-ownership (surface OWNERSHIP.md only, payload `8e81b4a9` at merge HEAD, fence byte-identical; gate now FAIL w/ the DESIGNED un-accepted CRITICAL — flips to PASS-one-MINOR on the operator's accept). All --no-ff, every branch tip verified ancestor. NEXT: (1) operator executes the prepared accept one-liner (accepted_sha → `9673960add…`, subject "gadd: accept 9673960") — permanently the operator's own hands per the new standing ruling; (2) operator pushes. Branches retained until push confirmed. PRIOR detail (superseded by execution): (3) `mission/run-23-ci` tip `7729b2d` — CI red-guard repair (fetch-depth 0 on gadd-tests both copies `fa61f624…`, fail-loud signer red-run extraction, timeout-minutes 10 on gadd-tests+advisory both copies `f6142fdf…`; SECURITY+TEST_HONESTY PASS r1; Ratifier APPROVE-CONDITIONAL, 5 receipts, 5 STOPs). (4) `mission/run-23-ownership` tip `9673960` — OWNERSHIP corpus note, O-class (payload `8e81b4a9` byte-verified vs pinned lantern text, fence `fc932f70` unchanged; Ratifier APPROVE-CONDITIONAL, 6 receipts, 5 STOPs); its accept commit is PREPARED-NOT-EXECUTED (session permission classifier denied the loop's BASELINE commit — accepted_sha → `9673960add311143f80e9b551eee75105b5c443f`, subject "gadd: accept 9673960"). PRIOR: RUN-22 UBC WAVE MERGE-READY at the operator's buttons, chain order ancestry-pinned: (1) `mission/run-22-ubc` tip `903ac05` — ITEM 2 proportional-UBC rewrite (MAJOR, bench 5/5 round 1 zero blockers, Ratifier APPROVE-CONDITIONAL, 6 receipts + 5 STOPs, payload SHA `03dcee0e…` byte-verified); merges FIRST. (2) `mission/run-22-ubc-installer` tip `3f688ca` (base = ITEM 2 tip) — ITEM 1 installer ships ubc.md (Standard, SECURITY FAIL r1 → SR-1 symlink-fence repair → PASS r2; REGRESSION PASS r1; Ratifier APPROVE-CONDITIONAL, 6 merge-chain receipts + 5 STOPs incl. never-merge-out-of-order and shipped-SHA `e7dcc663…` == post-ITEM-2); merges SECOND. Gate PASS one designed MINOR at both tips, base `8947b1f`. Origin Actions status UNMEASURED all run (GitHub API 503 throughout — declaration ×2, mid-run poll ×20, close ×1). PRIOR: run-21 chain LIVE on origin — origin/main == local main at `8c8a248` verified at run-22 declaration (`git ls-remote`): the operator pressed the push button between sessions; both merges (signer `19d3243`, citests `923906d`) + run-21 lantern closes published. `mission/run-21-signer`/`-citests` branches deleted (`-d`, merged-only) per the standing retain-until-push-confirmed rule. Prior detail of that chain: BOTH run-21 merges LANDED on local main (operator-approved "approve merge run-21-signer and run-21-citests"). (1) signer merge `19d3243` --no-ff (parent branch tip `6cd5411`): ALL 5 RATIFIER STOPS VERIFIED — STOP-1 no-squash (6cd5411 ancestor of HEAD ✓), STOP-2 post-merge gate PASS base `8947b1f` exactly one MINOR / 0 CRIT / 0 MAJOR ✓, STOP-3 both `02-lane-violation.sh` copies == `a8a94e7…bdc01` ✓, STOP-4 no forbidden surface in `44f09ed..6cd5411` ✓, STOP-5 operator pressed ✓. (2) citests merge `923906d` --no-ff (branch tip `eaa5396`): `gadd-tests.yml` both copies == `227c0d4…`, full corpus simulation of the CI job GREEN (failclosed 32 · fleet 81 · heartbeat 52 · inapplicability 8 · parity 40 · signer 48), gate still PASS on final HEAD, residue clean. Final local main tip `923906d`; branches `mission/run-21-signer`/`-citests` retained until push confirmed. Prior: run-19 chain MERGED `d2106f5` LIVE on origin; origin main AT `02f9165` (run-20 close + CODEOWNERS + post-run-20 ratifications pushed; verified `origin/main..main` empty at run-21 start, then local main advanced with run-21 lantern commits — unpushed). Stale detail of the merged run-19 packet: `mission/run-19-prflow` was MERGE-READY at `cd37bc0` (PR-flow items 1+4+5 + accept commit, one packet; Ratifier APPROVE-CONDITIONAL — THIRD item-6 L-class ruling, 6 receipts, 4 STOPs incl. no-squash fence; merge = operator's button). Local main also carries the unpushed run-18/19 lantern closes. Prior chains all LIVE on origin: run-17 merged `2fbb39d` (n1+n2 heartbeat), run-16 merged `2aeae9f`, receipts green throughout. Prior: run-14-p1 MERGED+PUSHED 2026-07-17 (`65a9f91` on origin; operator-approved full chain; all 6 Ratifier receipts produced; pre-push hook gated PASS; the heartbeat is now LIVE in loop step 6). Prior: run-13-failclosed MERGED+PUSHED 2026-07-16 (`bb2b699`, operator-approved full chain; 5 reds closed on main). Prior: run-12-speed MERGED+PUSHED 2026-07-16 (`b74c389`, operator-approved; one-hunk union resolution in LANTERN.md disclosed, both sides byte-receipt). Prior: run-10-dogfood MERGED+PUSHED 2026-07-16 (`8a3f679`, operator-approved with re-verify condition honored; all 7 Ratifier receipts produced; pre-push hook fired live and gated the push PASS; origin ratchet ran, success). Prior: run-7 merged to main, pushed (wave "self-governing gadd": R5 wired · seed self-application bench-clean · Ratifier installed). Prior: PUBLIC HISTORY REWRITTEN from the root 2026-07-15 (double residue scrub + identity normalization) — every pre-rewrite SHA in log entries below is a stale pointer, disclosed not rewritten |
| Constitution | Ratifier-in-loop FULLY installed 2026-07-15 (operator: "go A, go B"): packets route to `gadd-ratifier` (isolated context, SR-1..**9**); only the charter's 7-item tier-3 list parks for the operator; item 7 at invariant wording. NAMING (operator-ratified 2026-07-17, item 7): "mesa-in-loop" branding RETIRED — the in-loop context is "the Ratifier" full stop; "Mesa" = operator-side counsel space ONLY; SR-9 added (in-loop products attributed to the Ratifier; mesa/operator attributions require verbatim-quotable text). ITEM-6 VERBATIM WRITE DONE (run #16, `53801cd`): V/L/O receipt-gated classes live in the charter, byte-exact from the run-15 brief (SHA-1 receipt `8005f17b`), quoting the run-16 dispatch; local-private canonical synced; FIRST L-CLASS EXERCISE same run (heartbeat fix — Ratifier classified, approved in-loop, merge still parked). Nightly schedule LIVE: launchd `com.gadd.mission-loop`, 02:17, night-mode park-and-continue; installer `bin/schedule-loop.sh` (placeholder-only template tracked). Morning brief = the operator's surface (English, ≤1 page, decisions-first). CUSTODY AMENDMENT (operator-ratified via Mesa 2026-07-17 reply, recorded 2026-07-18 system clock): the agent DELIVERS the prepared accept line UNPROMPTED the moment an accept becomes due — law, not courtesy; reference behavior = the run-29 delivery at merge `f893d5b`; the amendment's first AUTONOMOUS execution gets flagged in the next morning brief and reviewed at retro (standing first-execution rule) |
| North Star | **FIRST MEASURED VALUE 2026-07-15: escaped_rate = 0 over 9 accepted pushes** — fleet of 2 clean repos, 17 verdicts admitted with ZERO anomalies across all 7 reason classes, 30 findings caught pre-acceptance (14 CRITICAL). Ledger caveat CLOSED 2026-07-15: `gadd/ESCAPED.jsonl` live on both governed repos' origins — the next measurement's zero is a measured zero |
| Packet rule | PERMANENT (2026-07-15): YOUR MOVE never contains terminal commands — packets end in "reply approve and I execute"; operator may reply in plain language (any language, incl. Spanish); the loop translates to protocol |
| Objective function | RATIFIED 2026-07-14: maximize escaped-regression catches across governed repos (proxy until instrumented: upstream-governed-repo coverage × verdicts retained), subject to guards G1–G5 (`audits/objective-audit-v1.md` §3). Internal-first; OSS milestones gate on ≥1 upstream-governed repo |
| Adapters | lv (boundary) shipped · cc (in-loop) in progress — installer + blocking CI/hooks are v0.3 |
| RED_TEAM | Bench split into `RED_TEAM/` — one definition file per adversary (role, attack surface, pass criteria, output contract) + `gate-matrix.md`. Gate runners dispatch each adversary as its OWN isolated invocation, in parallel (cc: five `gadd-rt-*` subagents; lv: five independent API calls). Adversaries never see each other's verdicts. Models: structural (CONTRACT_FIDELITY, TEST_HONESTY) → cheap tier (haiku); judgment (SECURITY, DATA_INTEGRITY, REGRESSION) → strong tier (opus) |
| Protocol invariants | VERDICT + max 3 blockers per adversary · re-run only failed adversaries on the new diff · 2-round cap (spec inv. 6) · Architect arbitrates at the cap |
| Graders | `RED_TEAM/**` is grader territory — executors and the Fixer never edit it |
| Roadmap next | BRIEF-FRESHNESS CLOSE-CHECK: **BUILT run #26 — MERGE-READY at `mission/run-26-briefcheck` tip `6ea61a1`, no accept due** (ratified 2026-07-17, operator decision 2; Standard packet per §5 of the audit: header-anchored criterion, topmost-DECLARED derivation, bin/brief-check.sh + tests/brief-fixtures.sh + the one close-law line in mission-loop.md) · superseded: EVALUATION DONE run #25, AWAITING RATIFICATION (`audits/brief-freshness-eval-v1.md`, local-private — literal anywhere-criterion proven vacuous by receipt; header-anchored criterion + topmost-DECLARED derivation + bin/brief-check.sh + tests/brief-fixtures.sh + one close-law line proposed; build = Standard packet on approval) · ORIGINAL QUEUE ITEM (2026-07-16, run-25 pick candidate): BRIEF-FRESHNESS CLOSE-CHECK — evaluate a deterministic check that FAILS a run close if BRIEF.md does not reference the closing run number (operator, verbatim intent: "second brief-freshness slip; it deserves a check, not vigilance"); evaluation first, and any change to the loop's close law or gates parks for ratification per stop condition 2 · PR-FLOW READINESS AUDIT DONE run #18 (`audits/pr-flow-audit-v1.md`, local-private; GATES EXTERNAL-REPO ADOPTION — operator-ratified item): Q1 merge-commit WORKS · Q2 squash BREAKS-LOUD (fail-closed wedge, never fail-open) · Q3 baseline target narrow-break (squash widens the queued base_sha red; post-approval TOCTOU window) · Q4 CODEOWNERS MISSING. FIVE QUEUE ITEMS AWAITING OPERATOR RULING (jurisdiction flagged): (a) base_sha canonicalization + ancestry + squash-incompat error — tier-3/item-6; (b) CODEOWNERS for tier-3 surfaces — operator governance act, proposed text in the audit; (c) verifiable accept-signer replacing %ae — tier-3/item-6; (d) adoption note (merge-commit-only, integration ≠ acceptance) — Standard; (e) PR-time advisory ratchet run — Standard. RUN-16 RESULTS NOW STANDING: SPEED AUDIT v2 DONE (`audits/speed-audit-v2.md`, local-private; parser-parity receipt vs v1 bit-for-bit) — P1 REALIZED (deep-context tail eliminated: 0% turns >400k vs 26.4%; max ctx 394,006 under the ceiling; Director weighted/run −44%), P4 realized, P3 partially visible; total/run −7% because subagent work/run rose 68% (more Major throughput, not overhead); P7 stays REGISTERED-NOT-BUILT — no unexplained residual; v3 trigger = ≥3 fully-post-P1 runs (parser scripts preserved in `audits/*.py`). FIRST-MESSAGE TAX measured: ~47k tokens (not ~30k — in-app estimate understates), structure ≈20.2k cached prefix + ~27k per-session write; ~12–15k of the write is non-gadd plugin/skill/MCP surface; trim = operator-side project plugin/MCP config hygiene, second-order lever (~1–2% of spend). RUN-16 BENCH NOTES n1+n2 FIX BUILT run #17 (`2aeae9f..ddbc4df`, MERGE-READY — closed only when merged; fixtures 11+12, suite 52/52, DI PASS r3 after two SR-1 repair rounds AT CAP, Ratifier L-class APPROVE-CONDITIONAL). NEW OPEN (run-17 DI r3 hardening notes, Ratifier STOP-5 stay-open rule): h1+h2 as ONE queued refactor — status-mode measured emission should guard its OWN jq exit status and fail closed, retiring the probe proxy (probe flag-surface can never mirror every real-call flag; no real jq exhibits the residual today). CLOCK DRIFT disclosed: system clock measured 2026-07-16 during run #16 while run-15 artifacts carry 2026-07-17 — dates in prior entries are as-written, not rewritten. DECISION-3 STANDING CONDITION (operator 2026-07-17): stale deployment-name intermediates (`a451a43` + run-15 local intermediates carrying the descriptive pattern in-tree) are LEFT until the pre-launch scrub gate, which runs a FULL-HISTORY residue audit and re-decides; if ANY history rewrite happens before launch for any reason, those commits ride along in the same pass; anonymity is enforced binary the moment the repo faces external readers. HARDENING A–G reds CLOSED on main (run-13 merged): GADD_BASE silent-pass (MAJOR), crash-demote, malformed-line wipe, shared-/tmp substrate (F-12), OWNERSHIP self-governance + working-tree fence spoof. ORIGIN BENCH RULING (operator, 2026-07-16): keyless degrade is a DELIBERATE ACCEPTANCE — deterministic half runs, adversary half discloses itself as not-run; activation condition = first external contributor OR the second deployment's pilot launch, whichever first; subscription-vs-API decision deferred to that moment, stays tier-3 (secrets+money). ORIGIN BENCH RULING (operator, 2026-07-16): keyless degrade is a DELIBERATE ACCEPTANCE — deterministic half runs, adversary half discloses itself as not-run; activation condition = first external contributor OR the second deployment's pilot launch, whichever first; subscription-vs-API decision deferred to that moment, stays tier-3 (secrets+money). QUEUED from run-13 bench notes: base_sha canonicalization + ancestry check · hang timeout (gate) · trap EXIT INT TERM hygiene · stale docs/metric-parity.md /tmp reference · lib/common.sh standalone /tmp default · ::error:: base sanitize-if-untrusted. STILL QUEUED (APEX residuals): crafted-filename evasion (F-03) · RLS parser gaps (F-04) · %ae provenance + verdict-planting residuals · TOCTOU same-push pinning · redteam token parse + head_sha pin · hook stdin refspecs · gitignore widen `gadd/verdicts/*` · DX queue (installer clobber/reseed, jq preflight, CI runs tests/*.sh, version stamps). QUEUED: sandbox→`tests/`, test-hardening notes (aggregation_failed class, MINOR tally, tsx ceiling, positive tool-metric tests), R3 watchdog automation in dispatch plumbing · SPEED RULINGS RATIFIED 2026-07-16 (log entry below; audit local-private): P1 context-ceiling enforcement (Standard, monotonic) + P3 composite receipts script (Standard, monotonic) + P4 LANTERN rotation (Trivial/Standard, archive-never-delete) APPROVED and queued; P2 `gadd-bench` runner TIER-3 CONDITIONAL — only after the dogfood merge, 3 receipts (equivalence both-ways · known-bad mutation through the script path · Ratifier verdict) before it goes live, manual dispatch until then; P7 Architect/Coordinator Director split REGISTERED-NOT-BUILT, evaluated only by SPEED AUDIT v2 numbers after P1/P3/P4 land (grader tiers stay a floor per R2, Ratifier untouched); SPEED AUDIT v2 re-measure mandatory after P1/P3/P4 · STARTUP-MODE DESIGN ROW (roadmap, Major — trigger changes are tier-3): tier profile targets Director ceremony (packet/receipt verbosity, turn count — 68% of weighted spend), never the bench (14%) or gates (2.4% wall) · run-10 deferrals (all OPEN reds, Ratifier receipt 5): hook HEAD-vs-pushed-ref coupling (MINOR), redteam `.txt` verdicts uncovered by `*.json` ignore (MINOR), GADD_BASE silent-pass in shipped checks (MAJOR — a garbage base ref makes every check swallow git errors and PASS vacuously; executor-demonstrated), OWNERSHIP.md not self-governed (MINOR), stale OWNERSHIP prose line re lane list (Trivial doc fix) · retro items: approval-matrix↔charter tier-3 seam · SR-8 flag: "disclosure-addition vs monotonic-tightening" boundary needs invariant wording · OWNERSHIP-WORDING O-CLASS EDIT OPERATOR-RATIFIED run #21 (BUILDABLE run #22 — exact text = BRIEF.md §3 "On `tests/` and `RED_TEAM/`" note + amendment marking tests/** "(see note below)"; governed-file accept dance + Ratifier O-class receipt; resolves the charter-item-6-vs-OWNERSHIP.md "own" overload without enforcement change) · RUN-21 NEW QUEUE: valid-JSON-wrong-TYPE base BASELINE.json slips the parse guard → author factor silently dropped to MAJOR nudge (L-class tightening candidate; base trust-pinned, enrolled path still signature-gates) · `timeout-minutes` on PR-triggered CI jobs (gadd-tests AND live gadd-advisory — uniform hardening, generic public-repo abuse class) · additive-MINOR stacking awareness (external adopters at 2 pre-existing MINORs newly FAIL a legacy accept until signer enrollment — design-accepted) · h1/h2 heartbeat-emission-exit hardening still open · WAVE "UBC PORTABILITY" OPERATOR-RATIFIED 2026-07-16 (log entry below carries the pinned payload, SHA-1 `03dcee0e7d711e66d9923e8284cebcd7e53d3d5a`): RUN-22 FIRST PICKS — ITEM 2 proportional-UBC rewrite of context/ubc.md (Major, byte-exact text pinned in the log entry, title stays) THEN ITEM 1 cc-installer ships context/ubc.md (Standard, skip-if-exists, never touches pre-existing CLAUDE.md/context files, suggestion-only import line, R6 shipped-SHA==post-ITEM-2-SHA); rejection-ledger row (Karpathy origin, adapted; unconditional ultrathink retired — primary-semantic / keyword-plausible-unmeasured) rides the ITEM 2 packet; lv scope gap accepted as chosen · later: `gadd-accept` bot, Cursor/Replit adapters |

## Log (append-only, newest first)

Rotation (P4, run #12, 2026-07-16): entries older than run #10 moved verbatim to [LANTERN-ARCHIVE.md](LANTERN-ARCHIVE.md) — append-only, oldest at bottom, never edited or deleted; NOW + recent runs stay here.

- **mission-loop run #30 CLOSE (same session; 2 items completed, both
  MERGE-READY; heartbeat at close prep 37.9% of ceiling, measured):**
  ITEM 1 (Trivial, operator-ratified) — `mission/run-30-th-echo` tip
  `221f5d4`: scratch-copy echo line in RED_TEAM/TEST_HONESTY.md,
  byte-identical 5/5 to the adapter copies; Director edit (grader lane);
  always-on CONTRACT_FIDELITY PASS r1 zero blockers, fingerprint clean;
  8 suites green; gate designed-FAIL exact; Ratifier APPROVE-CONDITIONAL
  (operator ratification = the authorization for an adversary-definition
  edit; 7 receipts + 7 STOPs; accept prepared "gadd: accept 221f5d4",
  delivered unprompted per the custody amendment — its first autonomous
  exercise, flagged in the brief + for retro). ITEM 2 (Standard,
  operator-ratified A3) — `mission/run-30-loop-lease` tip `340a6bc`
  (`73487de` executor + `340a6bc` fixer r1): loop-lock lease design per
  the ratified spec (lease-mtime age vs TTL 3600s/env override, pid-death
  NEVER a staleness input — retired to advisory status display w/
  structural grep receipt + pinned A3 regression test; `refresh` at phase
  boundaries; old-format dir-mtime fallback); bench TH FAIL r1 (exit-4
  race untested) → Fixer → TH PASS r2; SECURITY PASS r1, its n1
  unreadable-mtime fail-open + n2 future-lease wedge closed in repair
  with mutation-bite receipts; n3 refresh-ownership DEFERRED → standing
  queue per Ratifier ruling (operator yes/no in brief); 57-assert corpus,
  9 suites green own-hands, gate PASS-one-MINOR, no fence paths → NO
  ACCEPT DUE; Ratifier APPROVE-CONDITIONAL, mission-loop.md step-0 sync
  ruled in-scope (both copies byte-identical), 5 receipts + 6 STOPs.
  A2 NOT STARTED (Major at 37.9% would cross the wall) → run #31 FIRST
  PICK. Dispatches clean: executor+fixer (1 context, 2 rounds), 3
  adversary invocations net, 2 Ratifier contexts, 1 repair round of cap
  2. Residue clean (12 patterns, 0 hits) + brief-check PASS pre-close.
  First-execution flags in brief: A3 (ships at merge #2, first live
  execution = next run) + custody amendment (prepared line delivered
  unprompted this close). Stopped: condition 1 (TIER-3 — two merges are
  the operator's buttons) + condition 4 (context wall adjacent). Task
  budget 2/5 used. Lock released at close.

- **mission-loop run #30 DECLARED (2026-07-18 system clock; FRESH SESSION per
  the run-29 chain-live close; heartbeat at declaration: 21.1% of ceiling,
  measured):** bootstrap observations — (a) loop lock was held by DEAD pid
  15867 (the terminated run-29 resumption session); stale-reclaimed and
  acquired with THIS session's long-lived pid 54577 (claude process, verified
  alive) per the run-29 live-pid remedy — the very transient-pid staleness
  A3 will retire is disclosed once more in passing. (b) origin/main ==
  `43d896c` verified live (`git ls-remote`); local main `fa8601a` exactly 1
  lantern commit ahead (run-29 chain-live), unpushed, rides the next operator
  push per standing practice. (c) HEAD==main at `fa8601a` (standing
  branch-cut ruling). (d) No open operator buttons (run-29 chain live, origin
  CI all green per the prior close). (e) Untracked `reports/` still present
  (operator-side artifacts, run-22 observation standing) — left untouched.
  Plan = the ratified run-30 order, verbatim: (1) TEST_HONESTY.md scratch-copy
  echo line — Trivial per operator ratification, FIRST; RED_TEAM/** grader
  lane so the edit is the Director's (executors/Fixer barred), deterministic
  gate + full suites + always-on CONTRACT_FIDELITY (RED_TEAM/** is a
  governed contract path per OWNERSHIP.md; "always-on triggers can never be
  skipped, whatever the tier"), Ratifier packet, designed fence CRITICAL →
  post-merge accept = operator's own hands. (2) A3 loop-lock lease hardening
  (Standard/Trivial, bin/** lane; ratified spec: timestamped lease refreshed
  at phase boundaries, stale = lease age past threshold, NEVER pid-death
  alone; first execution flagged in morning brief + next retro). (3) A2
  swallowed-error hardening → standing queues, budget permitting.

- **mission-loop run #29 CHAIN LIVE ON ORIGIN (2026-07-18 system clock; same
  resumption session):** operator executed the accept with their own hands
  (`43d896c`, "gadd: accept 08b2d81" — FOURTH accept under the custody
  ruling; the prepared line had been delivered unprompted per the custody
  amendment ratified minutes earlier, and executed via the session's `!`
  own-hands mechanism at the operator's request, exact command
  clipboard-handed). Gate flipped FAIL-designed-CRITICAL → PASS-one-MINOR
  live on the real tree (base now `08b2d81`), both directions proven live.
  Residue clean pre-push (12 patterns, 0 hits, engine canary passed). Push
  `24c24bc..43d896c` on the operator's word, hook-gated PASS (pre-push gate
  fired live: PASS, only the standing signer MINOR). ORIGIN CI ALL GREEN on
  `43d896c` (monitored to completion): gadd-ratchet SUCCESS · gadd-tests
  SUCCESS (bench-guard 53 asserts running on origin for the first time) ·
  gadd-redteam SUCCESS. `mission/run-29-bench-isolation` deleted (`-d`,
  push confirmed) per the retain-until-push-confirmed rule. The scratch-copy
  mutation discipline + `bin/bench-tree-guard.sh` + 5 adapter echoes are
  LIVE on origin main; rider `76bc039` rode as ratified. No open buttons.
  Next work = run #30 (fresh session), ratified order: (1) TEST_HONESTY.md
  echo line (Trivial, FIRST) · (2) A3 loop-lock lease hardening · (3) A2
  swallowed-error hardening · standing queues; morning-brief flags pending:
  custody-amendment first autonomous execution + A3 first execution.

- **OPERATOR RATIFICATIONS ×2 (via Mesa, decisions dated 2026-07-17,
  recorded 2026-07-18 system clock; same resumption session, accept still
  the open button):** (1) TEST_HONESTY.md ECHO LINE — YES: the scratch-copy
  echo line lands in `RED_TEAM/TEST_HONESTY.md` itself (the definition
  file; the five adapter copies already carry it from run-29). Queued run
  #30, Trivial tier, FIRST in queue — the ratified run-30 order is now (1)
  TEST_HONESTY.md echo (Trivial) → (2) A3 loop-lock lease hardening
  (Standard/Trivial, bin/** lane) → (3) A2 swallowed-error hardening →
  standing queues. (2) CUSTODY AMENDMENT RATIFIED: the custody ruling now
  explicitly requires the agent to deliver the prepared accept line
  UNPROMPTED the moment an accept becomes due — the run-29 delivery at
  merge `f893d5b` is the reference behavior, now law, not courtesy;
  amendment text pinned in the Constitution row; per the standing
  first-execution rule, its first autonomous execution gets flagged in the
  next morning brief and reviewed at retro. Open buttons unchanged:
  (1) accept — accepted_sha → `08b2d81be70169903d1373cb89e6a6886eb927c2`,
  subject "gadd: accept 08b2d81", operator's own hands; (2) push, separate
  word.

- **mission-loop run #29 MERGE EXECUTED (2026-07-17 evening; RESUMPTION
  session — the operator had terminated all prior interactive sessions; Mesa
  GADD resumption dispatch verified against the tree and found STALE: it
  described branch tip `5537ee5` mid-build with a history-repair order, real
  state was MERGE-READY `08b2d81`, run closed 20:18; discrepancy reported
  with receipts, operator ruled):** OPERATOR DECISIONS (one message, three
  parts): (1) rider path MERGE AS RATIFIED — the dispatch's rebase order
  RESCINDED (its "before merge prep" precondition expired in flight; the
  ratified disposition "foreign rider `76bc039` merges as-is disclosed"
  stands); the rider stays in history as the honest receipt of the incident.
  (2) A3 LOOP-LOCK LEASE HARDENING RATIFIED as specified: timestamped lease
  refreshed at phase boundaries; stale = lease age past threshold, NEVER
  pid-death alone; Standard/Trivial tier, bin/** lane, normal ceremony;
  queue position run #30 AFTER the TEST_HONESTY.md echo line and BEFORE A2
  ("isolation-breach classes do not wait behind hardening items" — the same
  rationale that promoted A1); per standing rule its first execution gets
  flagged in the morning brief and reviewed at the next retro. (3) merge
  approved; hand the prepared accept line unprompted and halt for the
  operator's accept; push follows per protocol after the accept lands.
  RESUMPTION BOOTSTRAP (dispatch step 0, receipts): peer-liveness quiet —
  only this session's transcript active (next-most-recent idle 55 min), no
  process writing the repo beyond self/IDE/idle shells, loop lock FREE (the
  pid-77809 lock dir already gone; pid 77809 dead) — lock acquired with the
  long-lived session pid 15867 per the run-29 live-pid remedy. The 7
  receipts + 6 STOPs were recovered verbatim from the terminated session's
  transcript (Ratifier packet quoted in full; no packet file exists
  in-repo). MERGE `f893d5b` --no-ff. ALL 6 STOPS HONORED, RECEIPT-7 VERIFIED
  AT THE MERGE COMMIT: STOP-1 tip exact `08b2d81be70…927c2`, branch not
  advanced ✓; STOP-2 clean auto-merge (probed pre-merge via `git
  merge-tree`), exactly 5 branch commits in range, first-parent surface
  exactly the 9 declared files ✓; receipt-2 re-run at merge HEAD: all 8
  suites green 53/20/32/81/69/8/40/69 ✓; receipt-3 re-run at merge commit
  base `e18ce5b`: FAIL BY DESIGN, EXACTLY {standing signer MINOR + one
  CRITICAL naming `RED_TEAM/gate-matrix.md`} (STOP-3 ✓); zero `gadd: accept`
  subjects in range — no accept rode, custody intact (STOP-4) ✓; STOP-6
  scan: no RED_TEAM/** beyond gate-matrix.md, no .gadd/checks/**, no
  BASELINE.json in the merge ✓; remote UNTOUCHED (STOP-5 — push is a
  distinct button) ✓. NEXT (operator's own hands, in order): (1) accept
  commit — accepted_sha → `08b2d81be70169903d1373cb89e6a6886eb927c2`,
  subject "gadd: accept 08b2d81" — flips the gate to PASS-one-MINOR (fourth
  accept under the custody ruling); (2) push, on the operator's separate
  word. Branch `mission/run-29-bench-isolation` retained until push
  confirmed.

- **mission-loop run #29 CLOSE (same session; 1 item completed, MERGE-READY;
  heartbeat at close prep 39.5% of ceiling, measured):** ITEM 1 A1 BENCH
  SCRATCH-COPY MUTATION-DISCIPLINE (Major — RED_TEAM/** grader change,
  operator-directed first pick) — `mission/run-29-bench-isolation` tip
  `08b2d81`: gate-matrix mutate-and-restore license REVOKED (scratch-copies-
  under-mktemp only, verbs extended w/ `update-index`+bits, tripwire duty,
  truthful disclosure) + `bin/bench-tree-guard.sh` instrument + 53-assert
  corpus + 5 adapter echoes. Bench: r1 3 PASS/2 FAIL → Fixer → r2 1 PASS/1
  FAIL → Fixer AT CAP → r3 DI PASS; net 5/5; THREE real fail-open holes in
  the new instrument found by the bench and closed with both-direction
  receipts (ignored-path residue · staged-index masking ·
  assume-unchanged/skip-worktree cloak) — the bench earned its keep on the
  very tool that polices it; guard snapshot/verify clean around every
  round. Gate at tip: designed FAIL {signer MINOR + gate-matrix CRITICAL}.
  RATIFIER APPROVE-CONDITIONAL, item-6 L-CLASS (8th), 7 receipts + 6
  STOPs; accept = operator's own hands (prepared "gadd: accept 08b2d81");
  foreign rider `76bc039` merges as-is disclosed. ANOMALY A3: concurrent
  mission-loop session stale-reclaimed the lock (transient-pid flaw in
  loop-lock.sh, DEMONSTRATED), committed the duplicate declaration rider,
  self-detected and yielded; lock re-acquired live-pid 61713. PROPOSAL for
  ratification: loop-lock long-lived-pid + lease/heartbeat hardening.
  Rolls to run #30: TEST_HONESTY.md echo line (Trivial) · A2
  swallowed-error hardening · standing queues. Dispatches 10/10 clean
  (executor+fixer ×3 rounds, 8 adversary invocations net, Ratifier);
  repair rounds 2/2 used (run-17 precedent honored at cap). Residue +
  brief-check run pre-close (receipts in close commit). Stopped:
  condition 1 (TIER-3 — merge is the operator's button) + condition 3
  (39.5% at close prep, wall adjacent). Task budget 1/5 used.

- **mission-loop run #29 DECLARED (2026-07-17 system clock; FRESH SESSION per the
  run-28 chain-live close; lock acquired pid 62232; heartbeat at declaration:
  16.7% of ceiling, measured):** bootstrap observations — (a) origin/main ==
  `145eb77` verified live (`git ls-remote`); local main `24c24bc` exactly 1
  lantern commit ahead (run-28 chain-live), unpushed, rides the next operator
  push per standing practice. (b) HEAD==main verified at `24c24bc` (standing
  branch-cut ruling). (c) No open operator buttons (run-28 chain live, origin
  CI all green per the prior close). (d) Untracked `reports/` still present
  (operator-side artifacts, run-22 observation standing) — left untouched.
  Plan by leverage (operator directive pins the first pick): (1) A1 BENCH
  SCRATCH-COPY MUTATION-DISCIPLINE — FIRST PICK, declared MAJOR (RED_TEAM/**
  grader change; "Changes here are Major" per RED_TEAM/CLAUDE.md; governed
  fence → designed gate CRITICAL pre-accept, post-merge accept = operator's
  own hands per the standing custody ruling). Root cause pinned by read-only
  audit this session: `RED_TEAM/gate-matrix.md:32-36` currently PERMITS
  in-tree mutation ("Mutation tests … must restore the exact prior state and
  verify it with `git status` before returning") — the run-28 incident
  adversary was arguably compliant with that letter; the five
  `adapters/cc/agents/gadd-rt-*.md` carry unrestricted `tools: … Bash` with
  read-only in prose only; and NO deterministic mechanism detects a mid-bench
  tracked-tree write (every check diffs committed ranges; the receipts
  porcelain count is informational and point-in-time). Spec: (i) gate-matrix
  isolation ¶ rewritten — bench members NEVER write any tracked path, even
  transiently; executed mutation tests ONLY on scratch copies under mktemp
  outside the tracked tree (the repo's own tests/heartbeat-fixtures.sh
  pattern); the dispatcher MUST snapshot the tree fingerprint immediately
  before bench dispatch and verify identity after each adversary returns —
  any delta voids the round, fail-closed; (ii) new instrument
  `bin/bench-tree-guard.sh` (`snapshot` → deterministic fingerprint of
  tracked-tree state; `verify <fp>` → exit 0 identical / exit 2 on delta OR
  cannot-measure, loud, names changed paths); (iii)
  `tests/bench-guard-fixtures.sh` corpus w/ mutation-bite receipts (CI globs
  tests/*.sh — new suite runs on origin automatically, no workflow edit);
  (iv) one echo discipline line in each of the five adapter agent files.
  Monotonic tightening (revokes a permission, adds a guard) — Ratifier
  item-6 L-class candidate. Full bench (Major). Surface 8 files, exactly one
  fence path. (2) A2 swallowed-error hardening candidate + standing queues,
  as budget allows.

- **mission-loop run #29 DECLARED (2026-07-17 system clock; FRESH SESSION per the
  run-28 chain-live close; lock acquired pid 77809 after reclaiming stale pid
  62232 dead; heartbeat at declaration: 18.6% of ceiling, measured):** bootstrap
  observations — (a) origin/main == `24c24bc` verified live (`git ls-remote`);
  local main == origin, FULLY SYNCED, zero unpushed commits. (b) HEAD==main
  verified at `24c24bc` (standing branch-cut ruling). (c) No open operator
  buttons (run-28 chain live, origin CI all green per the prior close).
  (d) Untracked `reports/` still present (operator-side artifacts, run-22
  observation standing) — left untouched. (e) Both `02-lane-violation.sh`
  copies byte-identical at declaration (`87ddc7e2`), matching the run-28 pin.
  Plan by leverage (first pick = operator directive, remainder from the
  ratified rolled queue, nothing new): (1) A1 BENCH MUTATION-DISCIPLINE —
  FIRST PICK per the operator's run-28 directive (verbatim intent: "a bench
  member writing to the tracked tree, even transiently and self-reverted, is
  an isolation-breach class I want closed before the next Major runs a
  bench"), declared MAJOR (grader/bench-contract change, always Major; both
  files under the `RED_TEAM/**` governed fence → designed gate CRITICAL
  pre-accept, post-merge accept = operator's own hands per the standing
  custody ruling). Root cause pinned: `RED_TEAM/gate-matrix.md` isolation
  rule's final sentence LICENSES transient tracked-tree mutation ("must
  restore the exact prior state and verify it with `git status` before
  returning") — exactly the clause the run-28 A1 anomaly rode. Scope:
  replace that license with SCRATCH-COPY-ONLY discipline (mutants applied
  only to copies outside the tracked tree; any write to a tracked path, even
  self-reverted, = isolation breach invalidating the round; gate runner
  snapshots `git status --porcelain` pre-bench and re-verifies post-bench
  before admitting verdicts — codifying the run-28 Director practice) +
  one reinforcing line in `RED_TEAM/TEST_HONESTY.md`. Wording-only monotonic
  tightening of adversary license; no verdict semantics, triggers, or tiers
  altered; full bench (Major). (2) A2 swallowed-error hardening candidate ·
  standing queues, as budget allows.

- **2026-07-17 (system clock) · RUN-28 CHAIN LIVE ON ORIGIN (operator: accept
  own-hands, then "push"):** the operator executed the prepared accept with
  their own hands (`145eb77`, "gadd: accept e18ce5b" — third accept under the
  custody ruling; the Director prepared the exact line on the operator's
  explicit instruction, the operator ran it via `!`), gate flipped
  FAIL-designed-CRITICAL → PASS-one-MINOR live (base `e18ce5b`), push
  `6ac72d4..145eb77` executed on the operator's word — residue clean, pre-push
  hook fired live and gated PASS (only the standing signer MINOR). ORIGIN CI
  ALL GREEN on `145eb77`: gadd-ratchet SUCCESS · gadd-tests SUCCESS (signer
  69/69 incl. the new S19–S21 running on origin) · gadd-redteam SUCCESS.
  `mission/run-28-ditype-wording` deleted (`-d`, push confirmed). The h3
  type-named wording fix is LIVE on origin main. BRIEF.md updated to executed
  state (nothing pending). No open buttons; run #29 = fresh session (A1
  scratch-copy mutation-discipline FIRST PICK per the operator directive ·
  A2 hardening candidate · standing queues).

- **2026-07-17 (system clock) · RUN-28 MERGE EXECUTED (operator: approve verbatim,
  honoring all 5 STOPs incl. STOP-2):** merge `8a0fe21` --no-ff, lock re-acquired
  pid-fresh 59736. STOP-5 fired by its letter (main advanced by exactly the
  run-28 close lantern commit): Director HALTED pre-merge and sent the delta to
  the SAME Ratifier context; Ratifier verified own-hands (docs-only advance,
  zero fence paths, accepted_sha unchanged, ancestry intact; STOP-2
  committed-tip-blobs reading confirmed) → PROCEED at first-parent `50aa758`,
  receipt-3 re-pinned to the merge commit, all else verbatim. All receipts then
  verified at `8a0fe21` (details in the state row): parents/ancestry ✓ ·
  3-file surface ✓ · byte identity `87ddc7e2` ✓ · 7 suites green ✓ · gate =
  exactly {signer MINOR + one fenced CRITICAL} ✓ · no accept rode ✓ · remote
  UNTOUCHED. Accept commit = the operator's own hands next (prepared line in
  the state row), push = separate word. OPERATOR DIRECTIVE logged: A1
  scratch-copy mutation-discipline → run #29 FIRST PICK (isolation-breach
  class closed before the next Major bench). BRIEF.md updated to executed
  state; brief-check PASS re-verified.

- **mission-loop run #28 CLOSE (same session; 1 item completed, MERGE-READY;
  heartbeat at close prep 34.5% of ceiling, measured):** ITEM 1 h3 DI WORDING
  NOTE (Major — gate change) — `mission/run-28-ditype-wording` tip `e18ce5b`
  (`bb5875c` fix + `e18ce5b` tests off main `1c680ae`): base-BASELINE.json
  guard branches on `jq -e .`'s exit-code taxonomy (rc 1 = valid-but-falsy →
  type-named CRITICAL naming "JSON null"/"JSON boolean"; rc 4/5/other =
  empty stream / syntax error → "does not parse" unchanged); wording-only,
  verdict-preserving (13-class truth table: malformed VALUE identical
  pre/post everywhere). Surface 3 files: both check copies byte-identical
  `87ddc7e2` + additive S19/S20/S21 (signer 60→69). All 7 suites green at
  tip, Director-reproduced. Gate: FAIL by design — standing signer MINOR +
  one fenced CRITICAL naming `.gadd/checks/02-lane-violation.sh` only
  (clears on the operator's post-merge accept, run-24 shape). BENCH 5/5
  ROUND 1 zero blockers (full bench per Major), isolated. RATIFIER
  APPROVE-CONDITIONAL — item-6 L-CLASS own-hands (seventh; O-class rejected
  by receipt), custody confirmed: accept = operator's own hands, prepared
  accepted_sha → `e18ce5bc708c7626e19f693bbd73c8acd93ae96c` subject
  "gadd: accept e18ce5b"; 5 receipts + 5 STOPs (state row). ANOMALIES: A1
  transient self-reverted tracked-file mutation during the bench (in no
  commit; tree re-verified clean + byte-identical; Ratifier: CONDITION
  STOP-2 + LOG; queued: mutation harness scratch-copy-only discipline) ·
  A2 pre-existing swallowed-error flake class, main and HEAD equally (LOG +
  hardening queue). Dispatches 7/7 clean (executor, 5 adversaries,
  Ratifier), zero repair rounds, zero classifier denials. Residue: clean
  (12 patterns, 0 hits, canary passed) before the close commit. BRIEF.md
  regenerated to run-28 state, brief-check PASS pre-close (close law
  honored). Stopped: condition 1 (TIER-3 — merge is the operator's button)
  + condition 4 (34.5% at close prep; any further item's ceremony would
  cross the 40% wall, run-26/27 precedent). Task budget 1/5 used. Rolls to
  run #29: standing queues (incl. new: bench mutation-harness scratch-copy
  discipline · swallowed-error hardening candidate).

- **mission-loop run #28 DECLARED (2026-07-17 system clock; FRESH SESSION per the
  run-27 chain-live close; lock acquired pid-fresh 33215; heartbeat at declaration:
  19.6% of ceiling, measured):** bootstrap observations — (a) origin/main ==
  `6ac72d4` verified live (`git ls-remote`); local main `641f46e` exactly 1
  lantern commit ahead (run-27 chain-live), unpushed, rides the next operator
  push per standing practice. (b) HEAD==main verified at `641f46e` (standing
  branch-cut ruling). (c) No open operator buttons (run-27 chain live, origin
  CI all green per the prior close). (d) Untracked `reports/` still present
  (operator-side artifacts, run-22 observation standing) — left untouched.
  (e) Both `02-lane-violation.sh` copies byte-identical at declaration
  (`3b66e001`), matching the run-27 pin. Plan by leverage (all picks from the
  ratified rolled queue, nothing new): (1) h3 DI WORDING NOTE — FIRST PICK,
  declared MAJOR (gate change, always Major; run-21 bench-note lineage, spec
  pinned at the run-27 close): `jq -e .` at the parse guard exits nonzero on
  valid-JSON top-level `null`/`false` (exit tracks output truthiness), routing
  those bases to the parse-branch "does not parse" wording instead of the
  type-named branch — fail-closed CRITICAL either way, wording-only monotonic
  tightening; fix lands on BOTH copies (`.gadd/checks/` + `adapters/lv/checks/`)
  byte-identical + additive signer-fixtures scenarios; full bench (Major);
  governed fence `.gadd/checks/**` → designed gate CRITICAL pre-accept,
  post-merge accept = operator's own hands per the standing custody ruling.
  (2) Standing queues as budget allows.

- **2026-07-17 (system clock) · RUN-27 CHAIN LIVE ON ORIGIN (operator: "Push"):**
  push `500a35b..6ac72d4` executed, pre-push hook fired live — gate PASS with
  only the standing signer MINOR (base `d0845e5`), residue clean pre-commit.
  ORIGIN CI ALL GREEN on `6ac72d4` within ~30s: gadd-ratchet SUCCESS ·
  gadd-tests SUCCESS · gadd-redteam SUCCESS. `mission/run-27-installer-ux`
  deleted (`-d`, push confirmed) per the retain-until-push-confirmed rule.
  The installer fix (explicit REFUSED on non-directory `context` + hardlink
  comment) is LIVE on origin main. BRIEF.md updated to executed state
  (nothing pending). No open buttons; run #28 = fresh session (h3 DI
  wording FIRST PICK, Major, spec pinned · standing queues).

- **2026-07-17 (system clock) · RUN-27 MERGE EXECUTED (operator: pre-condition
  "confirm the bench ran" answered — SECURITY+REGRESSION PASS r1 zero
  blockers — then approve verbatim, honoring all 7 STOPs; no accept due):**
  merge `220c398` --no-ff, lock re-acquired pid-fresh 99215. STOP-1 fired by
  its letter (main HEAD `3506ae9` ≠ pinned `4349451` — main had advanced by
  exactly the run-27 close lantern commit, LANTERN.md only +43/-1): Director
  HALTED with the merge untouched and invoked the STOP's named remedy —
  re-ratification in the SAME Ratifier context. Ratifier verified the delta
  own-hands (docs-only advance, zero fence paths, branch tip/parent/ancestry
  intact) → PROCEED, receipt-1 amended to HEAD==`3506ae9`, receipts 2–6 and
  STOPs 2–7 verbatim. All receipts then verified at the merge commit
  (details in the state row): parents/ancestry ✓ · surface 4/0 one file both
  ranges ✓ · gate PASS findings [] vs `500a35b` ✓ · brief 20/20 + failclosed
  32/32 + parity 40/40 ✓ · zero fence/accept paths, no accept rode ✓.
  Remote UNTOUCHED — push = the operator's separate word. Branch retained
  until push confirmed. BRIEF.md updated to executed state (one word
  remaining: push); brief-check PASS re-verified.

- **mission-loop run #27 CLOSE (same session; 1 item completed, MERGE-READY;
  heartbeat at close prep 29.5% of ceiling, measured):** ITEM 1 RUN-22 UX
  NOTES (Standard — operator-ratified rolled queue item) —
  `mission/run-27-installer-ux` tip `8576a34` (single commit off main
  `4349451`): `adapters/cc/bin/install.sh` +4/-0 — (1) explicit
  `REFUSED (context exists but is not a directory — left untouched)` branch
  between the symlink-REFUSED and SKIPPED branches (previously: regular-file
  `context` → raw `mkdir: context: File exists` exit 1 mid-install under
  set -euo pipefail; now: loud refusal, exit 0, rest of install completes,
  file untouched); (2) the hardlink-case comment above the SKIPPED elif (a
  hardlinked ubc.md is `-L`-invisible, lands SKIPPED, never written —
  accepted, documented). Both-direction receipt reproduced THREE independent
  times (executor, bench, Ratifier): main copy crash exit 1 ↔ tip copy
  REFUSED exit 0. Ordering invariant verified: `-L` (lstat) branch first —
  symlink-to-dir, symlink-to-secret, and dangling symlinks all still hit
  branch 1, never the new branch. BENCH 2/2 ROUND 1 zero blockers, isolated:
  SECURITY PASS (9 crafted fixtures incl. FIFO + hardlink-to-secret;
  secret sentinel byte-identical across all 9; new branch emits only a fixed
  literal — refuses-only, no injection surface; non-blocking: pre-existing
  TOCTOU window not materially widened) · REGRESSION PASS (all 7 suites
  green at tip: failclosed 32 · fleet 81 · heartbeat 69 · inapplicability 8 ·
  parity 40 · signer 60 · brief 20 — matching lantern siblings; main-vs-tip
  installer output byte-IDENTICAL on every pre-existing path; installed
  ubc.md byte-identical to source). Gate at tip vs origin base `500a35b`:
  PASS, findings []. RATIFIER: APPROVE-CONDITIONAL — item-6 OUT OF SCOPE by
  its own hands (zero fence paths in `4349451..8576a34`) → NO ACCEPT COMMIT
  DUE; 7 receipts reproduced own-hands, 6 merge receipts + 7 STOPs named
  (state row). ITEM 2 h3 NOT STARTED — heartbeat 29.5% at close prep, a
  full Major ceremony (~17 pts, run-24 precedent) would cross the 40% wall;
  root cause pinned for run #28: `jq -e .` exit tracks output truthiness,
  so valid-JSON top-level `null`/`false` bases skip the type-named branch
  and emit the parse-branch "does not parse" wording (fail-closed CRITICAL
  either way — wording-only). Anomalies: NONE — 4/4 subagent dispatches
  clean (executor, 2 adversaries, Ratifier), zero repair rounds, zero
  classifier denials. Residue: clean (12 patterns, 0 hits, canary passed)
  before the close commit. BRIEF.md regenerated to run-27 state,
  brief-check PASS pre-close (close law honored). Stopped: condition 1
  (TIER-3 — the merge is the operator's button) + condition 4 (29.5% at
  close prep; ITEM 2's Major ceremony would cross the wall). Task budget
  1/5 used. Rolls to run #28: h3 DI wording note (Major, FIRST PICK, spec
  pinned) · standing queues.

- **mission-loop run #27 DECLARED (2026-07-17 system clock; FRESH SESSION per the
  post-run-26 relaunch-declined directive; lock acquired pid-fresh 21948;
  heartbeat at declaration: 18.6% of ceiling, measured):** bootstrap
  observations — (a) origin/main == `500a35b` verified live (`git ls-remote`);
  local main `00042aa` exactly 2 lantern commits ahead (run-26 chain-live +
  relaunch-declined), unpushed, rides the next operator push per standing
  practice. (b) HEAD==main verified at `00042aa` (standing branch-cut ruling).
  (c) No open operator buttons (run-26 chain live, origin CI all green per the
  prior close). (d) Untracked `reports/` still present (operator-side
  artifacts, run-22 observation standing) — left untouched. Plan by leverage
  (all picks from the ratified rolled queue, nothing new): (1) RUN-22 UX NOTES
  (Standard — installer robustness, `adapters/cc/bin/install.sh` only):
  explicit REFUSED status when `context` exists but is not a directory (today
  a regular-file `context` crashes `mkdir -p` raw under set -e — fail-visible
  but not fail-explained) + the hardlink-case comment (a hardlinked
  `context/ubc.md` is undetectable as a link, caught by `-f` → SKIPPED,
  never written — accepted, documented); triggered bench SECURITY +
  REGRESSION (run-22 installer precedent); Ratifier packet; merge = operator
  button. (2) h3 DI WORDING NOTE (declared MAJOR — gate change, always
  Major): top-level `null`/`false` base gadd/BASELINE.json emits the
  parse-branch "does not parse" wording instead of a type-named message
  (still fail-closed CRITICAL — wording-only tightening on both
  02-lane-violation.sh copies, governed fence, accept = operator's own
  hands), as budget allows.

- **2026-07-17 (system clock) · POST-RUN-26 RELAUNCH DECLINED IN-SESSION (operator:
  "Relaunch the loop"):** heartbeat measured 47.5% of ceiling after the
  operator-driven merge/push extension — past the P1 wall; relaunch = FRESH
  SESSION (stop condition 4 honored over the relaunch instruction's letter,
  per the loop's own law and the post-run-24 precedent at 44.3%). Lock
  acquired pid 1360 for the measurement, released clean. RUN #27 NOT STARTED
  HERE; first picks on relaunch: run-22 UX notes · h3 wording note ·
  standing queues.

- **2026-07-17 (system clock) · RUN-26 CHAIN LIVE ON ORIGIN:** operator approved
  the merge and gave the push word in one message ("approve — execute the merge
  … honoring all 7 Ratifier STOPs; no accept due … then push on my word:
  push"). Merge `a32bb15` --no-ff executed, ALL 7 STOPS VERIFIED at the merge
  commit (receipts in the state row above). Push `479051f..500a35b` hook-gated
  PASS, residue clean pre-commit. ORIGIN CI ALL GREEN on `500a35b`:
  gadd-ratchet SUCCESS · gadd-tests SUCCESS (the new 20-assert brief corpus
  running on origin) · gadd-redteam SUCCESS. `mission/run-26-briefcheck`
  deleted (`-d`, push confirmed) per the retain-until-push-confirmed rule.
  BRIEF.md updated to executed state (decisions: nothing pending);
  brief-check PASS re-verified from main's own live copy post-merge. The
  brief-freshness close-check is now LAW: every future run close regenerates
  BRIEF.md and must pass `bin/brief-check.sh`. No open buttons; run #27 =
  fresh session (run-22 UX notes · h3 · standing queues).

- **mission-loop run #26 CLOSE (same session; 1 item completed, MERGE-READY;
  heartbeat at close prep 35.4% of ceiling, measured):** ITEM 1 BRIEF-CHECK
  BUILD (Standard — the operator-ratified run-25 decision-2 spec, §5 of
  `audits/brief-freshness-eval-v1.md`) — `mission/run-26-briefcheck` tip
  `6ea61a1` (`6474e60` instrument + `99ed6f3` corpus + `6ea61a1` close-law
  line): `bin/brief-check.sh` derives N from the lantern's topmost DECLARED
  entry (anchored ERE `^- \*\*mission-loop run #([0-9]+) DECLARED`;
  no-DECLARED or unreadable lantern → exit 2 fail-closed), reads BRIEF.md's
  header line only, word-boundary extraction (run #250 never satisfies N=25),
  exit 1 naming BOTH numbers on staleness, exit 1 on missing/unreadable brief;
  `tests/brief-fixtures.sh` 20/20 (fresh PASS · stale FAIL both-numbers ·
  rolls-to-vacuity pin · missing-brief · no-DECLARED exit 2 never-silent ·
  #250/#25 both directions · CLOSE-entry-above-DECLARED immunity); close-law
  line in `.claude/commands/mission-loop.md` byte-exact to the ratified
  decision-2 text. LIVE BOTH-DIRECTION RECEIPT: stale direction bit on the
  real tree mid-run (run-25 header vs closing #26 → exit 1, the exact
  artifact class that triggered the mandate); fresh direction exercised at
  THIS close — BRIEF.md regenerated then brief-check PASS before the close
  commit (the new close law's FIRST enforcement, Ratifier STOP-5 close half).
  Suites at tip: failclosed 32 · fleet 81 · heartbeat 69 · inapplicability 8 ·
  parity 40 · signer 60 · brief 20 (new). BENCH 2/2 ROUND 1 zero blockers,
  isolated: SECURITY PASS (corpus scratch hygiene mktemp-scoped clean; 3 low
  notes disclosed — ANSI/OSC passthrough in FAIL echoes of local gitignored
  content · missing `--` on one head call, fails conservatively ·
  fail-closed paths sound under pipefail) · TEST_HONESTY PASS (mutation
  battery on scratch copies: comparison-flip / no-DECLARED-exit-0 /
  missing-brief-exit-0 / last-vs-first-DECLARED all KILLED; word-boundary-
  class removal SURVIVED → Director equivalence receipt: extensionally
  equivalent across 6 edge inputs, greedy `[0-9]+` consumes all digits with
  or without the explicit boundary class — an unkillable equivalent mutant,
  disclosed not queued; criterion (f)'s observable behavior is enforced by
  full-number comparison, which the corpus kills). RATIFIER:
  APPROVE-CONDITIONAL — item-6 OUT OF SCOPE by its own hands (fence globs
  read live: RED_TEAM/** · .gadd/checks/** · gadd/BASELINE.json ·
  OWNERSHIP.md — none in range; brief-check wired into no acceptance path,
  grep-clean across .gadd/ .github/ gadd/) → NO ACCEPT COMMIT EXPECTED;
  7 receipts reproduced own-hands, 7 STOPs named for the --no-ff merge
  (ancestry/no-squash · exact 3-file surface, zero fence paths · corpus
  20/20 at merge HEAD · sibling suites green at merge HEAD · fresh-direction
  enforced at close · gate PASS findings-[] with no accept forced ·
  close-law line byte-identical at merge tip). ORIGIN CI measured this run:
  ALL GREEN on `479051f` (gadd-ratchet · gadd-tests · gadd-redteam).
  Anomalies: NONE — 4/4 subagent dispatches clean (executor, 2 adversaries,
  Ratifier), zero repair rounds, zero classifier denials. Residue: clean
  (12 patterns, 0 hits, canary passed) before the close commit. Stopped:
  condition 1 (TIER-3 — the merge is the operator's button) + condition 4
  (heartbeat 35.4% at close prep; ITEM 2's full ceremony would cross the
  wall). Task budget 1/5 used. Rolls to run #27: run-22 UX notes (explicit
  REFUSED on regular-file `context`; hardlink comment) · h3 DI wording note ·
  standing queues.

- **mission-loop run #26 DECLARED (2026-07-17 system clock; FRESH SESSION per the
  run-25 chain-live close; lock acquired pid-fresh 75450; heartbeat at declaration:
  20.4% of ceiling, measured):** bootstrap observations — (a) operator opened the
  session via remote control with "push" + "next loop": the pending run-25
  chain-live lantern commit `479051f` was pushed PRE-declaration
  (`db6b2f1..479051f`, pre-push hook fired live, gate PASS with only the standing
  signer MINOR); origin/main == local main == HEAD == `479051f` verified live
  (`git ls-remote`) — zero unpushed commits, first fully-synced declaration since
  the custody ruling. (b) HEAD==main verified (standing branch-cut ruling).
  (c) No open operator buttons. (d) Untracked `reports/` still present
  (operator-side artifacts, run-22 observation standing) — left untouched.
  Plan by leverage (all picks ratified, nothing new): (1) BRIEF-CHECK BUILD —
  RATIFIED FIRST PICK (operator decision 2, run-25 session): Standard packet per
  §5 of `audits/brief-freshness-eval-v1.md` — `bin/brief-check.sh`
  (header-anchored criterion, N derived from the lantern's topmost DECLARED
  entry, fail-closed exit 2 on no-DECLARED) + `tests/brief-fixtures.sh`
  (incl. the rolls-to-vacuity pin) + the ONE ratified close-law line in
  `.claude/commands/mission-loop.md`; triggered bench SECURITY + TEST_HONESTY
  (run-23 precedent); Ratifier packet; merge = operator button. (2) run-22 UX
  notes (Trivial/Standard: explicit REFUSED on regular-file `context`;
  hardlink comment in the cc installer). (3) h3 DI wording note (top-level
  null/false base parse-branch wording), as budget allows.

- **2026-07-17 (system clock) · RUN-25 CHAIN LIVE ON ORIGIN:** push `17fe0bc..db6b2f1`
  executed on the operator's mid-turn instruction — residue clean across all 8
  commits in the range (12 patterns, tree+metadata+message, canaries passed),
  pre-push hook fired live and gated PASS. ORIGIN CI ALL GREEN on `db6b2f1`:
  gadd-ratchet SUCCESS · gadd-tests SUCCESS (the extended heartbeat corpus
  69/69 running on origin) · gadd-redteam SUCCESS. `mission/run-25-heartbeat`
  deleted (`-d`, push confirmed) per the retain-until-push-confirmed rule.
  BRIEF.md updated to executed state (decisions section: nothing pending).
  No open buttons; run #26 = fresh session, first pick the RATIFIED
  brief-check build.

- **2026-07-17 (system clock) · RUN-25 MERGE EXECUTED + BRIEF-CHECK RATIFIED (operator,
  verbatim: "approve decision 1 — execute the merge of mission/run-25-heartbeat
  at ef267ca honoring all 5 STOPs." + "approve decision 2 — ratified: brief
  header line must carry the closing run number derived from the lantern's
  topmost DECLARED entry; build brief-check as a Standard packet in run #26 per
  §5 of audits/brief-freshness-eval-v1.md, including the one-line close-law
  addition." + mid-turn "push"; same session as the run-25 close, lock
  re-acquired pid-fresh 29254):** merge `d1d5a65` --no-ff, HEAD==main verified
  pre-merge (`3b39e0b`). ALL 5 STOPS VERIFIED — receipts in the state row
  above (parents/ancestry · exact 2-file surface, zero fence paths · six
  suites green 69/32/81/8/40/60 · R1 both-direction reproduced at the merge
  commit · gate PASS findings-[] vs origin base, no accept forced). NO ACCEPT
  COMMIT rides this chain — the first governed merge under the custody ruling
  where none is due (Ratifier fence verification). BRIEF-FRESHNESS CLOSE-CHECK
  now RATIFIED AS SPECIFIED (header-anchored criterion + topmost-DECLARED
  derivation + bin/brief-check.sh + tests/brief-fixtures.sh + the ONE
  close-law line in mission-loop.md) — BUILDABLE run #26, Standard packet,
  run-26 FIRST PICK. Push executed on the operator's mid-turn instruction;
  origin CI status recorded in the next entry once measured.

- **mission-loop run #25 CLOSE (2026-07-17 system clock, same session; 2 items
  completed — 1 MERGE-READY + 1 evaluation parked for ratification; heartbeat at
  close prep 33.0% of ceiling, measured):** ITEM 1 BRIEF-FRESHNESS CLOSE-CHECK
  EVALUATION (operator-queued; Standard-as-evaluation, no code shipped) —
  deliverable `audits/brief-freshness-eval-v1.md` (local-private per the audits
  rule). Root cause of the slip class: the close law in mission-loop.md never
  mentions BRIEF.md (duty lived only in the constitution row = vigilance). KEY
  FINDING, receipt-backed: the operator's literal criterion ("BRIEF.md
  references the closing run number") is VACUOUS — the stale run-24 brief
  mentioned "run #25" twice (lines 10/44, the rolls-to section); every brief's
  rolls-to guarantees the next run number appears in the previous brief.
  Pinned interpretation (SR-8 flavor, operator veto): the brief's HEADER LINE
  carries the closing run number; N derived deterministically from the
  lantern's topmost `mission-loop run #N DECLARED` entry (anchored ERE; the
  CLOSE entry never matches, rotation-immune, no-DECLARED → exit 2
  fail-closed). Proposed mechanism (§5): bin/brief-check.sh + acceptance
  corpus tests/brief-fixtures.sh (incl. a rolls-to-vacuity pin) + ONE
  close-law line in mission-loop.md — PARKED, stop condition 2 (the close-law
  line IS the enforcement; BRIEF.md is gitignored so CI/hooks can never see
  it). ITEM 2 h1/h2 HEARTBEAT EMISSION-EXIT HARDENING (Standard — closes the
  run-17 DI r3 stay-open note) — `mission/run-25-heartbeat` tip `ef267ca`
  (`b7c6a62` fix + `ef267ca` tests): all three status-mode jq emission sites
  (garbage-ceiling, unmeasured, measured-success) capture-then-print with
  their OWN exit/empty guards — atomic printf, static fail-closed JSON +
  loud stderr + exit 2, never 0/empty; startup probe proxy RETIRED (header
  comment carries the full run-16/17 lesson history + why any proxy leaves a
  residual class); check mode untouched. Both-direction receipt: pre-fix main
  copy under a residual-class fake jq (probe-shape passes, --arg fails) =
  exit 0 + EMPTY stdout, the fail-open LIVE; post-fix = exit 2 + one-line
  fail-closed JSON. Corpus 52→69 ADDITIVE (scenarios 13 residual-class /
  14 empty-stdout-exit-0 / 15 mechanism pin; scenarios 1–12 byte-stable).
  Suites at tip: failclosed 32 · fleet 81 · heartbeat 69 · inapplicability 8 ·
  parity 40 · signer 60 (Director independently reproduced heartbeat 69/69 +
  failclosed 32/32). BENCH 2/2 ROUND 1 zero blockers, isolated: TEST_HONESTY
  PASS (mutation battery — guard-strip, fallback-exit-0, guard-removal mutants
  all caught; no pre-existing assertion weakened) · DATA_INTEGRITY PASS (only
  status-mode exit 0 is structurally preceded by proven non-empty printf;
  partial-output-then-crash jq fails closed, no partial leak). DI non-blocking
  note DISCLOSED NOT QUEUED: a Byzantine jq emitting well-formed fabricated
  exit-0 JSON slips any emission guard — reproduced IDENTICALLY on pre-diff
  main; pre-existing toolchain trust boundary (same class as a compromised
  bash), not opened by this diff. RATIFIER: APPROVE-CONDITIONAL — item-6
  classified OUT OF SCOPE by its own hands (bin/ instrument + additive tests/
  corpus = free ratchet, not a grader edit; fence globs verified: neither file
  governed → NO ACCEPT COMMIT EXPECTED), 5 receipts reproduced in a throwaway
  worktree (surface, 69/69 + mutation demos, siblings green, R1 both-direction,
  live smoke), 5 STOPs named (tip ef267ca replays exact; surface exactly the 2
  files, nothing rides; suites green at merge commit; R1 reproduces; nothing
  forces an accept/fence edit). Anomalies: NONE — 4/4 subagent dispatches
  clean (executor, 2 adversaries, Ratifier), zero SR-1 repairs, zero
  classifier denials. Residue: clean (12 patterns, 0 hits, canary passed)
  before the close commit. BRIEF.md regenerated to run-25 state BEFORE the
  close commit (the ITEM 1 slip class, not repeated). Stopped: condition 1
  (TIER-3 — the merge is the operator's button) + condition 2 (RATIFICATION
  NEEDED — the close-law line) + condition 4 (heartbeat 33% at close prep;
  ITEM 3's full ceremony would cross the wall). Task budget 2/5 used. Rolls
  to run #26: brief-check build (on ratification) · run-22 UX notes · h3
  wording note · standing queues.

- **mission-loop run #25 DECLARED (2026-07-16 system clock; FRESH SESSION per the
  post-run-24 directive; lock acquired pid-fresh 86089; heartbeat at declaration:
  19.9% of ceiling, measured):** bootstrap observations — (a) origin/main ==
  `17fe0bc` verified live (`git ls-remote`) — the run-24 chain (merge `272742b` +
  accept `17fe0bc`) is LIVE on origin per the prior close; local main `32d8ee9`
  exactly 2 lantern commits ahead (run-24-chain-live close + post-run-24
  directives), unpushed, rides the next operator push per standing practice.
  (b) HEAD==main verified at `32d8ee9` (standing branch-cut ruling). (c) No open
  operator buttons. (d) Untracked `reports/` dir still present (operator-side
  artifacts, run-22 observation standing) — left untouched. Plan by leverage
  (all picks from the ratified rolled queue, nothing new): (1) BRIEF-FRESHNESS
  CLOSE-CHECK EVALUATION (operator-queued run-25 pick, verbatim intent "second
  brief-freshness slip; it deserves a check, not vigilance") — evaluation
  FIRST; any resulting change to the loop's close law or gates PARKS for
  ratification per stop condition 2; BRIEF.md is gitignored/local-private,
  an input to the evaluation. (2) h1/h2 HEARTBEAT EMISSION-EXIT HARDENING
  (Standard, DI-triggered bench; run-17 DI r3 stay-open note): status-mode
  measured emission guards its OWN jq exit status and fails closed, retiring
  the probe proxy. (3) run-22 UX notes (Trivial/Standard: explicit REFUSED on
  regular-file `context`; hardlink comment) + h3 DI wording note, as budget
  allows.

- **2026-07-16 (system clock) · POST-RUN-24 OPERATOR DIRECTIVES (verbatim: "regenerate
  BRIEF.md to reflect the current state — it still shows run #23, and a stale
  brief is decision-#17 territory. Also queue for run #25: evaluate a
  deterministic close-check that fails a run close if BRIEF.md does not
  reference the closing run number — second brief-freshness slip; it deserves
  a check, not vigilance. Then relaunch the loop."):** BRIEF.md REGENERATED to
  the run-24 state (decisions-first: nothing pending; chain live; rolls-to-25
  list incl. the new item) — the stale-brief slip is DISCLOSED as
  Director-caused (run-24 closed without touching BRIEF.md; second slip of
  this class, hence the operator's check-over-vigilance queue item).
  BRIEF-FRESHNESS CLOSE-CHECK queued in the roadmap row (evaluate run #25;
  anything touching close law/gates parks for ratification). RUN #25 NOT
  STARTED HERE: heartbeat measured 44.3% of ceiling after the operator-driven
  merge/accept/push extension — past the P1 wall; relaunch = FRESH SESSION
  (stop condition 4 honored over the relaunch instruction's letter, per the
  loop's own law).

- **2026-07-16 (system clock) · RUN-24 MERGE EXECUTED (operator, verbatim: "approve
  merge run-24"; same session as the run-24 close, lock re-acquired pid-fresh
  16372):** `mission/run-24-ditype` merged --no-ff → `272742b`, HEAD==main
  verified pre-merge (`dce7222`). ALL 6 RATIFIER STOPS VERIFIED at the merge
  commit: (1) both 02-lane-violation.sh copies == `3b66e001…` ✓; (2) six suites
  green at merge HEAD — failclosed 32/32 · fleet 81/81 · heartbeat 52/52 ·
  inapplicability 8/8 · parity 40/40 · signer 60/60 ✓; (3) merge introduces
  exactly the 3 declared files (first-parent diff), tests/ range-diff zero
  deletions, RED_TEAM/ + spec/ zero hunks ✓; (4) two parents (no-ff) and
  `d0845e5` an ancestor of `272742b` ✓; (5) no accept rode the merge
  (BASELINE.json + allowed_signers untouched in range) ✓; (6) live gate on the
  un-accepted tip = FAIL with EXACTLY the designed governed-fence CRITICAL on
  .gadd/checks/02-lane-violation.sh + the standing signer MINOR ✓. Accept
  one-liner handed to the operator (their own hands per the standing custody
  ruling; disclosed packet-rule exception per the ratified precedent): set
  accepted_sha → `d0845e54c1216f4364587407cca88de6259c07bd`, subject
  "gadd: accept d0845e5". Push = the operator's next button (merge + accept +
  3 lantern commits). Branch retained until push confirmed.

- **mission-loop run #24 CLOSE (same session; 1 item completed, MERGE-READY;
  heartbeat at close 37.5% of ceiling — the P1 wall, measured):** ITEM 1 DI
  WRONG-TYPE BASE GUARD (Major — gate change; closes the run-21 DI bench note) —
  `mission/run-24-ditype` tip `d0845e5` (`8e6b183` check tightening + `3566a8a`
  fixtures S15–S17 + `d0845e5` S18 SR-1 repair): a valid-JSON-but-wrong-TYPE
  base gadd/BASELINE.json (top level not an object; accept_authors present and
  non-null but not an array of strings) now routes into the EXISTING
  base_baseline_malformed fail-closed branch — CRITICAL naming the violation +
  accept_bad — on BOTH check copies (byte receipt `3b66e001…` both, verified at
  `8e6b183` and tip); absent/null/empty-array accept_authors byte-preserved.
  Both-direction receipts: pre-fix scratch demo = legacy MAJOR nudge only, exit
  0 (the fail-open confirmed live); post-fix = wrong-type CRITICALs; live gate
  on the un-accepted tip → FAIL w/ the DESIGNED governed-fence CRITICAL +
  standing MINOR; simulated accept in a discarded scratch clone →
  PASS-one-MINOR. Suites at tip: failclosed 32 · fleet 81 · heartbeat 52 ·
  inapplicability 8 · parity 40 · signer 60 (48 pre-existing unchanged +
  S15–S18). BENCH 5/5 NET: CF · SECURITY · DATA_INTEGRITY · REGRESSION PASS r1
  zero blockers; TEST_HONESTY FAIL r1 with a REAL corpus gap (array-MEMBER type
  check unmutated — an all→any flip survived the whole suite) → SR-1 repair
  `d0845e5` (S18 mixed-type array; mutation-bite receipt: the mutant fails S18
  assert 48, plus S8 assert 20 incidentally via the empty-array vacuity edge —
  disclosed) → TH PASS r2 (fresh isolated invocation). RATIFIER:
  APPROVE-CONDITIONAL — SIXTH item-6 L-class ruling, classification its own
  hands (all three L-class receipts independently reproduced incl. the mutation
  bite in a throwaway worktree), 6 receipts + 6 STOPs (no-squash/ancestry;
  both-copy byte identity at the merge commit; six suites green post-merge;
  additive-only tests/ diff; designed FAIL-until-accept then PASS-one-MINOR;
  the accept NEVER rides the merge — operator's own hands per the standing
  custody ruling). NEW QUEUE h3 (DI non-blocking note): top-level `null`/`false`
  base emits the parse-branch "does not parse" wording rather than a type-named
  message — still fail-closed CRITICAL, wording-only. Anomalies: (1) SECURITY
  r1 adversary's scratch cleanup attempted a shared-temp wildcard rm -rf —
  classifier-BLOCKED, repo tree read-only throughout (run-22 anomaly class
  repeating). (2) Director cut mission/run-24-heartbeat for ITEM 2, then the
  heartbeat wall fired before any commit — branch deleted clean (`-d`, was ==
  main), disclosed. 9/9 subagent dispatches clean on the work itself (the TH r1
  FAIL is the bench WORKING). SR-1 executions: 1. Residue: clean (12 patterns,
  0 hits, canary passed) before the close commit. Stopped: condition 4
  (CONTEXT THRESHOLD — 37.5% at the wall) + condition 1 (TIER-3: merge, accept,
  and push are all operator buttons). Task budget 1/5 used. Rolls to run #25:
  h1/h2 heartbeat emission-exit hardening · run-22 UX notes (explicit REFUSED
  on regular-file `context`; hardlink comment) · h3 above · standing queues.

- **mission-loop run #24 DECLARED (2026-07-16 system clock; FRESH SESSION per the
  merge-chain close; lock acquired pid-fresh 19172; heartbeat at declaration:
  19.7% of ceiling, measured):** bootstrap observations — (a) origin/main ==
  `9fa136b` verified live (`git ls-remote`); local main `6c3beaf` exactly one
  lantern-close commit ahead (unpushed; rides the next operator push per
  standing practice). (b) HEAD==main verified at `6c3beaf` — FIRST branch-cut
  check under the ratified standing ruling: PASS. (c) No open operator buttons
  (run-22/23 chain live on origin, CI all green per the prior close). Plan by
  leverage (all picks from the ratified rolled queue, nothing new): (1) DI
  WRONG-TYPE BASE GUARD (declared MAJOR — gate change, always Major; full bench
  + Ratifier packet, item-6 L-class tightening candidate): a
  valid-JSON-but-wrong-TYPE base gadd/BASELINE.json (e.g. `[1,2,3]`, or
  accept_authors as a string) slips the `jq -e .` parse guard in both
  02-lane-violation.sh copies (byte-identical `21c1808` at declaration) →
  author factor silently degrades to the legacy nudge path; tighten to
  fail-closed CRITICAL with both-direction fixtures (corpus EXTENSION, never
  narrowing). Leverage trace: direct gate-catch tightening → North Star.
  (2) h1/h2 HEARTBEAT EMISSION-EXIT HARDENING (Standard, DI-triggered bench):
  status-mode measured emission guards its OWN jq exit status and fails
  closed, retiring the probe proxy (run-17 DI r3 stay-open note). (3) run-22
  UX notes (Trivial/Standard): explicit REFUSED on regular-file `context` +
  hardlink-case comment in the cc installer, as budget allows.

- **2026-07-16 (system clock) · MERGE CHAIN EXECUTED + TWO STANDING RULINGS RATIFIED
  (operator, verbatim: "approve merge chain as suggested: run-22-ubc →
  run-22-ubc-installer → run-23-ci → run-23-ownership, in that pinned order,
  honoring all STOPs. The ownership accept comes after the merges, executed by me
  (see ruling below), then I'll call the push. Ruling on the accept park: do NOT
  add a permission rule. Baseline accepts are tier-3 human-always by
  constitution, and once a signer is enrolled the accept must be signed with the
  operator-custodied key anyway — the loop being unable to commit accepts is the
  correct permanent state, not a bug to work around. Record as standing ruling.
  Hand me the prepared accept one-liner when the ownership merge lands and I
  execute it myself. Standing rule ratified: Director verifies HEAD==main before
  every branch cut; a mismatched HEAD is a hard stop, not a warning."):** ALL
  FOUR MERGES LANDED --no-ff on local main, every packet's STOPs verified at its
  merge commit — receipts in the state row above (`5136c70` → `ded81cb` →
  `b2794b6` → `ec40e40`). Gate at final HEAD: FAIL with exactly the DESIGNED
  un-accepted CRITICAL on OWNERSHIP.md + the standing signer MINOR — the
  both-direction receipt's predicted pre-accept state; the operator's accept
  flips it to PASS-one-MINOR (simulated receipt in the run-23 packet). STANDING
  RULING (accept custody, PERMANENT): baseline accepts are tier-3 human-always —
  the loop NEVER commits a BASELINE accept, no permission rule is added, and the
  accept must be operator-executed (signed with the operator-custodied key once
  a signer is enrolled); the harness classifier's denial is ratified as the
  correct permanent fence, closing the run-23 "new park class" as
  working-as-constituted. STANDING RULING (branch cuts): the Director verifies
  HEAD==main before every branch cut; a mismatched HEAD is a HARD STOP, not a
  warning (run-21/run-23 anomaly class, now law). Accept one-liner handed to the
  operator per their explicit instruction (a disclosed exception to the
  no-terminal-commands packet rule — the operator demanded the command); push
  remains the operator's next button after the accept. HEAD==main verified at
  execution start (`04706f0`); lock pid-fresh; residue clean pre-close.

- **mission-loop run #23 CLOSE (same session; 2 items completed, both MERGE-READY;
  heartbeat at close 37.0% of ceiling — the P1 wall, measured):** ITEM 1 CI
  RED-GUARD REPAIR (Standard) — `mission/run-23-ci` tip `7729b2d` (`fe15d62` +
  `7729b2d`): the origin-red gadd-tests (measured this run, closing run-22's
  unmeasured item: ratchet+redteam SUCCESS, gadd-tests FAILURE on `8c8a248`)
  repaired at root cause — `fetch-depth: 0` on both gadd-tests copies (the lone
  omission among siblings; byte pin `fa61f624…` both), signer-suite old-check
  extraction now FAILS LOUD on missing/empty history (corpus TIGHTENING, 59
  assert calls unchanged, vacuous-pass window closed), + run-21 queue item
  BUILT: `timeout-minutes: 10` on gadd-tests+gadd-advisory (both copies
  `f6142fdf…`). Both-direction receipt: shallow clone of the branch dies loud at
  extraction; full corpus green at tip (32·81·52·8·40·48). Bench: SECURITY PASS
  r1 + TEST_HONESTY PASS r1, zero blockers (triggered pair, isolated). RATIFIER:
  APPROVE-CONDITIONAL — FIFTH item-6 L-class ruling, receipts reproduced by its
  own hands, 5 STOPs; merge = operator button. ITEM 2 OWNERSHIP CORPUS NOTE
  (Standard, O-class) — `mission/run-23-ownership` tip `9673960`: the
  operator-ratified run-21 text + amendment written VERBATIM from the pinned
  lantern payload (byte receipt SHA-1 `8e81b4a9` both extractions; governed
  fence `fc932f70` byte-identical main↔tip; diff surface == OWNERSHIP.md only).
  Both-direction gate receipt: un-accepted edit → FAIL w/ CRITICAL on
  OWNERSHIP.md (fence bites); accept simulated in a discarded scratch clone →
  PASS with exactly the one designed MINOR. RATIFIER: APPROVE-CONDITIONAL,
  O-class CONFIRMED by its own hands, 6 receipts, 5 STOPs. **ACCEPT PARKED —
  new park class, disclosed:** the session's harness permission classifier
  DENIED the loop's `git commit` of the BASELINE accept edit (twice; honored as
  a hard fence, not worked around — the scratch sim was a discarded test). The
  accept is a prepared one-liner (accepted_sha → `9673960add…`, subject
  "gadd: accept 9673960"); operator executes it or grants the permission rule.
  Anomalies: (1) Director-caused, SELF-CAUGHT by the diff-surface receipt — the
  ownership branch was first cut while HEAD sat on `mission/run-23-ci` (executor
  left it there; run-21 anomaly class repeating — queue a standing rule:
  Director verifies HEAD==main before every branch cut); first commit `8641c60`
  left dangling-unreferenced, branch re-cut from main `9a867fd`, ALL receipts
  re-produced at `9673960`. (2) The three classifier denials (1 compound + 2
  accept), disclosed above. Subagent dispatches 5/5 clean (executor, 2
  adversaries, 2 Ratifier packets). Residue: clean (12 patterns, 0 hits, canary
  passed) before the close commit. Stopped: condition 3 (heartbeat 37% at the
  wall) + condition 1 (all four built items sit at operator buttons: run-22
  chain ×2, run-23 ×2 + accept + push). Task budget 2/5 used. Rolls to run #24:
  h1/h2 emission-exit hardening · DI wrong-TYPE base guard · run-22 UX notes
  (explicit REFUSED on regular-file `context`; hardlink comment) · the
  HEAD==main branch-cut standing-rule proposal.

- **mission-loop run #23 DECLARED (2026-07-16 system clock; FRESH SESSION per run-22
  close; lock acquired pid-fresh 26499; heartbeat at declaration: 9.1% of ceiling,
  measured):** bootstrap observations — (a) origin/main still `8c8a248` (verified
  `git ls-remote`); local main 2 lantern commits ahead (unpushed); the run-22 UBC
  merge chain (`903ac05` → `3f688ca`) still parked at the operator's buttons,
  untouched between sessions. (b) ORIGIN CI NOW MEASURED (closes run-22's
  unmeasured item): on `8c8a248` gadd-ratchet SUCCESS · gadd-redteam SUCCESS ·
  **gadd-tests FAILURE — a red guard on origin main, diagnosed with receipts**:
  the workflow checkout is shallow (CI log: `fetch-depth: 1`) while
  `tests/signer-fixtures.sh`'s both-direction red-run extracts the pre-upgrade
  check-02 from history (`OLD_CHECK02_REF=44f09ed`) → CI log `fatal: invalid
  object name '44f09ed'` → empty old-check script → red-run S2–S5 "old check
  finds nothing" assertions passed VACUOUSLY; assertion 47 (the only one
  requiring a finding to EXIST) caught it and failed the suite — fail-visible,
  the corpus working, but the vacuous-pass window is a test-honesty gap to close
  in the same repair. Local runs were never affected (full clone; 48/48 in
  run-21/22 benches). Every sibling workflow (ratchet, redteam, advisory, both
  copies each) already pins `fetch-depth: 0`; gadd-tests is the lone omission.
  Plan by leverage: (1) RED-GUARD REPAIR of the shipped run-21 citests item
  (Standard) — `fetch-depth: 0` on gadd-tests (both copies byte-identical),
  fail-loud old-check extraction in the signer suite (corpus TIGHTENING, never
  narrowing), + the run-21 ratified queue item `timeout-minutes` on PR-triggered
  jobs (gadd-tests + gadd-advisory, uniform) as a separate commit on the same
  branch; SECURITY-triggered bench + deterministic receipts. (2) ITEM 3
  OWNERSHIP wording O-class edit (operator-ratified run #21 w/ amendment,
  payload pinned verbatim in the run-22 close entry below) — accept dance +
  Ratifier O-class receipt. (3) h1/h2 · DI wrong-TYPE base guard · run-22 UX
  notes, as budget allows.

- **mission-loop run #22 CLOSE (same session; 2 items completed, both MERGE-READY at
  the operator's tier-3 buttons; heartbeat at close ≈40% of ceiling — the P1 wall,
  measured):** ITEM 2 PROPORTIONAL-UBC (Major, full bench) — `mission/run-22-ubc`
  `903ac05`: line 3 replaced by the 4 ratified lines, SHA `03dcee0e…` reproduced
  independently by the Director, DATA_INTEGRITY, and the Ratifier; every other
  byte incl. title unchanged; rejection-ledger row (Karpathy origin, adapted;
  primary-semantic / keyword-plausible-UNMEASURED) rode the packet. Bench 5/5
  ROUND 1 zero blockers (CF · TH · SECURITY · DI · REGRESSION, isolated;
  REGRESSION ran all six suites green: failclosed 32 · fleet 81 · heartbeat 52 ·
  inapplicability 8 · parity 40 · signer 48). RATIFIER: APPROVE-CONDITIONAL,
  item-6 classified OUT-OF-SCOPE by its own hands (agent-owned lanes, not a
  grader), 6 receipts, 5 STOPs (no-squash; one-designed-MINOR gate; SHA pin at
  merge HEAD; two-file surface; ITEM 1 never rides this verdict). ITEM 1
  INSTALLER-SHIPS-UBC (Standard) — `mission/run-22-ubc-installer` `e9114b8` +
  SR-1 repair `3f688ca`: skip-if-exists, never overwrites CLAUDE.md/context
  files, ONE suggestion-only line (a two-line first draft was Director-caught as
  deviating from the ratified "ONE line" and repaired pre-bench, disclosed);
  receipts R1–R7 reconstructed from the in-repo lantern summary (R5 residue-grep
  and R6 shipped-SHA at their lantern-named positions; Ratifier judged the
  reconstruction faithful per SR-6). Bench: SECURITY FAIL r1 with a REAL
  demonstrated CWE-59 blocker (symlinked `context`/dangling `context/ubc.md` →
  cp writes through the link OUTSIDE the target repo) → SR-1 fail-closed
  refusal fence → SECURITY PASS r2 (7 probe classes dead, canary intact);
  REGRESSION PASS r1 (26 pre-existing artifacts byte-identical, +1 file only,
  idempotent). RATIFIER: APPROVE-CONDITIONAL, tier-3 item-5 examined NOT
  engaged, 6 merge-chain receipts, 5 STOPs. ITEM 3 OWNERSHIP WORDING **DEFERRED
  to run #23** (ceiling, not blockage) — PAYLOAD PINNED HERE verbatim per the
  payload rule (BRIEF.md gets rewritten; this entry is now the in-repo source).
  Ratified text = append to OWNERSHIP.md's Agent-owned section, plus the
  operator's amendment marking the `tests/**` mention "(see note below)":

  > **On `tests/` and `RED_TEAM/`:** "agent-owned" above means *not gated by the
  > deterministic lane check (#2)* — agents add and refine fixtures during normal
  > ratified development. It does NOT mean ungoverned. The `tests/` and `RED_TEAM/`
  > fixture corpus is the operator-owned *ratified corpus* (charter item-6): the
  > Ratifier's L-class whole-corpus-preservation receipt forbids narrowing it,
  > CODEOWNERS requires operator review of external-PR changes to it, and CI
  > (`gadd-tests`) re-runs it. A proposer may extend or tighten the corpus; only the
  > operator may narrow or weaken it.

  Anomalies (all disclosed, none repo-impacting): harness flagged the ITEM 1
  executor's `--amend` (its own unpushed commit, Director-instructed — benign);
  SECURITY r1 adversary's scratch cleanup used a shared-/tmp glob (harness-
  flagged hygiene, tree access stayed read-only); an orphan background CI poller
  in the session task dir burned 20 attempts against the GitHub 503 wall
  (read-only, benign). 13/13 substantive subagent dispatches clean on the work
  itself (the SECURITY r1 FAIL is the bench working). SR-1 executions: 1 (ITEM 1
  symlink fence) + 1 Director-caught pre-bench deviation repair. Residue: clean
  (12 patterns, 0 hits, canary passed) before the close commit. NEW QUEUE from
  run-22 bench notes: (a) regular-file `context` in a target repo aborts the cc
  install mid-run via set -e with no message (safe/fail-closed but partial-
  install UX — add explicit REFUSED); (b) comment the hardlink case in the skip
  logic so a refactor doesn't reopen it (its safety is incidental to the -f
  branch). Stopped: condition 1 (TIER-3 — both merges at the operator's button)
  + condition 4 (heartbeat ≈40%, the P1 wall). Task budget 2/5 used. h1/h2 +
  run-21 queue items (DI wrong-TYPE base, timeout-minutes) roll to run #23.

- **mission-loop run #22 DECLARED (2026-07-16 system clock; FRESH SESSION per run-21
  close; lock acquired pid-fresh 9718; heartbeat at declaration: 18.9% of ceiling,
  measured):** bootstrap observations — (a) origin/main == local main at `8c8a248`
  VERIFIED live (`git ls-remote`): the operator pressed the PUSH button between
  sessions; the run-21 chain (signer merge `19d3243` + citests merge `923906d` +
  lantern closes) is LIVE on origin. That tier-3 button is CLOSED. (b) Origin
  Actions status UNMEASURED at declaration (GitHub API 503 twice) — re-check
  queued within this run; reported unmeasured until then. (c) Untracked local
  `reports/` dir observed (operator-side visual-report artifacts, e.g.
  `ubc-portabilidad-decision.html`) — not repo content, left untracked, no action.
  (d) Pinned UBC payload SHA-1 re-verified at declaration: `03dcee0e…` reproduced
  byte-exact from the log entry below. Plan by leverage (all picks
  operator-ratified, nothing new): (1) ITEM 2 proportional-UBC rewrite of
  [context/ubc.md](context/ubc.md) — MAJOR (always-applied standards layer; full
  bench + Ratifier packet; exact bytes already operator-ratified, merge still the
  operator's button); wave order pinned ITEM 2 → ITEM 1, not reordered.
  (2) ITEM 1 cc-installer ships ubc.md (Standard, R1–R7 incl. R6 shipped-SHA ==
  post-ITEM-2 SHA). (3) OWNERSHIP wording O-class edit (co-ratified run-22 pick,
  leverage-ordered AFTER the UBC wave: the wave feeds the external-shipping
  surface of the coverage-proxy growth path; the OWNERSHIP edit is
  disclosure-only, unblocks nothing). Then h1/h2 + run-21 queue items (DI
  wrong-TYPE base guard · timeout-minutes on PR CI jobs) as budget allows.

- **2026-07-16 (system clock) · RUN #21 MERGES EXECUTED + OWNERSHIP WORDING RATIFIED
  (operator, mid-turn: "approve merge run-21-signer and run-21-citests", then
  "Approve the OWNERSHIP wording as drafted, with one amendment: the Agent-owned
  table row for tests/** gains the marker '(see note below)' so a table-only reader
  is routed to the clarification. Nothing else changes."):** BOTH MERGES LANDED on
  local main (unpushed) — signer `19d3243` (5 STOPs verified: no-squash, gate PASS
  one-MINOR, byte-identity `a8a94e7…bdc01`, no forbidden surface, operator button)
  + citests `923906d` (gadd-tests.yml `227c0d4…` both copies, full corpus green
  incl. signer 48/48, gate PASS, residue clean). Final local tip `923906d`. PUSH
  is the next operator button (not assumed — narrow approval was "approve merge",
  and push publishes + fires the pre-push hook and origin ratchet; main = human
  territory). ITEM-3 OWNERSHIP WORDING now OPERATOR-RATIFIED with amendment —
  BUILDABLE run #22 (governed-file edit → needs the `gadd: accept` dance; prose/
  disclosure-only, no fence-glob or enforcement change → O-class, Ratifier O-class
  receipt: byte-identical verdicts across the ratified corpus + diff-outside-
  verdict-computation). EXACT RATIFIED TEXT = the BRIEF.md §3 draft (the "On
  `tests/` and `RED_TEAM/`" note appended to OWNERSHIP.md's Agent-owned section),
  VERBATIM. AMENDMENT (pinned, with a faithful-execution note): mark `tests/**`
  where it appears in the Agent-owned listing with "(see note below)" so a reader
  who scans only the listing is routed to the clarification — NOTE the listing is
  inline prose, not a literal table (the operator said "table row"); the intent is
  the marker on the tests/** entry, nothing else changes. NOT built this session:
  context at 47.4% (past the 40% ceiling) — starting a governed O-class packet here
  would be dumb-zone work; run #22 (fresh session) builds it. Sequencing: does NOT
  reorder the UBC-portability wave's pinned ITEM 2→ITEM 1 first-picks; the OWNERSHIP
  O-class edit is a co-ratified run-22 pick, leverage-ordered at the run-22
  declaration without touching the UBC pin.

- **2026-07-16 (system clock) · WAVE "UBC PORTABILITY" OPERATOR-RATIFIED (verbatim:
  "Approve the wave as packeted: ITEM 2 exact text ratified as quoted (title
  stays), rejection-ledger placement accepted, lv scope gap accepted as chosen,
  truth-note on the ultrathink rationale accepted as primary-semantic /
  keyword-plausible-unmeasured. Queue position behind run-21's ratified picks
  confirmed — do not reorder.or run 22 if is already shipped"):** queue resolved
  to RUN-22 FIRST PICKS — run #21 closed before this approve landed (its two
  merges park at the operator's tier-3 buttons, which are operator actions, not
  loop picks; the "run 22" fallback the approve itself names). SEQUENCE PINNED:
  ITEM 2 lands BEFORE ITEM 1 in the same wave, so the first UBC ever shipped
  externally is already the proportional version. ITEM 2 (MAJOR — [context/](context/)
  is the always-applied standards layer; full bench + Ratifier packet + operator
  ratifies the exact bytes before merge): [context/ubc.md](context/ubc.md) line 3
  ("For EVERY task, ultrathink before coding.") is replaced by the ratified block,
  pinned verbatim here as the in-repo payload source (rejection-ledger rule:
  payloads never live only in conversation); byte-exact receipt SHA-1
  `03dcee0e7d711e66d9923e8284cebcd7e53d3d5a` (the 4 lines below, LF line endings,
  trailing newline):

  ```
  Think in proportion to the task's tier:
  - Trivial — the standing rules below; no extended-thinking trigger.
  - Standard — think before coding or writing.
  - Major — ultrathink before coding.
  ```

  Every other line of ubc.md byte-for-byte INCLUDING the title line (operator:
  "title stays" — still truthful, ultrathink remains the Major form). Retired-
  wording rationale recorded per the ratified truth-note: PRIMARY = instruction
  semantics (an unconditional "ultrathink every task" order contradicts §6
  proportionality however the keyword mechanics resolve); the keyword-budget
  effect via CLAUDE.md-imported text = plausible, UNMEASURED — reported as such,
  never as fact. Rejection-ledger row (origin: Karpathy's "think before coding"
  principle, adapted; unconditional variant retired) rides the ITEM 2 packet,
  written then, not before. ITEM 1 (STANDARD):
  [adapters/cc/bin/install.sh](adapters/cc/bin/install.sh) ships `context/ubc.md`
  skip-if-exists (the RED_TEAM guard pattern already on its line 12); NEVER
  overwrites any pre-existing CLAUDE.md or context file (skip + say so in the
  install output); output gains ONE suggestion-only line (the deployment applies
  its own import — no automated edit of the target's CLAUDE.md). Receipts as
  packeted R1–R7, incl. R6 shipped-SHA == post-ITEM-2 ubc.md SHA (mechanically
  impossible to ship the unconditional wording) and R5 residue grep (current
  file verified clean live — zero gadd paths; "the ratchet"/"tier" vocabulary is
  deployment-generic, disclosed). lv SCOPE GAP ACCEPTED AS CHOSEN: UBC ships only
  via cc (culture applies where the agent loop runs); extending to lv-only
  deployments = separate future ruling. Root `bin/install.sh` verified a pure
  dispatcher (execs the adapter script) — no second surface to touch.

- **mission-loop run #21 CLOSE (same session; 2 items completed, both MERGE-READY at
  the operator's tier-3 button; heartbeat at close ~31% of ceiling, measured):**
  ITEM 1 ACCEPT-SIGNER (item-6, Major, full bench) — built to
  `audits/accept-signer-design-v1.md` under the operator's 3 ratified answers.
  Round-1 bench: CF PASS · TH PASS (48-scenario suite + mutation battery) ·
  SECURITY/DATA_INTEGRITY/REGRESSION FAIL with 3 REAL demonstrated blockers
  (trust-anchor smuggling: an unsigned commit touching ONLY `gadd/allowed_signers`
  alongside a legit signed accept widened the base anchor — full accept-gate
  compromise on an ENROLLED deployment, proven MISSED by the round-1 check; +
  enroll-later path bricked; + installer 3-field-`.pub` misclassification wrote
  `ssh-ed25519` as the principal so no accept ever verified). SR-1 repair round 1
  (`8947b1f`): combined pathspec `-- gadd/BASELINE.json gadd/allowed_signers` so
  every signers-touching commit is itself accept-verified; legacy-first-enrollment
  exemption (subject+author only, no signature, when base has no signers);
  malformed-base-BASELINE fail-closed CRITICAL. Round-2 re-bench of the 3 failed
  adversaries: ALL PASS (SECURITY also probed evil-merge/history-simplification,
  delete-re-add, ratchet-dodge — all fail closed). NET BENCH 5/5. RATIFIER:
  APPROVE-CONDITIONAL, **item-6 L-class (4th such ruling)**, 10 receipts
  reproduced by its own hands (incl. round-1 smuggle proven MISSED-then-closed,
  git<2.34 fail-closed, monotonicity manifest — no corpus input flips red→green),
  5 STOPs; merge = operator button. Post-accept live gate PASS with exactly one
  MINOR (the designed "enroll a signer, second factor only" disclosure on gadd's
  own unenrolled deployment). Files: both `02-lane-violation.sh` copies
  (byte-identical `a8a94e7ae67f…bdc01`), `adapters/lv/bin/install.sh`,
  `adapters/lv/templates/OWNERSHIP.md` (+`gadd/allowed_signers` fence line),
  `docs/pr-adoption.md`, new `tests/signer-fixtures.sh` (48/48). Prior suites all
  green (failclosed 32 · inapplicability 8 · parity 40 · heartbeat 52 · fleet 81).
  ITEM 2 CI-RUNS-TESTS (Standard) — `mission/run-21-citests` `eaa5396`:
  `gadd-tests.yml` runs every `tests/*.sh` on push+PR, fails the job after running
  all, glob-based (auto-picks up new suites), signal-only, dual-located
  byte-identical, ships via the existing installer glob. SECURITY PASS (plain
  `pull_request` not `pull_request_target`, `contents: read`, no secrets, no
  `${{}}` injection, injection-safe glob, strict subset of the ratified advisory
  pattern). NO accept commit (not a governed-lane edit). ITEM 3 OWNERSHIP-vs-item-6
  WORDING drafted as a RATIFICATION PROPOSAL, NOT self-served (invariant-grade,
  SR-8): the tension is that the charter (item-6) names `tests/`+`RED_TEAM/` the
  operator-owned ratified corpus ("proposer may not narrow it") while gadd's own
  OWNERSHIP.md lists `tests/**` under "Agent-owned (free to modify)" and the
  gadd-governed fence omits `tests/` (lane check blind). Root cause: "own" is
  overloaded — OWNERSHIP.md means "not gated by the deterministic lane check #2",
  the charter means "operator-owned corpus, protected from NARROWING by the L-class
  whole-corpus-preservation receipt + CODEOWNERS + CI". Proposed reconciliation
  text quoted in BRIEF.md; both readings are honest and enforcement is UNCHANGED —
  it's a clarifying disclosure edit to OWNERSHIP.md (a governed file → needs accept
  + it's charter-adjacent) so it parks for the operator. Anomalies: one
  Director-caused, self-caught — the first close commit landed on
  `mission/run-21-signer` (HEAD had followed the executor onto that branch) instead
  of main, which would have injected LANTERN.md into the Ratifier-verified signer
  packet (breaking STOP-4). Caught immediately on branch inspection; repaired by
  cherry-picking the close onto main (`7a2d147`) and `git branch -f`-ing the signer
  branch back to its ratified tip `6cd5411`; re-verified the packet
  `44f09ed..6cd5411` has zero LANTERN content. 12/12 subagent invocations clean
  (the 3 round-1 bench FAILs are the bench WORKING, not anomalies; the SR-1 repair
  is logged). SR-1 executions: 1 (repair round 1). Residue: clean (12 patterns, 0
  hits, engine canary passed) — run before the close commit. Stopped: condition 1 (TIER-3 — both items
  at operator merge buttons) + condition 2 (RATIFICATION NEEDED — the OWNERSHIP
  wording proposal). Task budget 2/5 used; context healthy (~31%) but a tier-3
  wall is the right close. NEW QUEUE from run-21: (a) DI note — valid-JSON-but-
  wrong-TYPE base BASELINE.json (e.g. `[1,2,3]`, or accept_authors as a string)
  slips the parse guard and silently drops the author factor to a MAJOR nudge
  (low impact — base trust-pinned, enrolled path still gates on signature; L-class
  tightening candidate); (b) `timeout-minutes` on PR-triggered CI jobs (gadd-tests
  AND the already-merged gadd-advisory — uniform hardening, generic public-repo
  abuse class, SECURITY note, not introduced by this run); (c) additive-MINOR
  stacking awareness — external adopters carrying 2 pre-existing MINORs newly FAIL
  on a legacy accept until they enroll a signer (design-accepted, operator-aware
  at merge). h1/h2 heartbeat-emission-exit hardening still QUEUED, deferred to
  next run.

- **mission-loop run #21 DECLARED (2026-07-16 system clock; FRESH SESSION per run-20
  close; lock acquired pid-fresh; heartbeat at declaration: 19.5% of ceiling):**
  standing ratifications loaded (post-run-20 entry below). Plan by leverage:
  (1) ACCEPT-SIGNER BUILD — first pick, item-6 (Ratifier classifies), declared
  tier MAJOR (grader change, always Major; full bench): build to
  `audits/accept-signer-design-v1.md` under the operator's 3 ratified answers
  (dedicated gadd-accept keypair / accept_authors permanent second factor / CI
  also runs the signature check pubkeys-only). INTERPRETATION PINNED PRE-BUILD
  (SR-8 flavor, disclosed for the Ratifier + operator veto): design step-1
  "nudge escalated MINOR→MAJOR" read literally as escalating the EXISTING
  accept_authors-missing nudge; a deployment with accept_authors SET but no
  enrolled signer gets an ADDITIVE MINOR disclosure nudge, not MAJOR — the
  alternative reading (MAJOR whenever base lacks signers) would gate-FAIL this
  very packet's own accept commit and hard-block naked deployments' genesis
  enrollment push, contradicting the design's own "no flag day / step-2 gated
  by the old %ae check one last time" text; genesis-window suppression (head
  enrolls → escalation suppressed to disclosure) pinned for the same reason.
  Ratchet rule pinned as STATE comparison (base signers non-empty AND head
  signers empty/absent → CRITICAL), since rotation commits ride pre-accept in
  the same push. (2) CI-runs-tests wiring (Standard, promoted). (3) OWNERSHIP
  wording fix. Then h1/h2 + queues as budget allows. Origin-state observation
  logged in the branch row above.

- **2026-07-16 · POST-RUN-20 OPERATOR RATIFICATIONS (all three, verbatim-quoted in
  the dispatch):** (1) ACCEPT-SIGNER DESIGN RATIFIED with answers — (a) DEDICATED
  gadd-accept keypair, never the personal GitHub key; "the private key is a tier-3
  secret with its own lifecycle"; (b) accept_authors KEPT PERMANENTLY as second
  factor; (c) CI ALSO runs the signature check, pubkeys only. BUILD = RUN #21
  FIRST PICK (item-6, Ratifier classifies; design + probe receipts in
  audits/accept-signer-design-v1.md). (2) CODEOWNERS RATIFIED as a PRECISE DELTA
  (run-19 text + /tests/ + /bin/, nothing else) — WRITTEN + COMMITTED `11a2fce`,
  receipt DELTA-EXACT (empty diff vs run-19 text + the two lines); "CI runs
  tests/*.sh" DX item PROMOTED (approved, queue → build). (3) OWNERSHIP.md-vs-
  item-6 wording tension APPROVED for the queue, invariant-grade fix. RUN #21 =
  FRESH SESSION (confirmed), first picks: signer build (Standard/Major, full
  ceremony, with the three answers as constraints) · CI-runs-tests wiring ·
  OWNERSHIP wording fix · then h1/h2 + remaining queues. Local main now 2 ahead
  of origin unpushed (`b373410` run-20 close + `11a2fce` CODEOWNERS) — next
  chain or "push main" carries them.

- **mission-loop run #20 DECLARED (same session, 86% ceiling at declaration —
  compact run; operator: "approve merge — execute the run-19 chain… CODEOWNERS: read
  in full. One question before I ratify — [tests/ corpus vs agent-owned lane]…
  Relaunch the loop (next pick: item 3 accept-signer, design-first as planned).")**
  — run-19 chain EXECUTED: merged `d2106f5` --no-ff, ALL 6 receipts green at the
  merge commit (gate PASS 0 findings base `aa0b9e3` · failclosed 32/32 · fleet
  81/81 · parity 40/40 · byte pins ×2 · accept diff 1-line · main not
  branch-protected so advisory trivially non-required), pushed `2fbb39d..d2106f5`
  hook PASS. CODEOWNERS QUESTION ANSWERED WITH RECEIPTS (operator's concern
  CONFIRMED): tests/ fixture-weakening via external PR is caught by NOTHING
  deterministic today — OWNERSHIP.md lists tests/** agent-owned (lane check blind),
  zero workflows/hooks execute tests/*.sh (grep receipt), Ratifier sees packets not
  PRs; CODEOWNERS AMENDED to add /tests/ + /bin/ (same logic, North Star
  instruments), pending ratification; flagged: promote DX item "CI runs tests/*.sh"
  (deterministic complement) + OWNERSHIP-vs-item-6 wording tension (SR-8 flavor,
  invariant rewrite queued). Run-20 plan: accept-signer DESIGN PASS (isolated
  design agent, read-only; proposal → operator ratification, build next run).
  **CLOSE (same entry):** DESIGN PASS DONE — `audits/accept-signer-design-v1.md`
  (local-private): RECOMMENDED = SSH commit signing verified against a BASE-PINNED
  `gadd/allowed_signers` (trust anchor read from GADD_BASE only — probe showed a
  working-tree anchor loses to self-enrollment, the base-pinned anchor defeats it;
  audit probe-F spoof dead; spoof+sign dead via principal matching); GPG rejected,
  token-file = git<2.34 fallback, GitHub API = CI supplement only; 5-step
  monotonic migration (legacy %ae fallback with escalated nudge, signed genesis
  accept, installer closes the fresh-install window); 3 open questions for the
  operator (design file + brief). AWAITING RATIFICATION — build = next run's
  first pick once ratified (item-6, Ratifier classifies). LOG-REPAIR DISCLOSED:
  the run-20 declaration edit accidentally consumed the run-19 entry's header
  line; restored verbatim in this same edit — append-only intent preserved, the
  defect and repair both named. Anomalies: that one (Director-caused, self-caught)
  — 1/1 subagent invocation clean. Stopped: conditions 2 (RATIFICATION NEEDED:
  signer design + amended CODEOWNERS await the operator) + 4 (88% of ceiling at
  design return — NEXT RUN MUST BE A FRESH SESSION). Session totals runs #16–#20:
  5 runs, 3 merges landed on origin (`2aeae9f` `2fbb39d` `d2106f5`) + run-16
  charter/close pushes, 3 item-6 L-class rulings, 2 audits, 1 design pass, 12/12
  subagent invocations clean, residue clean at every close.

- **mission-loop run #19 DECLARED (same session; operator ruled on the PR-flow queue,
  verbatim: "1. APPROVED — base_sha canonicalization + ancestry + explicit
  squash-incompatibility error. Ratifier classifies under item-6 with receipts.
  2. PENDING MY READ — quote the proposed CODEOWNERS text verbatim in your next
  brief (or reply). I ratify governance text only after reading it. 3. APPROVED —
  verifiable accept-signer replacing %ae. Ratifier classifies under item-6 with
  receipts. 4. APPROVED — build the adoption note (Standard). 5. APPROVED — build
  the PR-time advisory ratchet run, non-gating (Standard). Relaunch the loop.
  Tier-3 merges remain my button as always.")** — CODEOWNERS text quoted verbatim
  in the reply + brief per ruling 2. Run-19 plan by leverage: (1) item-1 gate
  hardening first (full ceremony), then items 4+5 (Standard builds) as budget
  allows; item-3 accept-signer DEFERRED to a design-first pass next run (grader
  redesign deserves fresh-session ceremony, not end-of-session context — disclosed,
  not silent). **CLOSE (same entry):** ITEMS 1+4+5 BUILT on `mission/run-19-prflow`
  (`7b66d5a` hardening H + `aa0b9e3` advisory workflow + adoption note + `cd37bc0`
  accept commit — one packet per item 6's own text). Hardening H: base
  canonicalization + ancestry assertion, non-ancestor → loud CRITICAL squash-
  incompat refusal; scenario-5 fixtures both-direction (red 4/4 pre-H; one fixture
  bugfix disclosed: `git checkout -` after orphan checkout), failclosed 32/32,
  prior 23 byte-stable, installed copy byte-identical `81c07fdb`, live gate PASS
  post-accept (base `aa0b9e3` canonical). Advisory workflow byte-identical
  `34fc0c93` both copies, ships via existing installer glob; adoption note
  normative (merge-commit only, integration ≠ acceptance). BENCH: DI PASS r1 +
  REGRESSION PASS r1, zero blockers (REGRESSION confirmed fleet 81/81, parity
  40/40, installer end-to-end, shallow-clone false-negative unreachable from
  shipped paths; DI confirmed canonicalization spelling-only, no red→green).
  RATIFIER: APPROVE-CONDITIONAL — THIRD item-6 L-class ruling (canonicalization
  nuance judged: verdict-field byte-delta on non-canonical spellings trips no
  escape trigger, pinned by 5b), 6 receipts, 4 STOPs (no-squash fence; gate re-run
  at merge HEAD). ITEM 2 (CODEOWNERS) still PENDING operator read — text quoted
  verbatim in reply + brief. ITEM 3 accept-signer DEFERRED to design-first next
  run. Anomalies: none — 3/3 subagent invocations clean; one own-fixture bug
  caught by the pre-fix red run (the receipts discipline working on the Director).
  SR-1 executions: 0 repairs (bench passed r1 both). Stopped: condition 1 (TIER-3
  — merge at the operator's button) with condition 4 approaching (82% of ceiling
  at close, measured). Heartbeat dogfooded throughout. (same session; operator dispatch: "approve merge —
  execute the run-17 chain per the Ratifier's receipts and STOPs. Then relaunch the
  loop for run #18. Also add to the standing queue if not already there: PR-flow
  readiness audit — verify gadd's acceptance chain works when merges to main happen
  via approved PRs (merge commit and squash): accept_authors allowlist attribution,
  baseline advance target, and CODEOWNERS mapping for tier-3 surfaces. This gates
  external-repo adoption.")** — run-17 chain EXECUTED first: merged --no-ff
  `2fbb39d` (all verdict receipts re-run green at the merge commit: 52/52 ·
  baseline-38 vs merged script 38/38 zero flips · parity `4c610410` · residue
  clean), pushed `2aeae9f..2fbb39d` hook PASS, origin ratchet success. PR-FLOW
  READINESS AUDIT queued (new item, operator-ratified) AND picked as run-18 first
  item — leverage trace: it gates external-repo adoption, the coverage-proxy growth
  path of the ratified objective function; ties-by-unblocking-power over h1/h2
  (hardens an already-safe path). Audit is read-only investigation (Standard
  rigor); report local-private per standing rule. **CLOSE (same entry):** AUDIT
  EXECUTED by isolated read-only subagent — 10 surfaces read, 6 merge/squash flows
  simulated in scratch repos, zero repo changes. Verdicts Q1 WORKS / Q2 BREAKS-LOUD
  / Q3 narrow-break / Q4 MISSING; 6 findings (2 CRITICAL: squash wedge fail-closed,
  CODEOWNERS absent fail-open; %ae spoof+self-enroll MAJOR confirmed live by
  probe); 5 queue items with jurisdiction flags → roadmap row, ALL await operator
  ruling (2 are tier-3/item-6, CODEOWNERS is an operator governance act — the loop
  builds none of them unratified). Report: `audits/pr-flow-audit-v1.md`
  (local-private), proposed CODEOWNERS text preserved verbatim. Anomalies: none —
  1/1 subagent invocation clean. Stopped: condition 1 (TIER-3 — every next action
  on this item is an operator ruling). Update also standing: mission-loop.md
  two-copy byte-identity, adapters/cc dep list, run-13 stale-doc fix all LIVE on
  origin via `2fbb39d`.

- **mission-loop run #17 DECLARED (same session as run #16, operator relaunch:
  "push main approved. approve merge for run-16-heartbeat per the Ratifier's receipts
  and STOPs. Then relaunch the loop for run #17.")** — run-16 chain EXECUTED first:
  main pushed (`253d381..2a7ec6a`, hook PASS), merge `2aeae9f` --no-ff (STOP-2
  byte-identity verified pre-merge; post-merge receipts 38/38 + `91cb487f` both
  copies; residue clean), pushed (`2a7ec6a..2aeae9f`, hook PASS); origin
  `gadd-ratchet` + `gadd-redteam` both completed success on `2aeae9f`. Run-17 plan:
  (1) heartbeat sibling fail-opens n1+n2 (Standard, one item — boolean-false
  fabricated tokens-0 + status-mode jq-absent exit 0), (2) Trivial queue docs, close
  on context/budget. **CLOSE (same entry per declaration):** (1) n1+n2 BUILT on
  `mission/run-17-heartbeat-siblings` (`1d93b04` fix + `d50cf7f` repair-1 +
  `ddbc4df` repair-2-at-cap): both defects demonstrated live pre-fix; tier-1
  all-numbers rule + status-mode jq fail-closed; fixtures 11+12 both-direction
  (pre-fix reds 5/5, 4/4, 2/2 per round), mutation demo 4 = the run-16 guard as
  mutant (CONFIRMED insufficient), demo-3 sed retarget DISCLOSED (SR-5, preserved
  its bite); suite 52/52; prior 38 assertions byte-stable. BENCH: DI FAIL r1
  (presence-only jq guard — broken/non-exec jq bypass) → SR-1 repair 1 → DI FAIL r2
  (identity-probe bypass, jq-1.4 generation-broken class — REAL catches both
  rounds) → SR-1 repair 2 AT CAP → DI PASS r3 zero blockers (adversary re-executed
  the bypass classes itself). RATIFIER: APPROVE-CONDITIONAL — SECOND item-6 L-class
  ruling, 6 receipts reproduced by its own hands (incl. baseline-fixtures-38
  against new script: zero flips), 5 STOPs; h1/h2 emission-exit refactor queued
  OPEN (STOP-5). (2) docs/metric-parity.md stale /tmp refs fixed (`e6cf994`,
  Trivial, DISCLOSED post-verdict docs-only rider). Anomalies: none in dispatch —
  5/5 subagent invocations clean (2 DI FAILs are the bench working, not
  anomalies). SR-1 executions: 2 (both repair rounds, receipts in commits).
  Stopped: condition 1 (TIER-3 — merge at the operator's button). Heartbeat at
  close: measured in-session, under ceiling.

- **2026-07-16 (system clock; see drift disclosure in roadmap row) · run #16 CLOSED —
  item-6 LIVE and exercised same run; speed audit v2 measured; 5/5 task budget:**
  operator dispatch: "Proceed with run #16 as agendaed: 1. Item-6 verbatim
  charter-write … (ratified text from brief #15, byte-exact). 2. SPEED AUDIT v2 —
  include the ~30k first-message tax question… 3. Standing queues as listed. Tier-3
  remains human as always." EXECUTED: (1) ITEM-6 VERBATIM WRITE (`53801cd`, local
  main, unpushed): byte-exact receipt SHA-1 `8005f17b` (stripped brief blockquote ==
  written charter block), commit quotes the dispatch; local-private canonical synced.
  (2) SPEED AUDIT v2 (results in roadmap row; audit local-private per standing rule;
  the ORIGINAL v1 parser survived and ran unmodified — parity receipt bit-for-bit).
  (3) STANDING QUEUE: mission-loop.md two-copy reconciliation (live copy adopts
  shipped deployment-neutral wording; byte-identical `a688a601` both) · adapters/cc/
  CLAUDE.md stale dep list fixed (adds heartbeat + plist, matches install.sh) ·
  HEARTBEAT NULL-USAGE FAIL-OPEN CLOSED (`173e3f7` on `mission/run-16-heartbeat`,
  Standard): defect demonstrated live pre-fix ("OK 0/400000 via tokens" on an
  all-null usage object); minimal jq null-guard → labeled bytes degrade; scenario-10
  fixtures both-direction (3/3 FAIL pre-fix), mutation demo 3 bites, suite 38/38,
  prior 32 assertions byte-stable, shipped copy byte-identical `91cb487f`; DI
  adversary PASS r1 zero blockers (isolated, opus); RATIFIER APPROVE-CONDITIONAL —
  FIRST LIVE ITEM-6 L-CLASS RULING (classification the Ratifier's, 5 receipts
  re-verified by its own hands, 3 STOPs incl. n1/n2 stay-open honesty condition).
  Anomalies: none in dispatch — 2/2 subagent invocations clean; residue check run on
  close (result in close commit); Slack brief send SKIPPED as redundant (interactive
  operator dispatch — BRIEF.md written per standing surface; disclosed, not silent).
  Stopped: conditions 5 (task budget 5/5) + 1 (both next actions are operator
  buttons: push main ×2 commits, merge run-16-heartbeat). Heartbeat self-reading at
  close: measured in-session, well under ceiling (P1 dogfooded on its own fix run).

- **2026-07-17 · run #15 — P1 LANDED, charter naming ratified, three operator rulings
  executed:** operator superseding dispatch. (1) P1 heartbeat MERGED --no-ff + PUSHED
  (`65a9f91`), all 6 Ratifier receipts produced (composite all_green · heartbeat 32/32
  · byte-identity bin↔adapters/cc · 6-file scope no-grader · clean-install never-127 ·
  non-force append); the context-ceiling meter is now LIVE in loop step 6. (2) CHARTER
  NAMING AMENDMENT ratified (`33a1dab`, item 7, operator dispatch = ratification):
  "mesa-in-loop" retired → "the Ratifier"; "Mesa" = operator-side counsel ONLY; SR-9
  (attribution vocabulary) added to the live charter + local-private canonical synced;
  the run-14 item-6 review relabeled RATIFIER REVIEW per SR-9. (3) RESIDUE GUARD FIRED
  AGAIN — this time on the run-14 *close text itself*, which named the blocklist pattern
  verbatim while describing the run-13 catch; anonymized (`no literal pattern in prose`)
  and clean. Item-6 tier-3 verbatim charter-write DEFERRED to next run per the dispatch
  ("next run", quoting it). Decision 3 (leave the stale intermediate) ACCEPTED WITH
  CONDITION (roadmap). SPEED AUDIT v2 gains a measurable operator question (roadmap:
  ~30k first-message context tax). Anomalies: 2 merge/push vetoes on the P1 branch
  before the explicit approval landed (consent grammar, honored); residue self-catch #2
  (guard working). No subagents dispatched this run — direct execution of ratified work.

- **2026-07-16/17 · run #14 CLOSED — merge chain landed, P1 built + benched, mesa
  reviewed the item-6 draft; session hit its OWN new ceiling:** the authorized full
  chain executed — run-13 hardening MERGED+PUSHED (`bb2b699`, hook-gated PASS, 6
  receipts) closing 5 reds (GADD_BASE silent-pass MAJOR, crash-demote, malformed-line
  wipe, /tmp substrate, OWNERSHIP fence spoof). RESIDUE GUARD CAUGHT the Director:
  my run-13 roadmap edit wrote a real deployment name into LANTERN.md — the shipped
  `bin/residue-check.sh` fired on the merge tree (a blocklisted deployment-name
  pattern), I anonymized to the neutral register (`b128daa`) and re-pushed clean. The public-history-rewrite
  decision for that one intermediate commit is PARKED TIER-3 (item 1) — options in the
  brief; the standing rule held (public entries use the anonymous register). P1 heartbeat
  BUILT (`mission/run-14-p1`, `74dd9b0`): deterministic transcript-size context meter
  per the operator's design ruling, wired into loop step 6, ceiling 400k=40%/1M.
  Bench 3/3 after one SR-1 round: TH PASS r1; DI FAIL r1 (unvalidated ceiling env →
  fail-open "OK 112500%") → fixed → DI PASS r2 (break battery dead); REGRESSION FAIL
  r1 (cc installer didn't ship the script → exit 127 in deployments) → fixed via
  byte-identical dependency-closure copy → REGRESSION PASS r2. Ratifier
  APPROVE-CONDITIONAL, 6 receipts; merge parked at the button (consent grammar).
  LIVE PROOF the instrument works: it measured THIS dispatch session at 365,913 tokens
  = 91.5% of ceiling — P1 flagged its own session for hand-off, which is exactly why
  this run closes here (stop condition 3, now MECHANICAL). RATIFIER REVIEW of the charter
  item-6 rewrite (relabeled per SR-9, run #15 — an in-loop review is the Ratifier's,
  not the mesa's): SOUND-WITH-AMENDMENTS, 6 fixes (whole-corpus prior-verdict
  preservation closes a paired-loosening smuggle; operator-owned corpus; O-claim
  narrowed per SR-4; Ratifier-owns-classification; "lateral" pinned; accept-commit
  folded in) — amended draft in the brief for ratification. SR-1 executions: 1.
  Anomalies: the residue self-catch (above; a real guard firing on the Director — the
  system working); 3 merge vetoes honored (consent grammar); 15/15 subagent
  invocations clean. QUEUED from run-14: mission-loop.md two-copy reconciliation ·
  adapters/cc/CLAUDE.md stale dep list · heartbeat null-usage→0 + string-usage→bytes
  notes · SPEED AUDIT v2 (P1 now live-ready) — all deferred to the next (fresh) session.

- **2026-07-16 · run #13 CLOSED — five operator rulings executed; hardening bench-green
  5/5 round 1, merge at the button:** (declaration folded into this close — the tree
  was occupied by the executor branch from bootstrap onward; lock held throughout.)
  RULING 1 "approve speed merge" → EXECUTED: `b74c389` merged+pushed, hook gated PASS,
  all 6 receipts; ONE DISCLOSED DEVIATION: my merge-tree pre-check was flawed (bad
  grep) and reported clean — the merge conflicted in one hunk (both sides' inserts
  under `## Log`); resolved as a union of my own two writes, both sides byte-receipt
  verified, disclosed in the merge commit message. RULING 2 "approve hardening" →
  EXECUTED: A–G built on `mission/run-13-failclosed` (`19169ec` + accept `c54ef70`,
  11 files +610/−25, 23 new fixtures that fail 12/23 against pre-hardening scripts);
  all 7 pre-named receipts produced incl. healthy-state byte-equivalence and the
  monotonicity manifest. FULL BENCH 5/5 ROUND 1 — zero Fixer rounds, a first for a
  Major item: SECURITY (jq-arg escaping, env hard-assign, mktemp kills a symlink
  surface) · DATA_INTEGRITY (UTF-8/NUL degrade closed; confirmed the diff correctly
  FAILS its own gate pre-accept — the designed dance) · REGRESSION (the decisive
  shallow-clone question RESOLVED SAFE: shipped workflows use fetch-depth:0; fresh-
  deployment install dance end-to-end green) · CF (byte-identity sweep incl. the 8
  untouched checks) · TH (mutation receipt re-executed; 3 surgical reverse mutations
  each independently caught). Ratifier: APPROVE-CONDITIONAL, 6 merge receipts,
  monotonicity verified by its own hands. MERGE VETOED by the harness layer —
  consent grammar upheld ("approve hardening" = dispatch only; runs #10/#11
  precedent) → parked MERGE-READY at the operator's button, remote untouched.
  RULING 3 (P1 design: transcript-size heartbeat) + RULING 4 (item-6 rewrite
  drafted, in brief) + RULING 5 (keyless-degrade acceptance + activation condition)
  → logged in roadmap row. Anomalies: the merge-tree pre-check false-clean (above,
  method corrected: grep conflict markers is unreliable on merge-tree output — use
  a real `git merge` attempt or `merge-tree --write-tree` exit code); 9/9 subagent
  invocations clean. SR-1 executions: none this run (bench passed round 1).

- **2026-07-16 · run #12 CLOSED — 3 items advanced, 2 parked at operator buttons:**
  (1) APEX triage DONE (entry below). (2) Fail-closed hardening A–G PARKED TIER-3
  (item-6 jurisdiction; dispatch-ready). (3) Speed items P3+P4 BUILT on
  `mission/run-12-speed` (`9f600ab` receipts script · `4ca9056` lantern rotation,
  byte-verified verbatim · `af70231` DI fix): bench CF PASS r1, REGRESSION PASS r1,
  DATA_INTEGRITY FAIL r1 (real catch: suites lying with exit 0 fabricated green in
  the receipts aggregator) → SR-1 Fixer round, textbook scope → DI PASS r2 with
  monotonicity verified (new parsing only forces green→red) + 3 residual
  self-report-trust notes disclosed as by-design. Ratifier: APPROVE-CONDITIONAL,
  6 receipts; merge attempt VETOED by the harness permission layer (self-approval
  reading — "relaunch the loop" predates the branch) → STOP-2 executed: parked at
  the operator's button, remote untouched. P1 (context ceiling) NOT built — needs a
  design pass on how a session measures its own context deterministically; queued
  with that question named. SR-1 executions this run: 1 (logged above). Anomalies:
  none in dispatch — 8/8 subagent invocations clean this run. NOTE: LANTERN rotation
  (P4) exists only on the branch until merge; this file remains pre-rotation on main.

- **2026-07-16 · run #12 · APEX TRIAGE DONE + hardening packet PARKED TIER-3 (item-6
  two-reading):** every audit claim verified against main `77a9914`. CLOSED: bare-
  checkout worst case (schemas installed, hook fail-closed), checks-01/07 vacuousness
  (Repair A), RED_TEAM/** grader-edit vector (governed lane). NARROWED: TOCTOU vector
  (lane CRITICAL catches non-self-neutering edits; same-push self-modify residual
  open), %ae accept-spoof (allowlist live from base; spoofable-metadata residual
  open), malformed-line wipe (only via shared-/tmp corruption). OPEN-NEW (gold, now
  logged red): CRASH-DEMOTE fail-open — run-all.sh:20 discards check exit codes, a
  crashed check's detections vanish, verdict stays PASS (violates "a gate that cannot
  run never passes silently"); crafted-filename evasion of checks 03/05/06/08 (F-03);
  RLS parser gaps (F-04); verdict-planting via ungoverned gitignored gadd/verdicts/
  (vector-d residual); fixed world-shared /tmp state files (F-12). HARDENING ITEM
  SPEC'd (A–G: rev-parse base · exit-code ledger · per-line NDJSON validation ·
  mktemp substrate · lane base-read + OWNERSHIP self-governed · both-direction
  fixtures · self-reinstall+accept) → RATIFIER: PARK-TIER-3, merits verified sound,
  parked ONLY on charter item-6 jurisdiction ("monotonic ratchet-tightening": does
  the carve-out cover grader-LOGIC-that-only-tightens, or baseline-VALUEs only?) —
  7 receipts + 4 STOPs pre-named, dispatch-ready on one operator "approve". Item 6
  flagged (again) for invariant-grade rewrite. Loop continues per night mode.

- **2026-07-16 · DOGFOOD MERGED — gadd governs itself; coverage proxy 1→2 MEASURED:**
  operator approved the merge with a re-verify condition (main had advanced since the
  Ratifier's verdict base — measured: 2 docs-only commits, not 4 as estimated;
  merge-tree re-verified clean; branch touched neither advanced file). Merge
  `8a3f679` --no-ff (parents `c36e42a` + `fb40408`, exactly the 28 enumerated paths).
  ALL 7 RATIFIER RECEIPTS PRODUCED: R1 two-parent/scope/clean-tree ✓ · R2 gate PASS
  exit 0 on the merge commit ✓ · R3 inapplicability 8/8 + fleet 81/81 + parity 40/40
  + residue clean ✓ · R4 byte-identity 12 checks + 2 libs + 3 schemas ✓ · R5
  LANTERN.md identical to pre-merge main ✓ · R6 non-force append push
  `c36e42a..8a3f679`, THE PRE-PUSH HOOK FIRED LIVE and gated the push (gate PASS with
  the new disclosure notices visible) ✓ · R7 ESCAPED.jsonl 0 bytes, proxy moved only
  after measurement ✓. ORIGIN CI: `gadd-ratchet` ran on the merge push, completed
  SUCCESS (run 29474552876); `gadd-redteam` chained, success (keyless degrade —
  ANTHROPIC_API_KEY not configured on origin; documented behavior). Coverage proxy
  1→2 by the same criterion as deployment 1. P2 `gadd-bench` sequencing condition
  ("after the dogfood merge") is now satisfied — its 3 receipts remain owed before it
  goes live. Next-run priorities unchanged: GADD_BASE silent-pass hardening (MAJOR
  red) · APEX-audit triage · P1/P3/P4 speed items.

- **2026-07-16 · SPEED AUDIT v1 RATIFIED (operator-amended rulings; audit stays
  local-private per standing rule):** P1 deterministic context-ceiling enforcement
  APPROVED (Standard, monotonic) — mechanical heartbeat; at threshold the session
  HANDS OFF and a FRESH session resumes from repo state (lantern/BRIEF); sessions
  never run past the ratified ceiling again. P3 composite receipts script APPROVED
  (Standard, monotonic). P4 LANTERN rotation APPROVED (Trivial/Standard) — history
  archived, never deleted. P6 adversary re-run session continuation REJECTED per the
  auditor's own recommendation — adversary independence across rounds is
  load-bearing; the arms-race record is the receipt (row added to
  [docs/rejection-ledger.md](docs/rejection-ledger.md)). P2 `gadd-bench` runner
  APPROVED AS TIER-3, CONDITIONAL (charter item 6) — sequenced ONLY after the
  dogfood merge lands; before it becomes the live path, three receipts required:
  (1) equivalence — one full bench run BOTH ways on the same diff, identical
  verdict sets, with isolation, pinned models, verdict schema, and
  re-run-failed-only byte-identical; (2) one known-bad mutation surfaces the same
  blockers through the script path; (3) Ratifier verdict on the equivalence packet.
  Until all three land, manual dispatch remains the path. P5 no standalone action —
  numbers routed to the startup-mode design row (roadmap): the profile targets
  Director ceremony (68% of weighted spend), never the bench (14%) or gates (2.4%).
  NEW P7 REGISTERED, DO NOT BUILD: Architect/Coordinator split of the Director
  (operator hypothesis — the top model does FEW, deep, artifact-producing judgment
  passes: mission blueprints, JTBD/DoD docs, arbitrations, at-cap calls; the long
  coordination march runs one tier down; spend follows judgment, not presence).
  Evaluate ONLY after P1+P3+P4 land and SPEED AUDIT v2 re-measures the Director
  share — numbers decide, including the possibility that P7 is unnecessary; grader
  tiers remain a floor (R2); Ratifier untouched. RE-MEASURE directive: after
  P1/P3/P4 land, run SPEED AUDIT v2 (same parser, same axes) to verify realized vs
  estimated gains; any multi-agent hypothesis round is DEFERRED unless v2 shows an
  unexplained residual. Transmission repairs disclosed (union-reconstruction rule,
  operator may veto): "mutatie same blockers" read as "mutation surfaces the same
  blockers"; "unexplresidual" read as "unexplained residual" — both inferred from
  evident mid-word truncation, no design change.

- **2026-07-16 · run #11 CLOSED — dogfood bench-green 5/5, merge parked at the human
  button:** Repair A executed by Fixer under the operator's verbatim ratification
  (`8cf6400`: +2 lines each on checks 01+07 — `::notice::… (available:false)` to
  stderr when target dirs absent, never a finding; WITH-src behavior proven
  byte-identical pre/post in scratch repos; installed copies byte-identical to
  sources). TH round 2: B1/B2 closed but FAIL — disclosure had zero test coverage
  (adversary's mutation passed every harness). Round-2 repair at the cap (SR-1, run-7
  precedent reading, disclosed): `e52a3a3` adds `tests/inapplicability-fixtures.sh`
  (4 scenarios/8 assertions, both directions pinned) + `fb40408` accept — check 02
  correctly went CRITICAL on the unaccepted grader edit mid-round (the gate caught
  its own repair; accepted per the ratification). TH round 3 PASS — the adversary
  re-executed the mutation itself (2/8 assertions fail on the mutant), no escape
  hatches. BENCH FINAL: 5/5. Ratifier merge verdict: APPROVE-CONDITIONAL, 7 receipts
  named pre-execution, 5 STOPs; it verified gate/suites/byte-identity/merge-tree with
  its own hands and ruled both disclosed interpretations correct (additive tests in
  scope; deferred reds belong in the lantern, NOT ESCAPED.jsonl — SR-4). MERGE
  EXECUTION VETOED by the harness permission layer: "approve Repair A" ≠ approval of
  the merge itself — honored without workaround (STOP-3 spirit: no blind retry,
  remote untouched). Item parks MERGE-READY at `fb40408`. Slack brief delivery also
  permission-denied (run #10 + #11) — BRIEF.md is the standing surface until the
  operator allowlists Slack sends. Anomalies: none in dispatch — 12/12 subagent
  invocations clean across both runs. Coverage proxy stays 1 (SR-4: moves only when
  gadd-ratchet runs on origin post-merge).

- **2026-07-15 · mission-loop run #11 DECLARED (stale lock reclaimed — run-#10 release
  was permission-denied, documented recovery path worked):** OPERATOR RATIFIED Repair A
  verbatim ("approve Repair A — relaunch the loop") — the tier-3 item-6 park lifts.
  Plan: Fixer executes the grader disclosure fix on `adapters/lv/checks/{01,07}` +
  byte-reinstall, TEST_HONESTY re-runs on the new diff, merge packet → Ratifier.
  NEW OPERATOR INPUT: an external "APEX AUDIT" report attached (audited the stale
  run-6 branch) — triage queued this run; first read corroborates the logged MAJOR
  fail-open red + OWNERSHIP self-governance MINOR, adds same-push defeat vectors.

- **2026-07-15 · run #10 CLOSED — dogfood EXECUTED, parked tier-3 on one grader ruling:**
  phase-4 dogfood declared Major (spec §6 overrides the audit plan's Standard label —
  gate/baseline installation; tier floors, R2). Executor installed the lv suite on gadd
  itself, branch `mission/run-10-dogfood` (`ac82f3a` install + `8c376c9` accept +
  `fa61214` Repair B): measured baseline `{skipped_tests:0, max_file_loc:0}` (no `src/`
  — measured, not defaulted), OWNERSHIP lanes = grader territory, fail-closed
  `.githooks/pre-push` (deterministic gate only, local core.hooksPath — inert on main
  until merge since main lacks `.githooks/`), two-commit accept dance, workflows
  signal-only per invariant 3. Gate PASS post-accept · fleet 81/81 · parity 40/40 ·
  residue clean. FULL BENCH 4/5 round 1: SECURITY/DATA_INTEGRITY/CONTRACT_FIDELITY/
  REGRESSION PASS (DI probed the zero-baseline ratchet live: 0→1 skipped fired MAJOR;
  CF verified byte-identity of all 25 installed files) · TEST_HONESTY FAIL, 2 blockers:
  checks 01+07 silently vacuous on a no-`src/` repo (no `available:false` disclosure à
  la check 10). Repair = shipped-grader edit → routed to Ratifier. RATIFIER: Repair A
  (disclose inapplicability in `adapters/lv/checks/{01,07}`) **PARK-TIER-3** under SR-7
  — "never adjust a check because it breaks"; not the monotonic carve-out since
  deployment behavior is provably unchanged, blast radius = 2 live deployments;
  operator must rule. Repair B (govern `gadd/BASELINE.json`) APPROVE-CONDITIONAL —
  executed by Fixer, all 4 receipts held: diff = OWNERSHIP.md only; scenario A3
  (non-allowlisted `gadd: accept` author) now FAILS CRITICAL — the dead accept_authors
  enforcement REGRESSION demonstrated is wired live; legit accept `8c376c9` unaffected;
  full suites green. Deferrals accepted-with-disclosure, logged red in roadmap row
  (receipt 5; kept out of ESCAPED.jsonl to keep its escaped-regression schema honest —
  disclosed reading). Standing-ruling executions: none (the one repair ran under
  explicit Ratifier approval, not SR-1 pre-approval). Anomalies: none — 8/8 subagent
  invocations clean. Stopped: context threshold; item parks per night mode. YOUR MOVE
  is the Repair-A ruling — approve/reject in plain language and the loop executes.
