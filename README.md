# Projeto: Controle Orçamentário - De ponta a ponta (ETL, Data Quality e Analytics)

## 📌 Visão Geral
Este é um projeto de **Análise de Dados** focado em controle orçamentário e lançamentos financeiros. O diferencial deste projeto é a implementação de um pipeline de **ETL com alicerces de Engenharia de Dados**, garantindo que as análises finais no Power BI sejam baseadas em dados íntegros, auditáveis e livres de inconsistências.

---

## 🏗️ Arquitetura e Estrutura do Pipeline
O projeto utiliza o conceito de camadas para garantir a separação entre o dado bruto e o dado pronto para análise:

1.  **Staging Layer (`stg_`)**: Camada de aterrissagem dos dados "como estão", permitindo a identificação de ruídos e erros gerados propositalmente para simulação de cenários reais.
2.  **Diagnóstico de Qualidade (Data Quality)**: Etapa de auditoria técnica via SQL onde o dado é validado antes de qualquer transformação física.
3.  **Trusted Layer (Dimensões e Fatos)**: Camada final de dados limpos, tipados e com integridade referencial, servindo como a única "fonte da verdade".

---

## 🛠️ Tecnologias Utilizadas
* **SQL Server**: Motor principal para processamento, limpeza, auditoria e modelagem.
* **Python**: Geração de dados sintéticos com regras de sazonalidade e erros controlados.
* **Power BI**: (Em construção) Camada de visualização e cálculo de KPIs.

---

## 📈 Log de Desenvolvimento (Metodologia)

### [28/12/2025] Ingestão e Estrutura Inicial
* Configuração do ambiente e criação da estrutura de banco de dados SQL Server.
* Carga inicial de 5000+ registros via Bulk Insert na camada de Staging.
* **Decisão técnica:** Uso de **Views** para isolar a lógica de tratamento, facilitando a manutenção e testes.

### [03/01/2026] Analytics Engineering: Camada de Auditoria e Carga das Dimensões
Nesta fase, concluímos o tratamento completo das tabelas de dimensões, elevando o rigor técnico com diagnósticos documentados no código:

* **Auditoria de Data Quality:** Implementação de scripts de diagnóstico para identificar espaços extras, valores nulos/vazios e duplicidade de PKs.
* **Investigação de Causa Raiz:** Identificação de registros duplicados ocultos por campos nulos na `stg_dim_categoria` (ex: caso Aluguel/Condomínio), com a respectiva estratégia de descarte na carga.
* **Tratamento de Tipagem Complexa:** Solução para chaves primárias importadas erroneamente em formato decimal (`float`) via conversão aninhada (`CAST AS FLOAT -> INT`).
* **Padronização Semântica Seletiva:** Desenvolvimento de lógica autoral para formato *Initcap* (Primeira letra maiúscula), com filtros para respeitar siglas e exceções de negócio (ex: RH, TI, Limpeza/Conservação).
* **Validação de Metadados:** Uso de `INFORMATION_SCHEMA` para assegurar a tipagem correta antes da carga física via `INSERT INTO`.
* **Integridade Referencial:** Verificação de Chaves Estrangeiras (FKs) entre Categorias e Centros de Custo para evitar dados "órfãos".

---

## 🚀 Próximos Passos
- [ ] Aplicar a régua de Data Quality nas Tabelas Fato (`fato_lancamentos` e `fato_orcamento`).
- [ ] Implementar validação de integridade referencial profunda (FKs das Fatos).
- [ ] Desenvolver o Dashboard no Power BI com foco em indicadores de desvio orçamentário (Orçado vs. Realizado).

---

Este é um projeto de portfólio para demonstrar habilidades em ETL, BI e Análise de Dados.