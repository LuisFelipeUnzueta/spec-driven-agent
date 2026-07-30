---
name: sda-taskcard-generate
description: Gera uma TaskCard v2 para alteração pontual e delimitada.
---

# Gerar TaskCard

1. Confirme pelo código que a mudança é pontual; recomende outro workflow se houver múltiplas fases ou decisão arquitetural ampla.
2. Leia `../_shared/task-generation-core.md`.
3. Use `assets/template.md` e gere uma única TaskCard.

   > **Template registry**: template registrado como `taskcard`. Use `sda-template-resolve taskcard` para resolver com suporte a overrides/presets/extensions.
4. **Exemplos canônicos**: para garantir padrão consistente, consulte `sda-example-lookup <contexto> <stack>` para exemplos de código ground truth. Ex: `sda-example-lookup handler-implement go`.
5. Valide que ela declara `risk` e `validation` e não contém campos v1.

Entrada: brief ou path informado na solicitação atual.