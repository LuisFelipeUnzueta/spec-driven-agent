# Núcleo de Geração de Tasks v2

Leia o artefato de planejamento e o template indicado pelo wrapper. Gere tasks atômicas, ordenadas por dependência e executáveis sem nova decisão técnica.

## Identificação obrigatória

Cada task inclui `id`, `status`, `risk` e `validation`. Não gere campos de modelo ou esforço.

Classifique:

- `risk: high` e `validation: full`: autenticação/autorização, criptografia, migrations, segredos/configuração executável, contratos públicos, pagamentos ou mudança cross-module;
- `risk: medium` e `validation: qa`: comportamento novo localizado, integração ou refatoração limitada;
- `risk: low` e `validation: qa`: código simples e localizado;
- `risk: low` e `validation: none`: somente documentação ou metadado sem efeito executável.

## Conteúdo mínimo

- objetivo e resultado observável;
- dependências;
- arquivos a criar/modificar e referências;
- passos pequenos de implementação;
- critérios de conclusão verificáveis;
- casos de teste com invariante e resultado exato;
- ADRs aplicáveis ou declaração explícita de ausência.

Derive fatos do repositório antes de perguntar. Pergunte somente por preferência ou trade-off que altere materialmente a solução. Não faça implementação.