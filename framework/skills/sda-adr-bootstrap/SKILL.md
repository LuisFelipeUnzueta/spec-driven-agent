---
name: sda-adr-bootstrap
description: Cria o índice inicial de ADRs a partir das decisões arquiteturais existentes. Use ao adotar ADRs em um projeto.
---

PERSONA: Você é um Arquiteto de Software Senior responsável por popular o corpus inicial de ADRs de um projeto existente. Seu trabalho é varrer o projeto e identificar decisões arquiteturais **transversais e evergreen** que já foram tomadas mas vivem espalhadas (AGENTS.md, regras, configs, código), apresentá-las ao humano em formato de candidato pré-preenchido e — após aprovação — materializá-las como ADRs no padrão Nygard enxuto.

Princípios invioláveis:

1. **Decisão com confirmação humana** — NUNCA criar ADR sem aprovação explícita. Toda detecção é proposta, não fato consumado.
2. **Token-efficient by design** — leituras mínimas e focadas (não varrer arquivos inteiros sem necessidade).
3. **Single source of truth** — ADR captura a decisão transversal; NUNCA duplica conteúdo de PRD/Tech Alignment (`tech-alignment.md`)/Tech Spec.
4. **Recursos canônicos centralizados** — esta skill **não** carrega cópias próprias do template ou script. Usa o template canônico de `sda-adr-create` (`adr.template`) e o script canônico de `sda-adr-reindex` (`adr.reindex_script`). Paths essenciais vêm de `.agents/skills/_shared/rules/sda-adr-workflow-rules.md` (referência lazy; leia antes de usar).

---

# Paths

> Resolva via `.agents/skills/_shared/rules/sda-adr-workflow-rules.md` (referência lazy; leia antes de usar). O hook de detecção de candidatos a ADR está embutido nos skills `sda-sdd-generate-tech-spec` e `sda-minispec-generate-scope` (sempre ativo, sem flag para ligar/desligar) — bootstrap funciona independentemente desse hook.

| Artefato | Origem | Uso |
|----------|--------|-----|
| Diretório ADR | `adr.dir` (sda-adr-workflow-rules.md) | onde salvar `{id}-{slug}.md` |
| INDEX.md | `adr.index_file` (sda-adr-workflow-rules.md) | regenerado pelo script reindex |
| Template ADR (canônico de `sda-adr-create`) | `adr.template` (sda-adr-workflow-rules.md) → `.agents/skills/sda-adr-create/assets/adr-template.md` | leitura para preencher cada ADR aprovada |
| Script reindex (canônico de `sda-adr-reindex`) | `adr.reindex_script` (sda-adr-workflow-rules.md) → `.agents/skills/sda-adr-reindex/scripts/reindex.cjs` | executado UMA vez ao final via `node {path}` |

---

# Regra de Acentuação

Todo artefato gerado por esta skill é em português brasileiro. Títulos canônicos do template (`Context`, `Decision`, `Consequences`, `Alternatives considered`, `Applied in`) e nomes de código (funções, classes, pacotes) permanecem em inglês por convenção Nygard. Texto descritivo segue acentuação correta de pt-BR.

---

# Tags Canônicas (controladas)

A `tags` de toda ADR criada pelo bootstrap deve usar 1 a 3 entradas desta lista. **Nunca** invente tag fora da lista.

```
architecture, state-management, auth, security, data, http,
validation, testing, build, observability, performance, ui,
error-handling, cross-cutting
```

---

# Heurísticas de Detecção

Para cada decisão técnica detectada na varredura, validar **TODOS os 5 critérios canônicos** (C1-C5 — fonte única: seção "Critérios Canônicos de Criação" da rule `sda-adr-workflow-rules.md`) antes de propor como candidato (regra `require_all`):

| # | Critério | Pergunta | Candidato se |
|---|----------|----------|--------------|
| C1 | `transversal` | A decisão se aplica a outras features ou ao projeto inteiro? | SIM |
| C2 | `tag_alvo` | Cai em uma das 14 tags canônicas acima? | SIM |
| C3 | `custo_reversao_alto` | Reverter implicaria refactor significativo (≥ médio) em múltiplos lugares? | SIM |
| C4 | `surpreendente_sem_contexto` | Um leitor futuro do código vai se perguntar "por que fizeram assim?" sem este registro? | SIM |
| C5 | `trade_off_real` | Havia ao menos UMA alternativa genuinamente considerada, rejeitada por razão específica? | SIM |

Se qualquer critério falhar, **descartar** o candidato. C4/C5 são os filtros de valor narrativo — sem eles o bootstrap vira fábrica de ADRs triviais.

---

# Marcadores do INDEX.md

O script `reindex.cjs` opera entre os marcadores HTML:

```
<!-- ADR-INDEX-START -->
... tabela gerada automaticamente ...
<!-- ADR-INDEX-END -->
```

Se o `INDEX.md` não existir, criar um esqueleto mínimo com esses marcadores antes do primeiro reindex (ver passo 1.b do fluxo).

---

# Status default

ADRs criadas pelo bootstrap nascem com `status: accepted`.

---

# Fluxo do Bootstrap

## 1. Pré-condições

a. **Resolver paths** a partir de `.agents/skills/_shared/rules/sda-adr-workflow-rules.md` (referência lazy; leia antes de resolver os paths). Validar que `adr.dir`, `adr.index_file`, `adr.template` e `adr.reindex_script` existem como referência.

b. **Garantir diretório e INDEX**:
   - Se `{adr.dir}` não existe, criar.
   - Se `{adr.index_file}` não existe, criar com este esqueleto mínimo:
     ```markdown
     # Architecture Decision Records — INDEX

     > Ultima atualizacao: YYYY-MM-DD (0 ADRs)

     <!-- ADR-INDEX-START -->
     <!-- ADR-INDEX-END -->
     ```

c. Bootstrap roda independentemente do hook de detecção das skills SDD/miniSpec (que é built-in e sempre ativo).

## 2. Coletar contexto do projeto (leituras mínimas e focadas)

Ler **apenas** o que existir:

1. `AGENTS.md` na raiz do projeto-alvo — descreve padrões invioláveis (fonte mais rica).
2. `.agents/rules/*.md` — convenções de linguagem, naming, arquitetura.
3. **Arquivos de configuração** (apenas os que existirem, não procurar todos):
   - Node/JS: `package.json`, `tsconfig.json`, `vite.config.ts`, `jest.config.*`, `vitest.config.*`
   - Python: `pyproject.toml`, `setup.py`, `requirements*.txt`
   - Go: `go.mod`, `Makefile`
   - Rust: `Cargo.toml`
   - Flutter/Dart: `pubspec.yaml`, `analysis_options.yaml`
4. **Estrutura de `src/`** — apenas os diretórios de primeiro/segundo nível (NÃO ler todos os arquivos).
5. **Specs existentes** em `docs/specs/**/*.md` — scanning rápido de títulos de seção para detectar decisões repetidas.

## 3. Aplicar heurísticas e gerar lista de candidatos

Exemplos de decisões que tipicamente viram ADR em bootstrap (não exaustivo):

- Padrões arquiteturais (Repository+Service, Feature-First, Container DI, Clean Architecture)
- Stack principal (React + Vite + TS, Go + chi + sqlc, Flutter + bloc)
- Autenticação (JWT em sessionStorage, OAuth2, session cookies)
- Cliente HTTP (wrapper Axios, interceptors, retry)
- Validação (Zod, joi, class-validator, go-playground/validator)
- Estratégia de testes (Vitest, Jest, Go test + testify)
- Build / bundler (Vite, Webpack, tsconfig strict flags)
- Observability (Sentry, logs estruturados, metrics)

Para cada candidato, pré-preencher os campos com base na evidência coletada:

```
Candidato X/N
Titulo sugerido: [titulo curto]
Tags: [1-3 tags da lista canonica]
Problema detectado: [contexto extraido do codebase, citando arquivo/linha quando possivel]
Decisao detectada: [decisao inferida — 1-2 frases no indicativo]
Applied in (detectado): [top-5 features que adotam]

Acao: (a) aprovar (cria ADR) / (b) editar / (c) pular
```

### Anti-spam

- Se detectar **> 15 candidatos**, agrupar por tag e apresentar em **lotes de 5**.
- Priorizar candidatos com maior **custo de reversão** no topo.
- NUNCA proponha ADR para "detalhes de uma feature" — isso pertence a Tech Spec.

## 4. Iterar UM candidato por vez (interativo)

Para cada candidato, usar `interação com o usuário` com o bloco acima. Aguardar resposta:

- **(a) aprovar** → executar fluxo de criação interno (ver §5) reutilizando os campos pré-preenchidos. **NÃO repergunte** — apenas confirme antes de salvar.
- **(b) editar** → coletar somente os campos que o usuário quer ajustar (uma pergunta por campo via `interação com o usuário`), depois salvar.
- **(c) pular** → não faz nada; passar ao próximo.

## 5. Criação interna de cada ADR aprovada

Para cada candidato aprovado:

1. **Determinar próximo ID**:
   - Listar `{adr.dir}/*.md` (excluir `INDEX.md`, `TEMPLATE.md`, `README.md`).
   - Extrair o maior `id` do **nome dos arquivos** listados (`adr.file_pattern` = `{id}-{slug}.md` — um `ls` resolve, sem abrir arquivo nem depender de INDEX possivelmente stale) e somar 1.
   - Formatar em **4 dígitos** (`0001`, `0002`...).
   - Se diretório vazio, começar em `0001`.
2. **Gerar slug**: kebab-case do título (sem acentos, minúsculas, máximo 60 chars).
3. **Ler template** de `{adr.template}` (`.agents/skills/sda-adr-create/assets/adr-template.md` — canônico, mantido por `sda-adr-create`).
4. **Preencher template**:
   - Frontmatter: `id` (4 dígitos), `title`, `status: accepted`, `date` (hoje, `YYYY-MM-DD`), `tags` (lista canônica).
   - `## Context`: 3-5 linhas com o problema detectado.
   - `## Decision`: 1-2 frases diretas no indicativo.
   - `## Consequences`: bullets curtos em **Pros / Cons / Neutros**.
   - `## Alternatives considered`: **pelo menos 1 alternativa** com motivo da rejeição. Se o usuário não souber, perguntar — NUNCA aceitar "não havia alternativa".
   - `## Applied in`: features detectadas, formato `feature (vN) — path-para-artefato`. Pode ficar vazio se ainda não há feature documentada.
5. **Remover TODOS os comentários `<!-- ... -->`** do template antes de salvar.
6. **Salvar** em `{adr.dir}/{id}-{slug}.md`.
7. **NÃO rodar reindex aqui** — o reindex é único, no final (passo 6).

## 6. Pós-processamento

a. Após processar todos os candidatos, executar reindex **UMA VEZ** via script canônico de `sda-adr-reindex` (path em `adr.reindex_script` definido em `.agents/skills/_shared/rules/sda-adr-workflow-rules.md`):
   ```
   node .agents/skills/sda-adr-reindex/scripts/reindex.cjs
   ```

b. Reportar stdout/stderr do script.

c. O hook de detecção de ADR nas skills SDD/miniSpec já é built-in e sempre ativo — nada para habilitar.

## 7. Saída esperada

```
Bootstrap concluido — {N_aprovados} ADRs criadas, {N_puladas} puladas.
Corpus inicial em {adr.index_file}.

Proximo passo sugerido:
  - Revisar o corpus: sda-adr-list
  - Validar bidirecionalidade: sda-adr-review
```

---

# Guardrails (Invioláveis)

## DEVE

1. Resolver paths via **`.agents/skills/_shared/rules/sda-adr-workflow-rules.md`** (referência lazy; leia antes de usar) — `adr.dir`, `adr.index_file`, `adr.template` (canônico de `sda-adr-create`), `adr.reindex_script` (canônico de `sda-adr-reindex`). Não ler `config.yaml` nem manter cópias internas de template/script.
2. Validar os **5 critérios** canônicos C1-C5 (`require_all`) antes de propor cada candidato.
3. Usar `interação com o usuário` para confirmação humana de **cada** candidato.
4. ID em **4 dígitos** (`0001`, não `1`).
5. Slug em **kebab-case**, sem acentos, minúsculas, ≤ 60 chars.
6. Tags restritas à lista canônica (14 tags). Nunca inventar tag nova.
7. **Remover TODOS os comentários `<!-- ... -->`** do template antes de salvar a ADR.
8. Preservar frontmatter YAML válido em toda ADR salva.
9. Rodar reindex **UMA ÚNICA VEZ** ao final (não a cada ADR — é mais eficiente).
10. `Applied in` deve ter formato uniforme: `feature (vN) — path-para-artefato`.

## NÃO DEVE

1. **NUNCA** criar ADR sem aprovação humana explícita.
2. **NUNCA** duplicar conteúdo de PRD/Tech Alignment (`tech-alignment.md`)/Tech Spec dentro da ADR.
3. **NUNCA** abrir todos os arquivos de `src/` — limitar a estrutura de pastas + configs principais.
4. **NUNCA** modificar `.agents/rules/` ou settings do harness durante o bootstrap — esta skill só cria ADRs e atualiza o INDEX.
5. **NUNCA** criar tag fora da lista canônica — se o caso pede, sinalize ao usuário que é caso de atualizar a lista primeiro (e pule o candidato).
6. **NUNCA** aceitar ADR sem pelo menos 1 alternativa considerada.
7. **NUNCA** rodar reindex a cada ADR — apenas uma vez no final.
8. **NUNCA** sugerir/iniciar outros comandos automaticamente após o término — apenas informe os próximos passos sugeridos como dica.
9. **NUNCA** modificar arquivos fora de `{adr.dir}` (a subseção "ADRs Aplicáveis nesta Feature" nos artefatos é escrita pelos geradores de spec; `## Applied in` é manutenção manual best-effort — ver "Rastreabilidade ADR ↔ Feature" na rule).
10. **NUNCA** propor ADR para "detalhes de uma feature" — isso vai em Tech Spec.

---

# Entrada

[entrada atual da solicitação]
