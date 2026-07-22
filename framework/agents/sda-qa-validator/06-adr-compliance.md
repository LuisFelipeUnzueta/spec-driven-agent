## Camada 6 — Conformidade ADR Light (sweep grep-detectavel)

> **Objetivo**: pegar no Gate 1 violacoes triviais de ADRs que historicamente so apareciam no Gate 2 e cascateavam por multiplos arquivos (ex.: ADR de idioma de identificadores). NAO e validacao profunda — e grep + comparacao. Analise de impacto arquitetural permanece no Tech Review.

**Procedimento**:

1. Liste ADRs ativas: leia o indice em `docs/adr/INDEX.md` (ou liste `docs/adr/*.md` se indice ausente). Considere apenas ADRs com status `Accepted` (ignore `Deprecated`/`Superseded`).
2. Para cada ADR, identifique se a regra e **grep-detectavel** no diff. Leia o texto da ADR, isole o simbolo/identificador que ela **proibe ou exige**, e traduza para um grep na **sintaxe da stack descoberta** (ver "Descoberta de Stack"). Ex. (multi-stack): "identificadores em ingles" → grepar identificadores no idioma proibido (tags de serializacao, nomes de campo/rota/metodo — `json:`/`form:` em Go, `@JsonKey`/`@SerializedName` em Dart/Kotlin, `alias=`/`Field(` em Python, decorators em TS); "soft delete via metodo canonico" → grepar o nome de metodo proibido nos arquivos da camada de dados.
3. Para cada violacao grep-detectavel encontrada em arquivos tocados pela task:
   - Adicione item em `problemas.*` com `categoria: "adr_compliance"` e `adr_referenciada: "ADR-XXXX"` no corpo da `correcao_sugerida`.
   - **Severidade**: **contradicao DIRETA a uma decisao concreta e explicita** que a ADR fixa (path/diretorio canonico do arquivo, biblioteca, identificador, naming) → **no minimo `alto`** (bloqueia). Nao rebaixe para `medio` porque o codigo "parece mais certo" que a ADR — resolver isso (conformar vs superseder) e decisao do usuario, nao sua. Mesmo que hoje o medio tambem bloqueie (entra no loop de correcao), uma contradição arquitetural direta merece `alto` para nao diluir sua severidade; rebaixa-la para `medio` foi o que, na politica antiga (medio passava como debito anotado), deixou o caso `arquitetura-projeto` shipar contrariando a ADR-0003 (logger em `internal/platform/logger` vs `pkg/logger` exigido). Demais desvios grep-detectaveis → severidade conforme impacto (`medio`/`alto`). **A localizacao/path do arquivo e grep-detectavel** (compare o diretorio real do arquivo no diff contra o path que a ADR fixa).
   - Liste em `adr_compliance.violacoes_grep_detectaveis[]` (campo do JSON).
4. **NAO** abra mais que 1-2 ADRs em modo Read completo — confie no indice + grep dos arquivos do diff. Se a ADR nao e grep-detectavel (decisao estrutural), **DEFERA** ao Tech Review e nada faca aqui.

**Casos tipicos detectaveis** — a regra concreta vem SEMPRE da ADR ativa do projeto host; os exemplos abaixo sao ilustrativos, **multi-stack e nao um catalogo fixo**. Traduza cada padrao para a sintaxe da stack descoberta:
- **ADR de idioma de identificadores**: grep nos arquivos tocados por identificadores no idioma proibido — qualquer mecanismo da stack (tags de serializacao, nomes de campo/metodo/rota).
- **ADR de naming canonico** (ex.: soft delete via metodo dedicado, factory vs construtor direto): grep pelo simbolo proibido na camada relevante.
- **ADR proibindo acesso direto a um recurso** (ex.: instanciar pool de DB / cliente de SDK fora do ponto de composicao/DI): grep pelo construtor proibido fora dos arquivos de bootstrap/providers.
- **ADR de provider/singleton para SDK**: grep por instanciacao direta do SDK fora do ponto unico permitido.

> Como derivar o grep: leia o texto da ADR, identifique o simbolo que ela proibe/exige, e escreva o grep na sintaxe da stack (descoberta na secao "Descoberta de Stack"). Se a ADR nao tem simbolo grep-detectavel (decisao estrutural), **DEFERA** ao Tech Review.

> **Por que aqui e nao no Tech Review**: as violacoes grep-detectaveis cascateiam por N arquivos quando descobertas tarde (ADR-0010 do post-mortem cadastro-pratos-franquia atingiu T5/T6/T7). Pegar no Gate 1 evita 1-2 rodadas de correcao downstream.
