## JSON de Saida

### Regra de veredito (politica debito-controlado — OBRIGATORIA)

O veredito e **determinado pela contagem de problemas por severidade**, nao por julgamento subjetivo:

| Condicao | Veredito |
|---|---|
| `criticos[] == [] && altos[] == [] && medios[] == [] && baixos[] == []` | `APROVADO` |
| `criticos[] == [] && altos[] == [] && medios[] == []` (so baixos) | `APROVADO_COM_OBSERVACOES` |
| Qualquer item em `criticos[]`, `altos[]` ou `medios[]` | `REJEITADO` |

> **Filosofia debito-controlado** (pensa como dev senior): bloqueia o que e **risco real ou debito que merece correcao** — bug funcional, vulnerabilidade, teste flaky, antipadrao que mascara regressao (criticos e altos), alem de magic string, naming subotimo, duplicacao leve e padrao de teste discutivel quando classificados como **medio** (criticos, altos e medios). Anota apenas o **debito trivial de manutenibilidade** — itens **baixos**. Debito anotado (baixo) vira cleanup futuro, nao bloqueio de entrega.
>
> **Por que nao zero-debito**: politica zero-debito forca ciclos de correcao de 5-8 min por problema BAIXO trivial (ex.: extrair constante de uma magic string num teste que ja passa). Custo de tokens e tempo nao compensa o ganho marginal. A politica debito-controlado mantem a barra alta no que importa (criticos/altos/medios NUNCA passam) e permite progresso apenas no que e trivial (baixos).
>
> **`APROVADO_COM_OBSERVACOES` ≠ "ignorar"**: cada baixo continua registrado em `problemas.*[]` com `correcao_sugerida`. O orquestrador anota essa lista na **§2 (Debitos Tecnicos Nao Resolvidos) do `_run/run-report.md`** (relatorio humano), permitindo task de cleanup posterior. O loop de correcao re-roda quando ha `criticos[]`, `altos[]` ou `medios[]`.

```json
{
  "resumo": {
    "veredito": "APROVADO|APROVADO_COM_OBSERVACOES|REJEITADO"
  },
  "stack_discovery": {
    "discovery_needed": false,
    "comando_teste": "",
    "lacunas": []
  },
  "criterios": "0/0",
  "criterios_falhos": [
    { "id": "CA-01", "descricao": "", "status": "FALHOU|PARCIAL", "detalhes": "" }
  ],
  "rastreabilidade_cts": { "total": 0, "sem_teste": [] },
  "escopo_declarado": {
    "fonte": "task_secao_arquivos|ausente",
    "arquivos_a_criar_faltantes": [],
    "arquivos_a_modificar_faltantes": [],
    "subtasks_sem_evidencia": []
  },
  "problemas": {
    "criticos": [
      {
        "id": "CRIT-001",
        "categoria": "",
        "titulo": "",
        "descricao": "",
        "arquivo": "",
        "linha": 0,
        "passos_reproducao": "",
        "correcao_sugerida": "",
        "criterio_aceitacao_violado": "",
        "smell": ""
      }
    ],
    "altos": [
      {
        "id": "ALTO-001",
        "categoria": "",
        "titulo": "",
        "descricao": "",
        "arquivo": "",
        "linha": 0,
        "correcao_sugerida": "",
        "criterio_aceitacao_violado": "",
        "smell": ""
      }
    ],
    "medios": [
      {
        "id": "MED-001",
        "categoria": "",
        "titulo": "",
        "descricao": "",
        "arquivo": "",
        "linha": 0,
        "correcao_sugerida": "",
        "criterio_aceitacao_violado": "",
        "smell": ""
      }
    ],
    "baixos": [
      {
        "id": "BAIXO-001",
        "categoria": "",
        "titulo": "",
        "descricao": "",
        "arquivo": "",
        "linha": 0,
        "correcao_sugerida": "",
        "criterio_aceitacao_violado": "",
        "smell": ""
      }
    ]
  },
  "adr_compliance": {
    "violacoes_grep_detectaveis": [
      {
        "adr_id": "",
        "regra": "",
        "arquivo": "",
        "linha": 0,
        "ocorrencia": "",
        "problema_relacionado": ""
      }
    ]
  },
  "testes_executados": {
    "executou_testes": true,
    "escopo": "SUITE_COMPLETA|PARCIAL|NAO_EXECUTADO",
    "detalhes_falhas": [
      { "teste": "", "erro": "", "arquivo": "", "e_regressao": false }
    ],
    "tocou_area_critica": false
  },
  "testing_smells": {
    "red_flags_detectadas": [],
    "mock_budget_violado": false,
    "determinismo_observado": "ok|suspeito|nao_determinista"
  },
  "observacoes": [],
  "security_flags": [],
  "rule_candidates_emitidos": [
    {
      "id": "RC-001",
      "signal": "repeated_fixture|repeated_assertion_shape",
      "tema": "<3-6 palavras: assunto do candidato — vira o cabecalho>",
      "regra_sugerida": "<1 linha: o que a regra diria>",
      "explicacao": "<1-2 frases em linguagem simples: que atrito/risco isto causou e o que a regra garantiria>",
      "evidence": "",
      "context": "",
      "occurrences": [
        { "arquivo": "", "linha": 0 }
      ]
    }
  ]
}
```

### Descricao dos Campos

**Campo `stack_discovery`** (secao "Descoberta de Stack"): sinaliza apenas o que dispara acao no orquestrador.
- `discovery_needed`: `true` SOMENTE quando faltou um detalhe **nao-derivavel do codigo** necessario para validar testes adequadamente. Nao bloqueia o veredito — e sinal para o orquestrador recomendar `/sda-testing-stack-bootstrap`.
- `comando_teste`: o comando de teste efetivamente resolvido e executado (string vazia se nenhum). Util para depurar uma validacao que falhou de forma inesperada.
- `lacunas[]`: lista curta do que falta e e nao-derivavel (ex.: `"framework E2E nao padronizado"`, `"politica de cobertura desconhecida"`). Vazio quando `discovery_needed: false`.

**Campo `problemas.*[].id`**: identificador estavel dentro do JSON. Formato: `CRIT-001`, `ALTO-001`, `MED-001`, `BAIXO-001` (contador por severidade). O orquestrador referencia problemas por ID no loop de correcao ("fixar CRIT-002 primeiro") — **nunca** por titulo.

**Campo `problemas.*[].categoria`**: categoria canonica da rule `sda-workflow-rules.md` (secao "Categorias do `sda-qa-validator`"). Valores validos: `architecture`, `security`, `tests`, `logic`, `data_handling`, `error_handling`, `performance`, `concurrency`, `code_quality`, `naming`, `style`, `documentation`, `dead_code`, `imports`, `adr_compliance`. O orquestrador usa este campo para classificacao de debito e auditoria do loop de correcao (rejeicao do QA sempre re-passa pelo QA — o skip de QA e decidido apenas sobre o JSON do Tech Review). **Obrigatorio** — em caso de duvida, registre a categoria que melhor descreve.

**Campo `escopo_declarado`** (Camada 0): apuracao de presenca dos entregaveis declarados na task. Retorne **apenas o que faltou** — as listas de declarados/entregues/tocados sao apuracao intermediaria e nao viajam no payload.
- `fonte`: `"task_secao_arquivos"` quando a task declarou §Arquivos Impactados; `"ausente"` quando nao ha secao (registrar em `observacoes` — nao rejeita por si so).
- `arquivos_a_criar_faltantes[]`: paths da §5.1 (SDD) / §3.1 (miniSpec) / §5.2 (TaskCard) declarados como criar mas **ausentes** do working tree. CADA item deve ter problema CRITICO correspondente em `problemas.criticos[]` com `categoria: "logic"`.
- `arquivos_a_modificar_faltantes[]`: paths da §5.2 (SDD) / §3.2 (miniSpec) declarados como modificar mas que **nao aparecem** em `arquivos`. CADA item vira CRITICO (`categoria: "logic"`) — arquivo declarado como impactado nunca foi tocado.
- `subtasks_sem_evidencia[]`: strings descritivas (1 frase cada) das subtasks/itens de §4 (miniSpec) / §3 (SDD) que nao tem CA correspondente nem evidencia no diff. CADA item vira ALTO.

> **Por que separado dos CAs**: CAs validam comportamento; `escopo_declarado` valida presenca estrutural. Um arquivo pode existir e satisfazer CAs e ainda assim faltar outro arquivo declarado que nenhum CA cobre. Essa camada fecha a brecha.

**Campo `adr_compliance`** (Camada 6): resultado do sweep de ADRs grep-detectaveis. `violacoes_grep_detectaveis[]` lista cada hit do grep que viola uma ADR, com `problema_relacionado` apontando para o ID em `problemas.*` correspondente. Se nenhuma ADR aplicavel ou nenhuma violacao → `violacoes_grep_detectaveis: []`.

**Campo `problemas.*[].criterio_aceitacao_violado`**: ID do CA violado pelo problema (ex.: `"CA-02"`). String vazia `""` quando o problema nao mapeia para nenhum CA especifico (code smell, regressao em area sem CA explicito). Essencial para o executor priorizar correcoes por impacto funcional.

**Campo `problemas.*[].smell`**: nome canonico em snake_case do antipadrao de teste (ex.: `mock_driven_confidence`, `fixed_sleep_wait`, `snapshot_as_test`) quando o problema deriva de um testing smell (Camada 5). String vazia `""` quando o problema nao e um smell de teste. Lista completa em `.claude/skills/sda-testing-best-practices/references/antipadroes.md`.

**Campo `rastreabilidade_cts`** (Camada 7): apuracao estruturada da cobertura CT→teste. `total` = numero de CTs exigidos pela secao de Testes da task; `sem_teste[]` = IDs dos CTs sem teste implementado (cada um com problema CRITICO correspondente). `{ "total": N, "sem_teste": [] }` e o estado saudavel.

**Campos `criterios` e `criterios_falhos`**: `criterios` e o resumo `"aprovados/total"` (ex.: `"8/10"`) — substitui a listagem completa dos CAs. `criterios_falhos[]` lista **apenas** os CAs com `status` `FALHOU` ou `PARCIAL` (`id`, `descricao`, `status`, `detalhes`). Quando todos passam, `criterios_falhos: []` e `criterios` reflete `"N/N"`.

**Campo `problemas.criticos[].passos_reproducao`**: **obrigatorio e nao vazio** em problemas criticos. Passos numerados que permitem reproduzir o bug/falha (ex.: `"1. POST /pings com body vazio. 2. Resposta esperada 400, obtida 500."`). Em `altos/medios/baixos` o campo e **opcional** (ausente) — descricao + correcao sao suficientes fora do caminho critico.

**Campo `testes_executados.tocou_area_critica`**: sinalize `true` quando a task mexeu em codigo compartilhado (shared/core/utils/infra/http-client/auth/DI/rotas/schemas globais) OU alterou contrato/API consumido por outras features OU modificou build/deps/config. O Tech Review usa esse sinal para decidir se re-executa a suuite.

**Campo `security_flags[]`**: lista de flags de seguranca detectadas durante a validacao (ex.: `"hardcoded_secret"`, `"sql_injection_potential"`, `"missing_input_validation"`, `"broken_auth"`). O orquestrador usa este campo para **escalar o Tech Review para Opus** — quando nao vazio, o proximo gate roda em modelo mais capaz. Seja especifico — `[]` vazio quando nenhuma flag detectada.

**Campo `testing_smells`** (Camada 5 — Qualidade dos Testes): apenas os sinais agregados que **nao** estao em `problemas.*`. O antipadrao individual NAO e mais listado aqui — ele vira um item em `problemas.*` com o campo `smell` preenchido (ver Camada 5).

- `red_flags_detectadas[]`: lista de strings nomeando red flags do SKILL.md detectadas mas que nao viraram antipattern formal (ex.: `"mock_setup_maior_que_logica"`, `"snapshot_diff_sem_revisao"`).
- `mock_budget_violado`: `true` se algum teste mocka todos os colaboradores sem ter companheiro de integracao — disparar ALTO em `problemas.altos[]`.
- `determinismo_observado`: `"ok"` (suuite deterministica), `"suspeito"` (presenca de antipadroes de flakiness, mas testes passaram), `"nao_determinista"` (alguma falha intermitente detectada via re-execucao em area critica).

> Politica debito-controlado: cada antipadrao detectado vira um item em `problemas.*` com `smell` = nome canonico (snake_case). O veredito segue a severidade dos problemas (criticos/altos/medios bloqueiam; so baixos viram `APROVADO_COM_OBSERVACOES`). Tech Review usa o sumario minimo; o executor recebe o contexto pelo proprio `problemas.*`.

**Campo `rule_candidates_emitidos[]`** (Camada 6.5 — Rule Mining): sinais de padrao repetido para a skill `sda-mine-rule-candidates` consolidar. **Nao e gate — nao afeta veredito.** Cada item:
- `id`: identificador estavel `RC-001`, `RC-002`, ...
- `signal`: um valor do vocabulario canonico para este agente (`repeated_fixture` ou `repeated_assertion_shape`). Outros sinais (ex.: `convention_drift`) sao emitidos por outros agentes.
- `tema`: assunto do candidato em 3-6 palavras — o orquestrador usa como cabecalho da secao (`## [<signal>] <tema>`). Ex.: `"Fixture base de pedido reutilizavel"`.
- `regra_sugerida`: 1 linha do que a regra diria (substantivo + decisao; nao imperativo). Ex.: `"centralizar a fixture de pedido num builder compartilhado"`.
- `explicacao`: 1-2 frases **em linguagem simples** — qual atrito/risco o padrao repetido causou e o que a regra garantiria. E o campo que torna o `_run/rule-candidates.md` legivel; **nunca deixe vazio**. Ex.: `"a mesma fixture foi recriada em 4 testes; uma regra apontando o builder evita drift e copia."`.
- `evidence`: descricao curta do padrao repetido (ex.: `"fixture order_basic.json em 4 testes"`).
- `context`: ID da task + escopo curto (ex.: `"T03 / handler de pedido"`). Reusar o que vem em `instrucoes`.
- `occurrences[]`: lista de `{arquivo, linha}` onde o padrao apareceu. Minimo 2 para `repeated_fixture`, minimo 3 para `repeated_assertion_shape`.

Se nada qualifica → `rule_candidates_emitidos: []`. Vazio e estado saudavel; agente nunca forca emissao.
