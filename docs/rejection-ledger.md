# Rejection Ledger — patterns considered and deliberately NOT adopted

One entry per rejected/adapted pattern, with the reason. Add here whenever a design is
considered and declined — future sessions read this instead of re-litigating.

| Pattern | Source | Ruling | Why |
|---|---|---|---|
| One agent role-playing the RED_TEAM bench | gadd v0.1 cc adapter (`agents/gadd-redteam.md`: "5 adversaries reviewing ONE diff in parallel perspectives"; same collapse in lv `redteam.sh`'s single prompt) | **Rejected** (2026-07-14) | Spec §3 said "adversaries in parallel" but never said *isolated* — so the adapter collapsed the bench into one Opus context role-playing five perspectives. One context has one set of blind spots, and role-played adversaries produce correlated verdicts; the bench's value is uncorrelated failure detection, not persona prose. **Spec-ambiguity lesson:** when an invariant depends on isolation/independence, the spec must say so explicitly ("own isolated invocation, never sees another's verdict") or an adapter will optimize it away as mere phrasing. Fixed by splitting the bench into `RED_TEAM/` (one definition file per adversary + gate-matrix.md), dispatching each adversary as its own isolated parallel invocation in both adapters (cc: five `gadd-rt-*` subagents; lv: five independent API calls), mapping models structural→cheap / judgment→strong per the Phase 0 orchestration, and naming independence a spec concern in §3. |
