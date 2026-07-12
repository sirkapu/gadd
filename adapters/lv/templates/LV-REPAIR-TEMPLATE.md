# LV-repair-{{SHA7}}: fix ratchet blockers (round {{N}} of 2)

## Context
Your last push (`{{SHA7}}`) FAILED the quality ratchet. This prompt is scoped to the blockers
below — fix them and NOTHING else. Do not refactor, do not add features, do not touch tests
except to restore weakened ones.

## Blockers (from gadd/verdicts/{{SHA}}.json)
{{FINDINGS_TABLE}}

## Rules
- One commit per blocker where practical.
- If a blocker cannot be fixed without violating a contract or a governed lane, STOP and write
  `gadd/lv-blockers/repair-{{SHA7}}.md` explaining why. Do not guess.

## Response Report (mandatory)
Per blocker: what changed, in which files, and how to verify.
