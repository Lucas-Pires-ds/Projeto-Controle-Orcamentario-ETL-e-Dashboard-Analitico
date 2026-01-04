# Projeto: Controle Orçamentário - De ponta a ponta (ETL, Data Quality e Analytics)

## 📌 Visão Geral
Este projeto é focado em análise de dados financeiros, mas com um diferencial: em vez de apenas conectar o Power BI em dados crus, eu construí um pipeline de **ETL com alicerces de Engenharia de Dados**. O objetivo é garantir que qualquer análise no Dashboard seja baseada em dados que já passaram por uma régua rigorosa de qualidade e auditoria.

---

## 🏗️ Arquitetura do Pipeline (Medalhão)
Desenhei o projeto utilizando o conceito de camadas para separar as responsabilidades e garantir que o processo seja rastreável:

1.  **Camada Bronze (Raw/Staging)**: Onde os dados aterrissam "como estão". Configurei esta camada com colunas em formato VARCHAR para garantir que a importação aterrissasse sem erros de conversão, permitindo que qualquer "sujeira" fosse tratada via código depois.
2.  **Diagnóstico de Qualidade (Data Quality)**: Antes de mover o dado para a próxima camada, rodo scripts de auditoria via SQL para validar se o dado está saudável.
3.  **Camada Silver (Trusted/Dimensional)**: É a camada onde o dado já está limpo, tipado e com todas as chaves batendo. É a "fonte da verdade" do projeto, estruturada em modelos dimensionais.
4.  **Camada Gold (Analytics)**: (Em desenvolvimento) Tabelas agregadas e visões prontas para consumo direto no Power BI.

---

## 🛠️ Tecnologias Utilizadas
* **SQL Server**: Motor principal para processamento, limpeza, auditoria e modelagem.
* **Python**: Geração de dados sintéticos com regras de sazonalidade e erros propositais.
* **Power BI**: (Em construção) Camada de visualização e análise de indicadores.

---

## 📈 Log de Desenvolvimento (Metodologia)

### [28/12/2025] Ingestão e Arquitetura de Camadas
* **Estruturação Bronze:** Carga de 5000+ registros via Bulk Insert. Configurei a camada Bronze 100% em `VARCHAR` para garantir a ingestão de dados sujos sem quebras de processo, movendo a complexidade de tratamento para dentro do SQL.
* **Simulação Realística:** Os dados foram gerados via Python com erros propositais (espaços, nulos e chaves órfãs) para validar a resiliência do pipeline.

### [03/01/2026] Analytics Engineering: Onde o valor foi gerado
Nesta fase, saí da análise visual e implementei um framework de **Data Quality** via código. Os principais desafios e soluções foram:

* **Framework de Auditoria:** Implementei diagnósticos automáticos comparando comprimentos de strings (`LEN` vs `TRIM`) e verificando nulos/vazios massivamente. Isso permitiu quantificar a "sujeira" antes da limpeza.
* **Resolução de Tipagem Complexa:** Tratei o erro clássico de IDs importados como decimais (ex: `101.0`) através de **conversão aninhada** (`CAST as FLOAT -> INT`), garantindo a integridade das Chaves Primárias na camada Silver.
* **Initcap com Exceções de Negócio:** Desenvolvi uma lógica de padronização de nomes via código (`LEFT`, `RIGHT`, `LEN-1`). Diferente de um tratamento comum, esta lógica preserva siglas críticas (RH, TI) e termos compostos, mantendo a semântica do negócio.
* **Hierarquia e Integridade:** Planejei a carga seguindo a dependência de Chaves Estrangeiras (FKs). Validei via `NOT IN` se todas as Categorias possuíam Centros de Custo correspondentes antes de persistir os dados, evitando erros de relacionamento no modelo final.



---

## 🚀 Status e Próximos Passos
- [x] Arquitetura de camadas definida (Bronze/Silver/Gold).
- [x] ETL e Data Quality das dimensões concluídos.
- [ ] Aplicar o mesmo rigor técnico nas tabelas Fato (Lançamentos e Orçamento).
- [ ] Construir a camada Gold para suporte aos indicadores do Power BI.

---

Este é um projeto de portfólio para demonstrar habilidades em ETL, BI e Análise de Dados.

