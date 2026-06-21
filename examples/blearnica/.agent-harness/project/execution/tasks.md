# Tasks

## Task: Create Diagnostic Test Flow

Goal: let learners complete a diagnostic test and receive a result.

Scope:

- Start a diagnostic test.
- Submit answers.
- Calculate score by knowledge unit.
- Show weak and strong units.

Acceptance criteria:

- A learner can complete the test.
- Results are grouped by topic.
- Weak topics are persisted for path generation.

Verification:

- Unit tests for scoring.
- End-to-end test or manual smoke test for the full flow.

Status: Todo

## Task: Generate Learning Path

Goal: create a learning path based on diagnostic weak units.

Scope:

- Rank weak knowledge units.
- Add prerequisite units when needed.
- Create ordered practice steps.

Acceptance criteria:

- Path uses diagnostic results.
- Each step maps to a knowledge unit.
- Progress can be recorded per step.

Verification:

- Unit tests for path ordering.
- Manual test with at least two learner profiles.

Status: Todo
