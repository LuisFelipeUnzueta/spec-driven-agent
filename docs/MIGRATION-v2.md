# Migracao para SpecDrivenAgent v2

A v2 e breaking. Migre tasks existentes antes de executar qualquer runner.

## 1. Inspecione

```powershell
.\.sda\scripts\migrate-v2.ps1 -ProjectPath . -DryRun
```

O script examina `docs/specs/**/*.md`, valida todas as entradas antes de escrever e mostra os arquivos elegiveis.

## 2. Converta

```powershell
.\.sda\scripts\migrate-v2.ps1 -ProjectPath .
```

Mapeamento:

| v1 | v2 |
|---|---|
| `gates: none` | `validation: none` |
| `gates: [qa]` | `validation: qa` |
| `gates: [qa, tech_review]` | `validation: full` |
| `model`, `reasoning_effort` | removidos |

Toda task convertida precisa declarar `risk: low`, `risk: medium` ou `risk: high`. Valor de `gates` desconhecido ou ausencia de `risk` aborta o lote sem alteracoes.

## 3. Atualize as projecoes

```powershell
.\.sda\scripts\sync-project.ps1 -ProjectPath . -FrameworkPath .\.sda\framework -Host Both -DryRun
.\.sda\scripts\sync-project.ps1 -ProjectPath . -FrameworkPath .\.sda\framework -Host Both
```

Escolha `Claude` ou `Codex` se o projeto usa apenas um host.

## 4. Revise customizacoes

- regras do projeto permanecem em `.agents/rules`;
- skills locais permanecem em `.agents/skills` e nao devem usar o prefixo reservado `sda-`;
- conteudo fora dos blocos gerenciados de `AGENTS.md` e `CLAUDE.md` e preservado;
- arquivos obsoletos so sao removidos quando registrados no manifesto anterior.

## 5. Remova chamadas v1

Substitua:

- `sync-claude.ps1` e `update-framework.ps1` por `sync-project.ps1`;
- `generate-agents-md.ps1` por blocos gerenciados do `sync-project.ps1`;
- `_run/*_state.yaml` por `_run/state.json`;
- `_run/run-report.md` e `_run/workflow-report.md` por `_run/report.md`.

No Claude invoque `/sda-*`; no Codex use `$sda-*` ou linguagem natural.
