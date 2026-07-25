# Regras Comuns dos Workflows v2

## Paths compartilhados

- **shared.specs_root**: `/docs/specs`
- **shared.specs_glob**: `/docs/specs/**/*.md`
- **shared.prds_glob**: `/docs/prds/**/*.md`
- **pre_refinement.path**: `/docs/specs/features/{feature}/{version}/pre-refinement.md`
- **tech_alignment.path**: `/docs/specs/features/{feature}/{version}/tech-alignment.md`
- **design_system.global.path**: `/docs/specs/design-system.md`
- **design.feature.path**: `/docs/specs/features/{feature}/{version}/design.md`
- **domain_glossary.global.path**: `/docs/specs/domain-glossary.md`
- **domain_glossary.feature.path**: `/docs/specs/features/{feature}/domain-glossary.md`
- **shared.handoff_frontend.path**: `/docs/specs/features/{feature}/{version}/handoff-frontend.md`
- **shared.state.path**: `/docs/specs/features/{feature}/{version}/_run/state.json`
- **shared.report.path**: `/docs/specs/features/{feature}/{version}/_run/report.md`
- **shared.retry.dir**: `/docs/specs/features/{feature}/{version}/_run/retry`
- **shared.retry.pattern**: `{task_id}.json`
- **shared.rule_candidates.path**: `/docs/specs/features/{feature}/{version}/_run/rule-candidates.md`
- **shared.test_cases.path**: `/docs/specs/features/{feature}/{version}/_run/test-cases.json`

Substitua todas as variáveis antes de ler ou escrever. Writers usam somente os paths v2; não criam aliases v1.

## Task v2

Toda task declara `risk: low|medium|high` e `validation: none|qa|full`. Campos v1 de modelo, esforço ou gates são erro de contrato.

- `none`: conteúdo sem efeito executável;
- `qa`: código localizado de risco baixo/médio;
- `full`: risco alto, área crítica ou mudança cross-module.

Áreas críticas são identificadas pelo propósito: autenticação/autorização, criptografia, migrations, segredos/configuração executável, contratos públicos e pagamentos.

## Execução

- Implemente no agente principal por padrão.
- Delegue gates independentes conforme `validation`.
- QA e Tech Review da mesma task são sequenciais.
- Paralelize somente tasks com dependências, símbolos e paths comprovadamente disjuntos.
- Não faça stage ou commit automático.
- Limite de três tentativas totais; a última usa o perfil crítico do adapter ativo.
- Reexecute apenas o gate afetado, exceto quando a correção muda comportamento ou estrutura.

## Saída dos gates

Use um único schema com `verdict`, `tests`, `criteria` e `findings[]`. Achados críticos, altos e médios bloqueiam; baixos são registrados no relatório.

## Estado

`state.json` é o único estado retomável. `report.md` é snapshot humano. Memória de retry só existe após rejeição e é removida ao aprovar.