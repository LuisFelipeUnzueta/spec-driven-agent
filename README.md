# SpecDrivenAgent

Nucleo de workflows orientados por especificacao para Claude Code e OpenAI Codex.

## Principios da v2

- uma unica fonte em `framework/skills`;
- descoberta nativa em ambos os hosts;
- `AGENTS.md` curto e compartilhado;
- adapters isolam modelos, esforco e formato de agentes;
- validacao proporcional ao risco;
- no maximo tres tentativas por task;
- nenhum staging ou commit automatico.

## Instalacao

Como submodule:

```powershell
git submodule add <url-do-repositorio> .sda
.\.sda\scripts\init-project.ps1 -ProjectPath .
```

Como clone separado:

```powershell
git clone <url-do-repositorio> SpecDrivenAgent
.\SpecDrivenAgent\scripts\init-project.ps1 -ProjectPath . -FrameworkPath .\SpecDrivenAgent
```

O host padrao e `Both`. Para limitar a projecao:

```powershell
.\.sda\scripts\init-project.ps1 -ProjectPath . -Host Claude
.\.sda\scripts\init-project.ps1 -ProjectPath . -Host Codex
```

## Atualizacao

Depois de atualizar o submodule ou clone:

```powershell
.\.sda\scripts\sync-project.ps1 -ProjectPath . -FrameworkPath .\.sda\framework -Host Both
```

Use `-DryRun` para inspecionar as mudancas. O manifesto `.agents/.sda-manifest.json` permite limpar apenas arquivos antes gerados pelo framework. Conteudo externo aos blocos `<!-- sda:start -->` e `<!-- sda:end -->` em `AGENTS.md` e `CLAUDE.md` e preservado.

## Projecoes

| Fonte | Codex | Claude |
|---|---|---|
| `framework/skills` | `.agents/skills` | `.claude/skills` |
| `framework/roles` | `.codex/agents/*.toml` | `.claude/agents/*.md` |
| `.agents/rules` do projeto | lidas pelas skills | `.claude/rules` |
| `templates/AGENTS.md.template` | `AGENTS.md` | importado por `CLAUDE.md` |

Skills locais sem prefixo `sda-` permanecem em `.agents/skills` e tambem sao projetadas para Claude. O prefixo `sda-` e reservado ao framework.

## Invocacao

| Host | Forma explicita |
|---|---|
| Claude Code | `/sda-taskcard-generate`, `/sda-minispec-run-tasks` |
| Codex | `$sda-taskcard-generate`, `$sda-minispec-run-tasks` |

Linguagem natural tambem pode ativar skills pelo campo `description`.

## Contrato de task v2

```yaml
risk: low # low | medium | high
validation: qa # none | qa | full
```

- `none`: documentacao ou metadado sem efeito executavel;
- `qa`: codigo localizado de risco baixo ou medio;
- `full`: autenticacao, seguranca, criptografia, migrations, secrets/config executavel, contratos publicos, pagamentos, mudancas cross-module ou `risk: high`.

`model`, `reasoning_effort` e `gates` nao pertencem mais a tasks. Perfis de host ficam em `framework/adapters/profiles.json`.

## Migracao da v1

```powershell
.\.sda\scripts\migrate-v2.ps1 -ProjectPath . -DryRun
.\.sda\scripts\migrate-v2.ps1 -ProjectPath .
```

Veja [docs/MIGRATION-v2.md](docs/MIGRATION-v2.md).

## Validacao do framework

```powershell
.\scripts\validate-framework.ps1
Invoke-Pester .\tests
```

Versao atual: **2.0.0**. Licenca Apache-2.0.
