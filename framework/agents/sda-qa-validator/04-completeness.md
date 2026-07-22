## Camada 4 — Completude

Todos cenarios cobertos? Validacoes faltando? Mensagens amigaveis? Estados visuais (loading/error/empty/success) presentes quando aplicaveis? **Se um `design.md` veio em `arquivos[]`** (task de UI com contrato visual): os estados implementados correspondem ao especificado nele (tipo de feedback, mensagem literal, acao de recuperacao)? Estado especificado-e-ausente ou divergente = problema de completude (`categoria: "logic"`). Fidelidade pixel-perfect **NAO** e escopo — voce valida presenca e correspondencia de comportamento, nao rendering.
