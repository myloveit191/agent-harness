# Task Router

Use this file to classify tasks into workflows such as feature, bugfix,
refactor, documentation, investigation, and release.

## Lifecycle Routing

Before routing by engineering task type, route product work by lifecycle stage:

| User intent | Lifecycle stage | Primary files |
| --- | --- | --- |
| Rough idea, concept, project direction | Idea | `.agent-harness/project/idea/` |
| Validate problem, interview users, compare alternatives | Discovery | `.agent-harness/project/discovery/` |
| MVP, roadmap, user stories, success criteria | Product | `.agent-harness/project/product/` |
| Domain, data, APIs, integrations, technical decisions | Architecture | `.agent-harness/project/architecture/` |
| Build features, split tasks, release prep | Execution | `.agent-harness/project/execution/` |
| Tests, metrics, feedback, learnings | Evaluation | `.agent-harness/project/evaluation/` |
| Deploy, monitor, incident response, maintenance | Operations | `.agent-harness/project/operations/` |
| Scale, monetize, expand, grow | Growth | `.agent-harness/project/growth/` |

If the stage is unclear, ask the smallest useful clarification or infer the
stage from the files and task language.

## Engineering Routing

After lifecycle routing, classify the task:

- Feature: update product memory, spec if needed, then implementation plan.
- Bugfix: reproduce or locate the failure, define expected behavior, verify.
- Refactor: identify behavior-preserving scope and required regression checks.
- Documentation: update the closest durable doc or project memory file.
- Investigation: record findings and open questions before proposing changes.
- Release: use execution and operations checklists before deployment steps.
- Growth: verify operational readiness and scaling risks before expansion work.
