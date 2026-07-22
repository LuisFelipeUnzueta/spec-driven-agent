# Modulos de Validacao — sda-qa-validator

Indice dos modulos deste diretorio. O orquestrador (`sda-qa-validator.md`) carrega estes modulos antes de produzir o JSON.

## Ordem de Leitura

| # | Modulo | Camada | Conteudo |
|---|--------|--------|----------|
| 0 | `00-persona-contract.md` | Pre | Persona, escopo, formato, descoberta de stack, economia de leitura, pre-validacao |
| 1 | `01-scope-completeness.md` | 0 | Completude de escopo declarado (entregaveis da task) |
| 2 | `02-correctness-robustness.md` | 1-2 | Corretude funcional + robustez (null/vazio/erros/async) |
| 3 | `03-surface-security.md` | 3 | Seguranca de superficie (input validation, XSS, segredos) |
| 4 | `04-completeness.md` | 4 | Completude (cenarios, validacoes, estados visuais, fidelidade ao design) |
| 5 | `05-testing-quality.md` | 5 | Qualidade dos testes — testing smells e red flags |
| 6 | `06-adr-compliance.md` | 6 | ADR Compliance Light (sweep grep-detectavel) |
| 7 | `065-rule-mining.md` | 6.5 | Rule Mining (sinais nao-bloqueantes para mineração offline) |
| 8 | `07-automated-tests.md` | 7 | Testes automatizados (execucao, rastreabilidade CT, regressao) |
| 9 | `08-json-output.md` | Schema | JSON de saida, schema completo, descricao dos campos |
| 10 | `09-critical-rules.md` | Regras | Regras gerais e criticas consolidadas |

## Dependencias Externas

A Pre-Validacao Obrigatoria (modulo 00) requer leitura de:
- `.claude/skills/sda-testing-best-practices/SKILL.md`
- `.claude/skills/sda-testing-best-practices/references/antipadroes.md`
- `.claude/skills/sda-testing-best-practices/references/ai-escreve-testes.md`
- `.claude/skills/sda-testing-best-practices/references/ci-flakiness.md`
