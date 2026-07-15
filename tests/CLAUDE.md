# CLAUDE.md — tests/

- The acceptance corpora ARE the instruments' specs (fleet-fixtures.sh for
  the North Star aggregator; parity-fixtures.sh for the parity engine).
  Fixtures are append-only in spirit: every adversary finding or arbitration
  adds one; none are deleted to make a change pass (that's test-weakening —
  tier-3).
