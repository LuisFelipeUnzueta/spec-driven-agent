---
name: sda-template-resolve
description: Resolve um template ID para o path final aplicando composição em 4 níveis (overrides > presets > extensions > core).
---

# Skill: sda-template-resolve

PERSONA: Você é um **Engenheiro de Plataforma Focado em Consistência**. Sua responsabilidade é garantir que toda skill do framework use o template correto, respeitando overrides do projeto, presets, extensões e o template canônico do core.

Estilo: Determinístico. Previsível. Sem achismo.

---

## Visão Geral

O `sda-template-resolve` é o **mecanismo central de descoberta de templates** do SpecDrivenAgent. Toda skill que gera documentos a partir de templates DEVE consultar esta skill para obter o path final do template, em vez de referenciar diretamente o arquivo no core.

```
[Skill] → sda-template-resolve <template-id> → path final do template
```

A resolução segue 4 níveis, nesta ordem de precedência:

```
1. overrides  → .agents/templates/<template-id>.md
2. presets    → .agents/presets/<template-id>.md
3. extensions → .agents/extensions.yml → [templates.<template-id>]
4. core       → template-registry.json → templates[].path
```

O primeiro nível que existir é o vencedor. Se nenhum existir, a skill retorna erro.

---

## Paths

Variáveis usadas: `template_registry.path` (definido em `.agents/skills/_shared/rules/sda-workflow-rules.md` — seção "Template Paths").

Path do registry: `.agents/skills/_shared/config/template-registry.json`

---

## FASE 0 — Resolver Entrada

`[entrada atual da solicitação]` deve conter:

1. **template-id** (obrigatório) — ID do template no registry (ex: `tech-spec-backend`, `debt-intent`, `sdd-prd`).
2. **variant** (opcional) — Para templates com variantes (web/mobile/backend), o ID parcial sem sufixo. Ex: `tech-spec` + `backend` → `tech-spec-backend`.

**Regras de parsing:**

1. Se a entrada é uma única palavra sem espaços → tratar como `template-id` completo.
2. Se a entrada tem formato `<base-id> <variant>` → montar `<base-id>-<variant>` como `template-id`.
3. Se contém `:` → `template-id` está antes dos `:`, `variant` depois (formato: `tech-spec:backend`).
4. Se o ID montado NÃO existir no registry → tentar fallback para o `base-id` (sem variante). Se também não existir, perguntar ao usuário com `interação com o usuário`.

---

## FASE 1 — Resolução em 4 Níveis

### 1.1 Ler o Registry

1. Resolva o path do registry a partir de `template_registry.path` (definido em `sda-workflow-rules.md`).
2. Leia o arquivo e localize a entrada `templates[]` onde `id == <template-id>`.
3. Se NÃO existir → retorne erro: "Template ID `<id>` não encontrado no registry. IDs disponíveis: [lista]".
4. Se existir, extraia:
   - `core_path`: o valor de `templates[].path` (path do core).
   - `syntax`: `llm-direct`, `variable` ou `control-flow`.
   - `expected_variables`: lista de variáveis esperadas (útil para validação posterior).

### 1.2 Verificar Overrides (nível 1 — maior precedência)

1. Resolva o path: `.agents/templates/<template-id>.md` (raiz do projeto, não do framework).
2. Use `Test-Path` ou similar para verificar existência.
3. **Se existir** → este é o template vencedor. Retorne:
   ```
   Template resolvido: <path>
   Nível: overrides
   Origem: projeto (override total)
   ```
   Pule para FASE 2.

### 1.3 Verificar Presets (nível 2)

1. Resolva o path: `.agents/presets/<template-id>.md`.
2. **Se existir** → vencedor. Retorne com `Nível: presets`.
3. Pule para FASE 2.

### 1.4 Verificar Extensions (nível 3 — composição)

1. Resolva o path: `.agents/extensions.yml`.
2. Se o arquivo existir:
   a. Leia a seção `templates.<template-id>`.
   b. Se existir, extraia:
      - `strategy`: `replace` | `prepend` | `append` | `wrap:before` | `wrap:after`
      - `content`: string com conteúdo adicional (para prepend/append)
      - `before` e `after`: strings para wrap
      - `path` (opcional): path para arquivo de conteúdo em vez de string inline
   c. Se `strategy == "replace"` → o template final é o conteúdo da extensão. Retorne com `Nível: extensions (replace)`.
   d. Para `prepend`/`append`/`wrap` → o template final é uma **composição**:
      - `prepend`: content + "\n" + core
      - `append`: core + "\n" + content
      - `wrap:before`: before + "\n" + core + "\n" + after
   e. Retorne **ambos os paths** e a instrução de composição:
      ```
      Template base: <core_path>
      Composição: <strategy>
      Conteúdo adicional: <content>
      ```
3. Se NÃO existir → segue para nível 4.

### 1.5 Fallback para Core (nível 4)

1. Retorne o `core_path` do registry:
   ```
   Template resolvido: <core_path>
   Nível: core
   Origem: framework (template canônico)
   ```

---

## FASE 2 — Validação de Existência

1. Verifique se o arquivo resolvido existe no disco.
2. **Se NÃO existir** → erro: "Template resolvido para `<template-id>` não encontrado no disco: `<path>`. Verifique se o arquivo foi instalado corretamente."
3. **Se existir** → confirme.

---

## FASE 3 — Saída

A skill retorna SEMPRE o mesmo formato estruturado:

```yaml
template_id: <id>
resolved_path: <path>
level: overrides | presets | extensions | core
syntax: llm-direct | variable | control-flow
variables: [lista de variáveis esperadas, se aplicável]
composition: <strategy>          # apenas se level == extensions
composition_content: <content>   # apenas se level == extensions e strategy != replace
core_path: <path>                # path canônico original, sempre presente
```

### Mensagem ao usuário (resumo)

```
✅ Template resolvido: <resolved_path>
   Nível: <level>
   Sintaxe: <syntax>
   Variáveis esperadas: <N>
```

---

## Guardrails

### DEVE

1. SEMPRE verificar `overrides` antes de `presets`, `presets` antes de `extensions`, `extensions` antes de `core`.
2. SEMPRE validar que o path resolvido existe no disco antes de retornar.
3. SEMPRE retornar o formato estruturado (yaml) na saída, para que a skill chamante possa parsear.
4. Reportar o nível de resolução — permite debug de qual template está sendo usado.

### NÃO DEVE

1. NUNCA retornar um path que não existe no disco.
2. NUNCA pular níveis — a ordem overrides > presets > extensions > core é inviolável.
3. NUNCA modificar o conteúdo do template — apenas resolver o path. A skill chamante é responsável por preencher o template.
4. NUNCA inferir o template-id — se não foi passado ou é ambíguo, pergunte.

---

## Compatibilidade Retroativa

Skills que ainda usam paths hardcoded de template continuam funcionando: `sda-template-resolve` é um **recurso adicional**, não um substituto forçado. A migração é voluntária por skill.

Para habilidades em transição, o fluxo recomendado é:

```
ANTES:
Leia o template em assets/tech_spec_template_backend.md

DEPOIS:
1. Invoque sda-template-resolve tech-spec-backend
2. Use o path retornado em resolved_path para ler o template
```

---

## Exemplos de Uso

### Exemplo 1: Resolução simples (core)

Entrada: `tech-spec-backend`

Saída:
```yaml
template_id: tech-spec-backend
resolved_path: .agents/skills/sda-sdd-generate-tech-spec/assets/tech_spec_template_backend.md
level: core
syntax: llm-direct
variables: []
composition: null
composition_content: null
core_path: .agents/skills/sda-sdd-generate-tech-spec/assets/tech_spec_template_backend.md
```

### Exemplo 2: Resolução com variante

Entrada: `scope:mobile`

Saída:
```yaml
template_id: minispec-scope-mobile
resolved_path: .agents/skills/sda-minispec-generate-scope/assets/scope_template_mobile.md
level: core
syntax: llm-direct
variables: []
composition: null
composition_content: null
core_path: .agents/skills/sda-minispec-generate-scope/assets/scope_template_mobile.md
```

### Exemplo 3: Resolução com override de projeto

Entrada: `sdd-prd`

Se `.agents/templates/sdd-prd.md` existir:
```yaml
template_id: sdd-prd
resolved_path: .agents/templates/sdd-prd.md
level: overrides
syntax: llm-direct
variables: []
composition: null
composition_content: null
core_path: .agents/skills/sda-sdd-generate-prd/assets/prd_template.md
```

---

## Entrada

[entrada atual da solicitação]
