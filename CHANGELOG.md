# Changelog

Todas as mudancas notaveis neste projeto serao documentadas neste arquivo.

O formato e baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/),
e este projeto adere ao [Semantic Versioning](https://semver.org/lang/pt-BR/).

## [Unreleased]

## [1.0.0] - 2026-07-22

### Adicionado
- Framework completo com 3 workflows: SDD, miniSpec, TaskCard
- 2 gates de validacao: QA funcional (sda-qa-validator) + Review arquitetural (sda-staff-architecture-review)
- 36+ skills para todas as fases do ciclo de vida
- Sistema de overrides por projeto (.agents/)
- Suporte a Claude Code e OpenAI Codex
- Scripts de inicializacao (init-project.ps1), sincronizacao (sync-claude.ps1) e atualizacao (update-framework.ps1)
- Sistema ADR com rastreabilidade bidirecional e INDEX.md auto-gerado
- Doutrina de testes (sda-testing-best-practices) com Iron Laws e 30+ antipadroes catalogados
- Skill de mineração de regras (sda-mine-rule-candidates) a partir do historico git
