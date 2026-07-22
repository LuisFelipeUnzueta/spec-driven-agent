## Camada 0 — Completude de Escopo Declarado (bloqueante — PRIMEIRA camada)

> **Objetivo**: garantir que TODOS os entregaveis estruturais declarados na task foram efetivamente construidos. Pega entregas parcialmente esquecidas pelo executor que CAs frouxos nao cobririam (ex.: task lista 3 endpoints + 1 migration; executor entregou 2 endpoints; CAs genericos passariam).
>
> **Filosofia**: este gate NAO valida funcionalmente os arquivos — apenas **presenca**. Validacao funcional fica nas Camadas 1-4. Presenca e o pre-requisito.

**Procedimento**:

1. **Extraia a lista autoritativa de entregaveis** da task (caminhos relativos):
   - SDD: secao `§5.1 Arquivos a Criar` + `§5.2 Arquivos a Modificar` da task `T{n}.md`.
   - miniSpec: secao `§3.1 Arquivos a Criar` + `§3.2 Arquivos a Modificar`.
   - TaskCard: secao `§5.2 Arquivos a Criar` + `§5.3 Arquivos a Modificar` (a §5 chama-se "Arquivos Envolvidos" e fica logo apos o Escopo).
   - Se a task NAO declarar lista de arquivos (ex.: TaskCard trivial sem secao), registre em `observacoes` e marque `escopo_declarado.fonte: "ausente"`. Nao rejeite por isso — apenas sinaliza menor cobertura desta camada.
2. **Cruze contra o efetivamente entregue**:
   - **Criar**: para cada path em `§Arquivos a Criar`, confirme que o arquivo existe no working tree (use Read/Glob). Faltante → CRITICO em `problemas.criticos[]` com `categoria: "logic"` (entregavel ausente e falha de implementacao).
   - **Modificar**: para cada path em `§Arquivos a Modificar`, confirme que o arquivo esta em `arquivos` (lista recebida do orquestrador) — sinal de que foi tocado. Se algum path declarado NAO esta em `arquivos`, levante como CRITICO (`categoria: "logic"`): arquivo declarado como impactado nao aparece no diff da task.
3. **Subtasks/itens de implementacao** (§4 Detalhes de Implementacao do miniSpec / §3 Descricao Detalhada do SDD): se houver checklist explícito (`- [ ] Subtask N`), confirme mencao ou cobertura via CA. Subtask sem CA correspondente E sem evidencia no diff → ALTO em `problemas.altos[]` (`categoria: "logic"`).
4. **NAO** invada validacao funcional — apenas existencia/presenca. Se o arquivo existe mas e stub vazio, isso vira problema funcional nas camadas 1-4.

Popule `escopo_declarado` no JSON **apenas com os faltantes** (a apuracao de declarados/entregues/tocados e interna e nao viaja no payload).
