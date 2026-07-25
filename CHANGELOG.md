# Changelog

Todas as mudancas notaveis deste projeto serao documentadas neste arquivo.

O formato segue [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/) e [Semantic Versioning](https://semver.org/lang/pt-BR/).

## [Unreleased]

## [2.0.0] - 2026-07-24

### Adicionado

- Projecao nativa para Claude, Codex ou ambos a partir do mesmo nucleo.
- Agentes Codex TOML e agentes Claude Markdown gerados por adapters.
- Manifesto `.agents/.sda-manifest.json` e blocos gerenciados preservando customizacoes.
- Contrato de task `risk` + `validation` e migrador v1 para v2.
- Nucleo compartilhado de execucao, gates, retry e relatorio.
- QA modular com schema unico de findings e orcamento de contexto.
- Validacao estatica de skills, links, isolamento de host e orcamentos.

### Alterado

- `AGENTS.md` passou a ser a instrucao compartilhada; `CLAUDE.md` apenas importa e estende.
- Estado reduzido a `_run/state.json`, `_run/report.md` e memoria de retry sob demanda.
- Implementacao ocorre no agente principal por padrao.
- Descricoes das 36 skills foram compactadas para o limite inicial do Codex.

### Removido

- Scripts `sync-claude.ps1`, `generate-agents-md.ps1` e `update-framework.ps1`.
- Campos v1 `model`, `reasoning_effort` e `gates` nas tasks.
- Placeholders de symlink e runners duplicados.
- Staging automatico pelos runners.

### Breaking

- A v2 nao oferece compatibilidade implicita com tasks v1. Execute `scripts/migrate-v2.ps1` antes de retomar workflows existentes.

## [1.0.0] - 2026-07-22

### Adicionado

- Workflows SDD, miniSpec e TaskCard.
- Skills de planejamento, execucao, QA, ADR, testes e documentacao.
