# Project Lifecycle

Use this lifecycle to turn a rough idea into a validated, built, deployed,
evaluated, maintainable, and expandable project. Each stage produces concrete
project memory under `.agent-harness/project/`.

Harness is not the product. Harness is the repeatable system that helps the
product move from idea to validation, design, implementation, operation, and
growth.

## Stage 1: Idea

Goal: turn a fuzzy idea into a short, testable brief.

Read or create:

- `.agent-harness/project/idea/idea-brief.md`
- `.agent-harness/project/idea/problem.md`
- `.agent-harness/project/idea/users.md`
- `.agent-harness/project/idea/assumptions.md`

Exit criteria:

- The idea is clear in 3-5 sentences.
- The target user and painful problem are named.
- The desired user outcome is explicit.
- The riskiest assumptions are listed.

## Stage 2: Discovery

Goal: prove the problem is real before building the product.

Read or create:

- `.agent-harness/project/discovery/problem-validation.md`
- `.agent-harness/project/discovery/market-research.md`
- `.agent-harness/project/discovery/competitor-analysis.md`
- `.agent-harness/project/discovery/user-interviews.md`
- `.agent-harness/project/discovery/validation-plan.md`

Exit criteria:

- There is evidence that users already spend time, money, or effort on the
  problem.
- Open questions and invalidated assumptions are documented.
- The project has a continue, adjust, narrow, or stop decision.

## Stage 3: Product

Goal: define the smallest product that validates the main hypothesis.

Read or create:

- `.agent-harness/project/product/vision.md`
- `.agent-harness/project/product/mvp-scope.md`
- `.agent-harness/project/product/user-stories.md`
- `.agent-harness/project/product/roadmap.md`

Exit criteria:

- The main hypothesis is written.
- MVP features and explicitly deferred features are listed.
- Success criteria are measurable.
- User stories include acceptance criteria.

## Stage 4: Architecture

Goal: design the system from domain concepts before implementation details.

Read or create:

- `.agent-harness/project/architecture/system-overview.md`
- `.agent-harness/project/architecture/domain-model.md`
- `.agent-harness/project/architecture/data-model.md`
- `.agent-harness/project/architecture/api-design.md`
- `.agent-harness/project/architecture/tech-decisions.md`

Exit criteria:

- Core domain entities and relationships are defined.
- Data model follows the domain model.
- Major boundaries, integrations, and risks are visible.
- Important technical choices have decision records.

## Stage 5: Execution

Goal: convert the MVP into small, verifiable work.

Read or create:

- `.agent-harness/project/execution/phases.md`
- `.agent-harness/project/execution/tasks.md`
- `.agent-harness/project/execution/definition-of-done.md`
- `.agent-harness/project/execution/release-checklist.md`

Exit criteria:

- Work is split into phases.
- Tasks are small enough to complete and verify.
- Each task has acceptance criteria.
- Release gates are known before release work starts.

## Stage 6: Evaluation

Goal: measure whether the product works technically and for users.

Read or create:

- `.agent-harness/project/evaluation/test-plan.md`
- `.agent-harness/project/evaluation/metrics.md`
- `.agent-harness/project/evaluation/user-feedback.md`
- `.agent-harness/project/evaluation/postmortem.md`

Exit criteria:

- Technical tests and product metrics are defined.
- User feedback is collected in a repeatable format.
- Incidents or failed experiments produce learnings.

## Stage 7: Operations

Goal: make the project deployable, observable, and maintainable.

Read or create:

- `.agent-harness/project/operations/deployment.md`
- `.agent-harness/project/operations/monitoring.md`
- `.agent-harness/project/operations/incident-response.md`
- `.agent-harness/project/operations/maintenance.md`

Exit criteria:

- Deployment steps are documented.
- Monitoring and alerting expectations are known.
- Incident response has ownership and severity levels.
- Maintenance work has a regular cadence.

## Stage 8: Growth

Goal: expand the product after the core value and operating model are proven.

Read or create:

- `.agent-harness/project/growth/growth-plan.md`
- `.agent-harness/project/growth/scaling-risks.md`
- `.agent-harness/project/growth/monetization.md`
- `.agent-harness/project/growth/expansion-roadmap.md`

Exit criteria:

- Growth bets are linked to validated user or business signals.
- Scaling risks are explicit before expanding scope.
- Monetization or sustainability assumptions are documented.
- Expansion work has clear success metrics and rollback criteria.
