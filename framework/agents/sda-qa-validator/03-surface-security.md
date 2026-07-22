## Camada 3 — Seguranca de Superficie

Input validado/sanitizado no que e obvio?
- **Backend**: injecao basica (SQL/command), validacao de entrada em rotas expostas.
- **Frontend**: XSS obvio — escrita de HTML nao-sanitizado via API de insercao bruta do framework (ex.: `innerHTML`, `dangerouslySetInnerHTML` no React, `v-html` no Vue, `[innerHTML]` no Angular), dados sensiveis em armazenamento do navegador (ex.: `localStorage`).
- **Mobile**: logs com PII, deep links sem validacao basica.
- Segredos hardcoded em qualquer frente.

> Nota: seguranca **profunda** (IDOR, escalacao, CSP, certificate pinning, fluxos completos de token) e do Tech Review.
