## Camada 5 — Qualidade dos Testes (testing smells)

Aplique a doutrina `sda-testing-best-practices` aos arquivos de teste tocados pela task. Detecte:

- **Mock-driven confidence** (AP-10): assertion em valor que o proprio teste plantou no mock. → **CRITICO**.
- **Retry-as-fix** (AP-22): configuracao de retry mascarando flakiness sem telemetria. → **CRITICO**.
- **Snapshot-as-test** (AP-04) sem classificacao `PRODUCT_CONTRACT`: snapshot de texto UI, mensagem, DOM, JSON interno. → **CRITICO**.
- **Weakening test to pass** (AP-24): assertion enfraquecida no mesmo commit do fix. → **CRITICO**.
- **Fixed sleep/wait** (AP-07): `sleep`, `Thread.sleep`, `cy.wait(N)` com tempo fixo. → **ALTO**.
- **Test order dependency** (AP-08): teste falha com `.only` ou em ordem alternada. → **ALTO**.
- **Non-deterministic input** (AP-09): relogio/RNG/locale sem injecao — qualquer que seja a stack (ex.: `Date.now()`/`Math.random()` em JS-TS, `time.Now()`/`rand` em Go, `DateTime.now()`/`Random()` em Dart, `datetime.now()`/`random` em Python, `System.currentTimeMillis()` na JVM). → **ALTO**.
- **Happy-path only** (AP-16): sem negative companion para casos positivos. → **ALTO**.
- **Mock drift / over-mock / incomplete mock / mock at wrong level** (AP-11..14). → **ALTO**.
- **Mock of own repository** (AP-27): mockar o proprio repository/adapter do modulo em vez de usar o real contra DB efemer — confianca fabricada na camada que mais quebra. → **ALTO**.
- **Testing internal structure / private method** (AP-02, AP-03). → **ALTO**.
- **Action without assertion** (AP-06). → **ALTO**.
- **Brittle selector** (AP-01): selector por classe CSS, indice ou xpath. → **MEDIO**.
- **Vague existence assertion** (AP-05): `.toBeTruthy()`, `.toBeDefined()` sem valor especifico. → **MEDIO**.
- **Tautological assertion** (AP-29): assercao infalivel que nunca pega regressao — ramo sempre-verdadeiro numa disjuncao (`assert(A || cond)` com `cond` ja garantida por assercao anterior), `expect(true).toBe(true)`, valor comparado consigo mesmo. **Distinto de AP-05**: aqui e *infalivel*, nao so frouxo. → **ALTO** (mascara regressao — Iron Law #1; severidade alinhada com o Tech Review).
- **Testing third-party** (AP-20): teste que valida comportamento de biblioteca/framework de terceiro em vez do codigo do projeto. → **ALTO**.
- **Untestable fail-fast** (AP-28): guard/fail-fast inalcançavel por teste (panico/exit em condicao que nenhum input externo produz) sem justificativa — sinal de codigo morto ou seam ausente. → **ALTO**.
- **Coverage as vanity** (AP-15) / **Quarantine as cemetery** (AP-21) / **Eternal beforeAll** (AP-17) / **Duplicate cross-layer** (AP-23). → **MEDIO**.
- **Magic strings** (AP-19) / **Cleanup in afterEach** (AP-18). → **BAIXO**.
- **AI zero edge cases** (AP-25): teste AI-gerado com 6+ assertions e zero negativo. → **ALTO**.
- **Semantically duplicated test** (AP-26): dois ou mais testes no MESMO arquivo (ou em arquivos da task) com mesma combinacao de `(Name, Method, Path/Symbol, Status/Result esperado)` validando o mesmo cenario com mudanca cosmetica (variavel renomeada, mesmo expectativa). → **MEDIO** (`categoria: code_quality`).
  - **Heuristica deterministica**: para cada par de testes nos arquivos tocados, compare a tupla `(test_name_normalizado, alvo_chamado, parametros_chave, resultado_esperado)`. Se duas tuplas coincidem em >= 3 dos 4 campos sem justificativa visivel (table-driven nao conta — table-driven e UM teste parametrizado), reporte como duplicata.
  - **Fix**: consolidar em um unico teste parametrizado (table-driven) ou remover o redundante.

Para cada smell detectado, popule `problemas.{criticos|altos|medios|baixos}[]` com `id`, `arquivo`, `linha`, `correcao_sugerida` e o campo `smell` = nome canonico (ex.: `"mock_driven_confidence"`).

Tambem avalie os **15 red flags** do `SKILL.md`. Se detectados, registre os nomes em `testing_smells.red_flags_detectadas[]` (nao duplicar com os smells ja em `problemas.*`).
