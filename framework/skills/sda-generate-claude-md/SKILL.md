---
name: sda-generate-claude-md
description: Gera ou reduz instrucoes compartilhadas do projeto sem duplicar regras lazy ou evidencias do codigo.
---

# Instrucoes compartilhadas do projeto

O nome da skill e mantido por estabilidade. O resultado canonico e a orientacao curta, compartilhada e sempre carregada do projeto.

1. Leia as instrucoes existentes e preserve integralmente blocos gerenciados pelo framework.
2. Descubra apenas fatos verificaveis em manifests, lockfiles, CI, estrutura e arquivos representativos.
3. Registre para cada regra candidata sua fonte `arquivo:linha` ou a confirmacao do usuario.
4. Inclua somente comandos existentes, convencoes transversais e restricoes que mudam decisoes do agente.
5. Mova procedimentos raros ou extensos para rules ou referencias lazy; deixe no arquivo principal apenas orientacao aplicavel a quase toda tarefa.
6. Use `assets/project-instructions-template.md` como checklist, omitindo secoes sem conteudo real.

   > **Template registry**: template registrado como `generate-claude-md`. Use `sda-template-resolve generate-claude-md` para resolver com suporte a overrides/presets/extensions.
7. Mostre um diff curto e so grave depois da aprovacao do usuario.

Alvo: menos de 80 linhas de conteudo do projeto, fora do bloco gerenciado. Nao duplique as regras do framework, nao invente stack ou comandos e nao altere extensoes especificas do host; a projecao e responsabilidade do adapter.
