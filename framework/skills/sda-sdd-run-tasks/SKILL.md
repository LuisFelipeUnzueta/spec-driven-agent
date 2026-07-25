---
name: sda-sdd-run-tasks
description: Executa tasks de um SDD v2 com validação proporcional ao risco e estado retomável.
---

# Executar SDD

1. Leia `../_shared/workflow-sdd.json`.
2. Leia `../_shared/run-core.md` por completo.
3. Execute as tasks na ordem do grafo; paralelize somente lotes comprovadamente independentes.
4. Aplique o contrato compartilhado sem acrescentar stage ou commit automático.

Entrada: path da pasta/versionamento SDD informado na solicitação atual.