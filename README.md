# SpecDrivenAgent

Framework de desenvolvimento assistido por IA para Claude Code e OpenAI Codex.

## O que e

SpecDrivenAgent e um framework que estrutura o fluxo de trabalho de desenvolvimento de software com assistencia de IA, oferecendo:

- **3 workflows** baseados em complexidade: SDD, miniSpec, TaskCard
- **2 gates** de validacao: QA funcional + Review arquitetural
- **36 skills** para todas as fases do ciclo de vida
- **Sistema de overrides** para customizacao por projeto
- **Suporte nativo** a Claude Code e OpenAI Codex

## Instalacao

### Opcao 1: Git Submodule (recomendado)

```bash
cd seu-projeto
git submodule add https://github.com/seu-usuario/SpecDrivenAgent.git .sda
```

### Opcao 2: Clone direto

```bash
git clone https://github.com/seu-usuario/SpecDrivenAgent.git
```

## Setup no Projeto

### Usando o script de inicializacao (recomendado)

O script auto-detecta o modo de instalacao (submodule ou clone) e configura tudo automaticamente.

```powershell
# Submodule (.sda/) — detecta automaticamente:
.\.sda\scripts\init-project.ps1 -ProjectPath .

# Clone direto — especifique o caminho:
.\SpecDrivenAgent\scripts\init-project.ps1 -ProjectPath . -FrameworkPath .\SpecDrivenAgent
```

### Manual

1. Copie `framework/` para `.claude/` (ou use `sync-claude.ps1`)
2. Execute `generate-agents-md.ps1` para criar `AGENTS.md`
3. Crie seu `CLAUDE.md`

## Estrutura

```
seu-projeto/
├── .sda/                      # Git submodule (framework fonte)
│   ├── framework/
│   │   ├── agents/
│   │   │   ├── sda-qa-validator.md          # Gate 1 — orquestrador
│   │   │   ├── sda-qa-validator/            # Modulos de validacao
│   │   │   ├── sda-staff-architecture-review.md
│   │   │   └── sda-qa-test-generator.md
│   │   ├── rules/
│   │   └── skills/
│   ├── scripts/
│   └── templates/
├── .claude/                  # Claude Code (gerado)
│   ├── agents/
│   ├── rules/
│   └── skills/
├── .agents/                  # Overrides do projeto
│   ├── rules/
│   └── skills/
├── AGENTS.md                 # OpenAI Codex (gerado)
├── CLAUDE.md                 # Claude Code (manual)
├── VERSION                   # Versao semver do framework
└── CHANGELOG.md              # Historico de alteracoes
```

## Workflows

| Workflow | Quando usar | Comando inicial |
|----------|-------------|-----------------|
| **SDD** | Features grandes/criticas | `/sda-sdd-generate-prd` |
| **miniSpec** | Features medias | `/sda-minispec-generate-intent` |
| **TaskCard** | Tarefas pontuais | `/sda-taskcard-generate` |

Execute `/sda-pre-refinement` se nao tiver certeza qual workflow usar.

## Customizacao

Adicione regras e skills especificas do projeto em `.agents/`:

```bash
# Regras do projeto
.agents/rules/seu-projeto-nome-da-regra.md

# Skills do projeto
.agents/skills/seu-projeto-nome-da-skill/
└── SKILL.md
```

O prefixo `sda-` e reservado para o framework. Use o nome do seu projeto como prefixo para overrides.

## Atualizacao

```powershell
# Submodule:
cd .sda && git pull && cd ..
.\.sda\scripts\sync-claude.ps1 -Force

# Clone direto:
.\SpecDrivenAgent\scripts\update-framework.ps1 -FrameworkPath .\SpecDrivenAgent
```

## Versao

Versao atual: **1.0.0**

Consulte [CHANGELOG.md](CHANGELOG.md) para historico de alteracoes.

## Licenca

Apache License 2.0
