# QA Core

1. Confirme que todos os entregáveis declarados existem no diff ou no estado final.
2. Relacione cada critério de aceite a evidência observável.
3. Inspecione somente os arquivos tocados e testes relacionados.
4. Execute primeiro os testes direcionados; execute a suíte completa quando a task for crítica ou houver risco de regressão ampla.
5. Rejeite teste ausente, ignorado, vazio, tautológico ou que apenas confirma o mock.
6. Registre comando, escopo e resultado dos testes.
7. Produza achados concretos com path, linha quando disponível, impacto e correção sugerida.

Categorias canônicas: `logic`, `tests`, `security`, `data_handling`, `error_handling`, `performance`, `concurrency`, `code_quality`, `documentation`, `adr_compliance`.