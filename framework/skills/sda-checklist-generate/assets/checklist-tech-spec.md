# Checklist de Qualidade — Tech Spec (SDD)

> Checklist é um **teste de unidade para requisitos**. Ele valida a qualidade da especificação técnica, não a implementação.

> Use este checklist na skill `sda-checklist-generate` para avaliar a qualidade do Tech Spec antes de gerar o Task Plan.

---

## A. Rastreabilidade (cada item do PRD virou definição técnica?)

- [ ] Cada User Story do PRD tem mapeamento explícito para definição técnica
- [ ] Cada Critério de Aceite do PRD tem cobertura na estratégia de testes
- [ ] Não há definição técnica órfã (sem User Story correspondente)

## B. Completude Técnica

- [ ] Stack e versões estão definidas
- [ ] Persistência (tabelas, esquemas, índices) está especificada
- [ ] Contratos de API (endpoints, formato, erros) estão definidos
- [ ] Integrações externas e mensageria estão mapeadas
- [ ] Observabilidade (logs, métricas, tracing) está prevista

## C. Decisões com Trade-offs

- [ ] Toda escolha de tecnologia/ferramenta tem justificativa
- [ ] Alternativas consideradas estão documentadas
- [ ] Padrões adotados (sync/async, polling/webhook, etc.) têm rationale

## D. Tratamento de Erro e Edge Cases

- [ ] Timeouts de chamadas externas estão definidos
- [ ] Comportamento sob falha parcial está descrito
- [ ] Concorrência (requests simultâneos) tem estratégia
- [ ] Idempotência está garantida onde aplicável
- [ ] Limites de input (tamanho, volume) estão especificados

## E. Arquivos e Impacto

- [ ] Todos os arquivos a criar estão listados
- [ ] Todos os arquivos a modificar estão listados
- [ ] Código existente reutilizado está referenciado

## F. Clareza

- [ ] Termos técnicos são consistentes com o glossário de domínio
- [ ] Seções do template estão preenchidas (ou marcadas N/A com justificativa)
- [ ] Comentários `<!-- LLM-ONLY -->` foram removidos

---

## Pontuação

Total de itens: 24. Mínimo para avançar: 20 (83%).

| Resultado | Pontuação | Ação |
|-----------|-----------|------|
| ✅ Aprovado | ≥ 20 pontos (83%) | Pronto para Task Plan |
| ⚠️ Ressalvas | 15-19 pontos (60-82%) | Revisar itens críticos antes de gerar tasks |
| ❌ Reprovado | < 15 pontos (< 60%) | Revisar Tech Spec antes de prosseguir |
