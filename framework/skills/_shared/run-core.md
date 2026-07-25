# Núcleo de Execução v2

Este contrato é compartilhado por SDD, miniSpec e TaskCard. Leia a configuração do workflow indicada pelo wrapper antes de executar.

## Entrada obrigatória

Cada task deve declarar:

```yaml
risk: low | medium | high
validation: none | qa | full
```

Campos v1 `model`, `reasoning_effort` e `gates` são inválidos na v2. Pare e solicite migração quando encontrá-los.

## Política de validação

- `none`: somente documentação ou metadado sem efeito executável.
- `qa`: código localizado de risco baixo ou médio.
- `full`: risco alto, mudança cross-module ou área crítica.

Áreas críticas: autenticação, autorização, criptografia, migrations, segredos/configuração executável, contratos públicos e pagamentos. Se a classificação declarada contrariar fatos do diff, eleve para `full` e registre o motivo.

## Estado

Use apenas:

- `_run/state.json`: estado de tasks, `base_sha`, tentativas e vereditos resumidos;
- `_run/report.md`: snapshot humano final;
- `_run/retry/{task-id}.json`: criado somente após rejeição e removido após aprovação.

Não faça stage ou commit. Capture um `base_sha` no início do workflow e revise o working tree filtrado pelos paths declarados.

## Fluxo

1. Valide repositório, task, dependências e working tree.
2. Inicialize ou retome `_run/state.json` sem apagar progresso válido.
3. Leia a disciplina do executor em `executor-discipline.md`.
4. Implemente no agente principal por padrão.
5. Execute os testes direcionados descritos na task.
6. Aplique a validação declarada:
   - `none`: finalize após checagens determinísticas;
   - `qa`: delegue revisão independente ao papel `sda-qa-validator`;
   - `full`: execute QA e, após aprovação, `sda-staff-architecture-review`.
7. Normalize ambos os validation para o schema em `gate-output-schema.json`.
8. Em rejeição, envie somente findings bloqueantes ao executor e persista a memória de retry.
9. Reexecute apenas o gate afetado, salvo mudança comportamental ou estrutural que exija re-QA.
10. Após aprovação, remova a memória de retry e atualize estado e relatório.

## Tentativas

São permitidas três execuções totais: inicial e duas correções. A terceira usa o perfil `critical` de `.agents/sda-profiles.json`. Após nova rejeição, marque a task como bloqueada e peça decisão ao usuário.

## Revalidação

- Rejeição do QA sempre exige novo QA.
- Rejeição arquitetural exige novo QA quando houver mudança de comportamento, segurança, contrato, migration, tratamento de erro, performance ou arquivos tocados adicionais.
- Achado apenas de legibilidade/padrão local pode voltar diretamente ao Tech Review.
- Categoria desconhecida é conservadora e exige QA.

## Relatório

`state.json` deve conter apenas dados necessários para retomar:

```json
{
  "base_sha": "",
  "status": "in_progress|completed|blocked",
  "tasks": [
    {
      "id": "",
      "status": "pending|in_progress|completed|blocked",
      "risk": "low|medium|high",
      "validation": "none|qa|full",
      "attempts": 0,
      "qa": "not_run|approved|approved_with_notes|rejected",
      "review": "not_run|approved|approved_with_notes|rejected",
      "files": []
    }
  ]
}
```

`report.md` resume tasks concluídas/bloqueadas, testes executados, findings baixos remanescentes e próximos passos. Não replique telemetria detalhada.