## Camada 7 — Testes Automatizados (bloqueante)

- **Rastreabilidade CT→teste (auditavel)**: para cada CT-XX listado na secao de Testes da task, localize o teste implementado correspondente. Popule `rastreabilidade_cts` no JSON (`total` = numero de CTs exigidos; `sem_teste[]` = CTs sem teste implementado). CT sem teste → problema CRITICO + `REJEITADO` (camada COMPLETUDE). Esta apuracao e a prova estruturada de que a checagem aconteceu — nao dependa so da instrucao do orquestrador.
  - **Quando a secao de Testes tem a subsessao "Detalhamento dos Casos de Teste"** (§6.6 SDD / §5.6 miniSpec / §10.2.1 TaskCard): o card de cada CT e a especificacao canonica — verifique o teste implementado contra **Invariant** e **Resultado esperado** do card (assercao literal), nao apenas contra a linha da tabela-indice. Teste que existe mas nao prova a invariante do card = CT sem teste valido. A task markdown e a fonte de verdade — **NUNCA** leia `_run/test-cases.json` (artefato de geracao; pode estar atras de edicoes humanas feitas na task).

- **Testes exigidos pela task/spec DEVEM existir.** Se a task exige testes e eles estao ausentes/vazios/`skip`/`todo`/cobrindo cenarios diferentes → veredito `REJEITADO`, problema **CRITICO**. `correcao_sugerida` deve solicitar explicitamente a criacao dos testes faltantes.

- **Execucao de testes — estrategia condicional:**
  - **Suuite completa** (sem filtros) e obrigatoria quando a mudança toca codigo compartilhado (shared/core/utils/infra/http-client/auth/DI/rotas/schemas globais), OU altera API/contrato consumido por outras features, OU modifica build/deps/config.
  - **Escopo parcial** (testes da feature + dependentes diretos + smoke) e aceitavel quando a task e claramente isolada a um unico modulo sem acoplamento externo.
  - Use o comando de teste do projeto identificado no contexto carregado.
  - Se o projeto nao possuir framework de testes configurado E a task nao exigir criacao de testes, registre em `observacoes` e use `executou_testes: false`. Isso por si so nao rejeita.

- **Qualquer teste falhando → `REJEITADO`.** Inclusive testes pre-existentes de outras areas (regressao causada pela mudanca). Registre cada falha em `problemas.criticos` e em `testes_executados.detalhes_falhas`, marcando `e_regressao: true` quando aplicavel.

- Se nao for possivel executar os testes (ambiente/comando indisponivel) → problema **ALTO** em `problemas.altos[]`, explique em `observacoes`. Como ha problema ALTO registrado, o veredito sera `REJEITADO` pela politica debito-controlado (testes nao-executaveis sao risco real, nao debito estilistico).
