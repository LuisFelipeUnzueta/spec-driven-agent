---
name: sda-minispec-run-tasks
description: Executa tasks de uma miniSpec v2 com validação proporcional ao risco e estado retomável.
---

# Executar miniSpec

1. Leia `../_shared/workflow-minispec.json`.
2. Leia `../_shared/run-core.md` por completo.
3. Execute as tasks na ordem do grafo; paralelize somente lotes comprovadamente independentes.
4. Aplique o contrato compartilhado sem acrescentar stage ou commit automático.

Entrada: path da pasta/versionamento miniSpec informado na solicitação atual.