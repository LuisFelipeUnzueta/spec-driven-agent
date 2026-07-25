---
name: sda-migrate-specs
description: Migra tasks SpecDrivenAgent v1 para o contrato v2 com validacao atomica e dry-run.
---

# Migrar specs para v2

1. Localize o checkout ou submodule do SpecDrivenAgent usado pelo projeto.
2. Execute `scripts/migrate-v2.ps1 -ProjectPath <projeto> -DryRun`.
3. Apresente os arquivos elegiveis e qualquer erro ao usuario.
4. So aplique sem `-DryRun` apos confirmacao explicita.
5. Verifique que tasks migradas contem apenas `risk` e `validation` para politica de execucao.
6. Nao faca staging nem commit.

Mapeamento: `none` vira `validation: none`, `[qa]` vira `validation: qa` e `[qa, tech_review]` vira `validation: full`. Os campos `model` e `reasoning_effort` sao removidos. Entrada invalida aborta o lote antes de qualquer escrita.
