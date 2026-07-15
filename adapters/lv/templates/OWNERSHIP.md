# OWNERSHIP — path lanes

The agent (Lovable) must NOT modify governed paths. Check #2 parses the fenced block below —
keep it as one glob per line. Commented lines inside the block are inert examples — uncomment
and set your real path to enforce them.

```gadd-governed
src/contracts/*
src/contracts/**
CLAUDE.md
AGENTS.md
OWNERSHIP.md
docs/standards/*
ai-specs/**
# Replace with your deployment's agent-prompt lane; templates ship placeholders, never real paths
# uncomment and set your agent-prompts dir, e.g. {{AGENT_PROMPTS_DIR}}/*
scripts/**
.gadd/**
gadd/BASELINE.json
.github/workflows/gadd-*.yml
```

Agent-owned (free to modify): `src/components/**` (except governed), `src/pages/**`,
`supabase/functions/**`, `supabase/migrations/**` (new files only).
