## Camada 6.5 — Sinais para Rule Mining (nao-bloqueante — emite via JSON)

> **Objetivo**: capturar **padroes repetidos** que sugerem convencao implicita, para alimentar a skill `sda-mine-rule-candidates`. NAO e gate — e log lateral. **Nunca rejeite por sinais de rule mining.** A decisao de virar regra fica para `sda-mine-rule-candidates` + `sda-curate-project-rules` (que aplica teste de fricao fora do hot path).

**Diferenca para Camada 5 (testing smells)**:
- Smell = antipadrao prejudicial ao teste (bloqueia se critico/alto).
- Sinal de rule mining = padrao repetido que poderia ter sido **convencao escrita** (nao prejudica, mas sugere oportunidade).
- Mesmo padrao pode gerar **ambos** (ex.: fixture generica usada em 4 testes e AP-23 + `repeated_fixture`). Emita os dois, com IDs distintos.

**Sinais que VOCE emite** (vocabulario canonico — ver `sda-workflow-rules.md` secao "Candidatos a Regra"):

| Sinal | Quando emitir |
|---|---|
| `repeated_fixture` | Mesma fixture/mock/setup (mesmo path ou estrutura) usado em >=2 testes dos arquivos da task. |
| `repeated_assertion_shape` | Padrao de assert identico em >=3 lugares (normalize literais para placeholders antes de comparar). |

**Regras de emissao**:
1. **Evidencia verificavel obrigatoria**: pelo menos um `arquivo:linha` real. Sem isso, nao emita.
2. **Nao emita sinal unico isolado**: se aparece so 1 vez, nao e repeticao.
3. **Nao emita duplicado**: se ja emitiu `repeated_fixture` para `fixtures/order_basic.json`, nao emita de novo no mesmo run para a mesma fixture.
4. **Nao emita para frameworks/libs externas**: padrao repetido vindo de `node_modules/`, `vendor/`, `.venv/` nao e convencao do projeto.
5. **Se nenhum sinal qualifica**: retorne `rule_candidates_emitidos: []`. Vazio e o estado saudavel (o agente nao forca emissao).

Popule `rule_candidates_emitidos[]` no JSON. Orquestrador persistira em `shared.rule_candidates.path`.
