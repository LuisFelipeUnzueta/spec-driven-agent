# Tests

A suite usa Pester 3.4+ e cobre projecoes Claude, Codex e Both, paths com espacos, idempotencia, blocos gerenciados, manifesto, limpeza segura, `.DS_Store`, dry-run, migracao v1 para v2 e validacao estatica.

```powershell
Invoke-Pester .\tests
```

Execute em Windows PowerShell 5.1 e PowerShell 7 quando ambos estiverem instalados:

```powershell
powershell -NoProfile -Command "Invoke-Pester .\tests"
pwsh -NoProfile -Command "Invoke-Pester .\tests"
```
