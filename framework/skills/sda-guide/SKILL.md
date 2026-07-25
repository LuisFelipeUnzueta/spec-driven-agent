---
name: sda-guide
description: Escolhe o workflow SDA e aponta a menor sequencia de skills para planejar, executar ou manter uma mudanca.
---

# Guia SpecDrivenAgent v2

## Escolha do workflow

- Escopo incerto: `sda-pre-refinement`.
- Feature ampla, critica ou com decisao arquitetural: SDD.
- Mudanca media e localizada: miniSpec.
- Alteracao unica e delimitada: TaskCard.

## Sequencias minimas

### SDD

1. `sda-sdd-generate-prd`
2. `sda-sdd-generate-tech-spec`
3. `sda-sdd-generate-task-plan`
4. `sda-sdd-run-tasks`

Use alinhamento tecnico, design ou challenge somente quando a superficie exigir.

### miniSpec

1. `sda-minispec-generate-intent`
2. `sda-minispec-generate-scope`
3. `sda-minispec-generate-tasks`
4. `sda-minispec-run-tasks`

### TaskCard

1. `sda-taskcard-generate`
2. `sda-taskcard-run`

## Validacao

Toda task usa:

```yaml
risk: low | medium | high
validation: none | qa | full
```

- `none`: documentacao ou metadado sem efeito executavel;
- `qa`: codigo localizado de risco baixo ou medio;
- `full`: risco alto, mudanca cross-module ou area critica.

Areas criticas incluem autenticacao, autorizacao, criptografia, migrations, secrets/config executavel, contratos publicos e pagamentos.

## Apoio sob demanda

- ADR: `sda-adr-bootstrap`, `sda-adr-create`, `sda-adr-review`, `sda-adr-supersede`, `sda-adr-deprecate`, `sda-adr-reindex`.
- Testes: `sda-testing-stack-bootstrap`, `sda-testing-best-practices`.
- Regras: `sda-mine-rule-candidates`, `sda-curate-project-rules`, `sda-rule-create`.
- Entrega: `sda-backend-contract-handoff`, `sda-docs-sync`, `sda-readme-generator`, `sda-semantic-commit`.
- Migracao v1: `sda-migrate-specs`.

## Fontes lazy

- paths compartilhados: `../_shared/rules/sda-workflow-rules.md`;
- paths SDD, miniSpec e TaskCard: rules correspondentes em `../_shared/rules/`;
- execucao, retry e relatorio: `../_shared/run-core.md`;
- regras especificas do projeto: `.agents/rules/`, somente quando relevantes.

Implemente no agente principal. Delegue somente revisao independente, trabalho realmente paralelo ou pedido explicito. Os runners nao fazem stage nem commit.
