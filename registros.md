# Diário de Desenvolvimento - Projeto BI Financeiro

## [28/12/2025] Início do Projeto e Ingestão de Dados
### O que foi feito:
- Definição do escopo: Controle Orçamentário e Lançamentos.
- Geração de dados sintéticos (5000+ linhas) usando Python para simular cenários reais com sazonalidade e erros.
- Configuração do ambiente SQL Server no VS Code.
- Criação do banco de dados `Financeiro_BI`.
- Implementação da Camada de Staging (`stg_`) para garantir a integridade da importação.
- Tratamento e criação de tabelas trusted dim_camp_marketing, dim_centro_custo e dim_categoria

### Decisões técnicas:
**- Realismo de Dados:**
Fiz um script python para gerar uma base de dados o mais próximo da realidade possível, para isso apliquei:
- Regras de sazonalidade como: campanhas de marketing condizentes com o calendário real, gastos com folha aumentados em epoca de 13° salario, centros de custos que gastam mais em determinada epoca do ano, etc.
- Erros propositais nos dados como espaços extras desnecessários, dados faltantes, chaves estrangeiras que não batem com chaves primárias, etc.

**- Arquiterura:**
Optei pelo padrão de camadas (Staging e Trusted) para garantir que o processo de ETL seja rastreável e que erros de importação não interrompam o fluxo de carga.
Utilizei views para tratar o dado sujo e testar se o tratamento estava funcionando antes de dar insert nas tabelas trusted, garantindo assim que as tabelas trusted estejam 100% limpas

**- Limpeza de dados:**
- Para o ETL dos dados, decidi trabalhar com a seguinte metodologia:
- Selecionei top (100) das tabelas para verificar visualmente como estavam os dados
- Fiz tratamentos como: 
    - Tratamento de Duplicidade Crítica, onde Identifiquei que o registro 'ALUGUEL/CONDOMÍNIO' aparecia duplicado, como solução apliquei um filtro WHERE id_cat IS NOT NULL para filtrar apenas linhas em que o id da categoria não é nulo.
    - Retirada de espaços extras dos valores.
    - Conversão numeros que estavam como varchar em INT (chaves primarias e estrangeiras)
    - Padronização  Initcap das palavras (sempre a primeira letra maiúscula e as demais minúsculas)
- Ao atingir o resultado desejado, transferi os dados para views vw_campanhas vw_centro_custo e vw_categoria
- Criei as tabelas trusted dim_camp_marketing, dim_centro_custo e dim_categoria e com os tipos de dados corretos e constraints como primary key, foreign key, not null, etc.
- Inseri os dados das views diretamente nas tabelas trusted
- Durante a insercão dos dados, identifiquei a necessidade de respeitar a hierarquia das chaves estrangeiras entre as tabelas dim_centro de custo e dim_categoria, então povoei a tabela dim_centro_custo antes da dim_categoria, para evitar erros de referencia entre as chaves.

**- Desenvolvimento Assistido:** Utilizei algumas IAs (Chat GPT, Gemini e Claude) de forma consultiva para validação de lógica SQL e refinamento da arquitetura de dados.

**- Resolução de problemas:**
- Encontrei erros de 'Objeto não encontrado' durante a ingestão. Solucionei implementando scripts de criação condicional (IF NOT EXISTS) para garantir que a estrutura de Staging esteja pronta antes do BULK INSERT.
- Desafio: Autocompletar (IntelliSense) não reconhecendo novas tabelas de Staging no VS Code. Solução: Utilizado o comando Refresh IntelliSense Cache e adotada a boa prática de referenciar tabelas utilizando o esquema (dbo.tabela) para garantir maior clareza e evitar problemas de permissão.


### Próximos passos

- Criar as tabelas dim_fornecedores, fato_lancamentos e fato_orcamento
- Criar views auxiliares para a criação das visualizações no Power BI
- Exportar os dados para o Power BI
- Criar dashboard no Power BI
- Validar se o projeto atingiu todas as expectativas
- Concluir projeto

Aqui está o texto formatado seguindo rigorosamente a sintaxe Markdown para que os títulos, subtítulos e negritos fiquem com a hierarquia correta no seu registro.

## [03/01/2026] Refatoração e Implementação de Camada de Data Quality
### O que foi feito:
Refatoração da estrutura do script SQL para um modelo de pipeline mais organizado e profissional.

Implementação de uma camada de Diagnóstico de Qualidade (Data Quality) antes da fase de transformação.

Criação e carga da tabela trusted dim_fornecedores.

Validação completa de integridade da tabela dim_camp_marketing utilizando novos métodos de auditoria.

### Decisões técnicas:
- Metodologia de Data Quality: Decidi ser mais rigoroso na verificação dos dados da Staging antes de criar as Views. Para isso, criei scripts de diagnóstico para validar:

Espaços Extras: Usei a lógica LEN(col) > LEN(TRIM(col)) para identificar de forma automática registros com sujeira de espaçamento, em vez de apenas olhar o TOP 100.

Campos Nulos ou Vazios: Implementei a checagem IS NULL OR LEN(col) = 0 para garantir que campos que parecem vazios (mas não são nulos) também sejam capturados.

Unicidade (PK): Utilizei GROUP BY com HAVING COUNT > 1 para garantir que não existam IDs duplicados que possam quebrar as constraints de Primary Key da camada Trusted.

Validação de Domínio: No campo mes_ref, criei um filtro para garantir que os valores estejam apenas entre 1 e 12, evitando erros de lógica de negócio.

- Refatoração da Arquitetura do Script: Para tornar o projeto mais escalável e fácil de manter, organizei o script único em blocos lógicos claros:

DDL: Criação das tabelas físicas (Trusted).

Diagnóstico: Scripts de validação da saúde do dado na Staging.

Transformação: Views com a "inteligência" de limpeza e padronização.

Carga: Processo de INSERT para a camada definitiva.

Auditoria: Relatório final usando UNION ALL para conferir o total de registros carregados em cada tabela.

- Evolução do Perfil: O projeto, que era focado em análise, passou a ter uma base forte de Analytics Engineering, garantindo que o dado no Dashboard seja 100% confiável e auditável.

### Resolução de problemas:
Desafio da Versatilidade vs. Padronização: Avaliei o uso de técnicas diferentes para mostrar conhecimento (Subqueries vs. Sum Case), mas decidi padronizar as validações iniciais em Subqueries. Essa escolha foi feita para manter a autoria total da lógica e garantir que eu consiga defender cada linha de código em uma revisão técnica.

Saneamento de Strings em Campos Numéricos: Identifiquei que campos numéricos na Staging às vezes impediam o uso da função LEN. Solucionei aplicando CAST(col AS VARCHAR) dentro da validação para permitir a contagem de caracteres sem erro de tipo.

### Próximos passos:
Aplicar essa mesma régua de qualidade (Data Quality) para as demais dimensões.

Iniciar o desafio das tabelas fato (fato_lancamentos e fato_orcamento), onde a validação incluirá integridade referencial (chaves estrangeiras).
