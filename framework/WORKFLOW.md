# Workflows SpecDrivenAgent v2

## Escolha

| Cenario | Workflow | Planejamento | Execucao |
|---|---|---|---|
| Feature ampla, critica ou arquitetural | SDD | PRD, Tech Spec, Task Plan, tasks | `sda-sdd-run-tasks` |
| Mudanca localizada de porte medio | miniSpec | Intent, Scope, Task Plan, tasks | `sda-minispec-run-tasks` |
| Alteracao unica e delimitada | TaskCard | TaskCard | `sda-taskcard-run` |

Use `sda-pre-refinement` quando o escopo ainda nao estiver claro.

## Contrato da task

```yaml
risk: low | medium | high
validation: none | qa | full
```

`validation` segue a superficie da mudanca: `none` para conteudo sem efeito executavel, `qa` para codigo localizado e `full` para risco alto ou superficies criticas.

## Execucao comum

Os tres runners carregam `_shared/run-core.md` e apenas uma configuracao pequena de paths por workflow.

1. validar task e dependencias;
2. implementar no agente principal;
3. executar somente a validacao declarada;
4. em rejeicao, corrigir os achados e repetir apenas o gate afetado;
5. limitar a tres tentativas totais e usar perfil critico na ultima correcao;
6. atualizar `_run/state.json` e `_run/report.md`.

Subagentes sao reservados para revisao independente, trabalho realmente paralelo ou solicitacao explicita. O runner nao executa `git add` nem commit.

## QA condicional

O nucleo de QA cobre criterios, testes e findings. Modulos adicionais sao carregados apenas quando aplicaveis:

- seguranca para superficie sensivel;
- UI para tarefa visual;
- ADR quando houver ADR aplicavel;
- flakiness diante de falha instavel;
- rule mining fora do caminho critico.

QA e Tech Review retornam o mesmo schema compacto: `verdict`, `tests`, `criteria` e `findings[]`.

## Artefatos

| Workflow | Artefatos principais |
|---|---|---|
| SDD | `docs/prds/features/{feature}/{version}/prd.md`, `tech_spec.md`, `task_plan.md`, `tasks/` |
| miniSpec | `intent.md`, `scope.md`, `task_plan.md`, `tasks/` |
| TaskCard | `tasks/task-{nn}-{slug}.md` |
| Execucao | `_run/state.json`, `_run/report.md`; memoria de retry somente apos rejeicao |
| ADR | `docs/adr/`, `docs/adr/INDEX.md` |

## Gates de Qualidade (Checklists)

Antes de cada transição de fase, recomenda-se rodar `sda-checklist-generate` para validar a qualidade da especificação:

```
PRD → [sda-checklist-generate prd.md] → Tech Spec → [sda-checklist-generate tech_spec.md] → Task Plan
INTENT → [sda-checklist-generate intent.md] → SCOPE → [sda-checklist-generate scope.md] → Tasks
```

Checklists NÃO bloqueiam o avanço — são **gates não-bloqueantes** que registram o score e permitem avanço mesmo com ressalvas. O score fica em `_run/checklist-<tipo>.md`.

Paths canonicos ficam em `_shared/rules/sda-*-workflow-rules.md`.
