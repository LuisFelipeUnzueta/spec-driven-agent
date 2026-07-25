# Paths da TaskCard v2

- **taskcard.task_plan.path**: `/docs/specs/features/{feature}/{version}/task_plan.md`
- **taskcard.tasks.dir**: `/docs/specs/features/{feature}/{version}/tasks`
- **taskcard.tasks.pattern**: `TC-{nnn}.md`

Uma TaskCard representa uma alteração pontual. Mudanças multifase, cross-module ou com decisão arquitetural ampla devem usar miniSpec ou SDD. O estado usa `shared.state.path`.