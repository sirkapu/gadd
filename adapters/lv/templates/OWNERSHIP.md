# OWNERSHIP — path lanes

The agent (Lovable) must NOT modify governed paths. Check #2 parses the fenced block below —
keep it as one glob per line.

```gadd-governed
src/contracts/*
src/contracts/**
CLAUDE.md
AGENTS.md
OWNERSHIP.md
docs/standards/*
ai-specs/**
{{AGENT_PROMPTS_DIR}}/*
scripts/**
.gadd/**
gadd/BASELINE.json
.github/workflows/gadd-*.yml
```

Agent-owned (free to modify): `src/components/**` (except governed), `src/pages/**`,
`supabase/functions/**`, `supabase/migrations/**` (new files only).
