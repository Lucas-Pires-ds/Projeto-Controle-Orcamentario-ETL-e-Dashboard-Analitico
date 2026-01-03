# Projeto: Controle Orçamentário - De ponta a ponta (ETL, Data Quality e Analytics)

## 📌 Visão Geral
Este é um projeto de **Análise de Dados** focado em controle orçamentário e lançamentos financeiros. O diferencial deste projeto é a implementação de um pipeline de **ETL com alicerces de Engenharia de Dados**, garantindo que as análises finais no Power BI sejam baseadas em dados íntegros, auditáveis e livres de inconsistências.

---

## 🏗️ Arquitetura e Estrutura do Pipeline
O projeto foi desenhado utilizando o conceito de camadas, garantindo a separação entre o dado bruto e o dado pronto para análise:

1.  **Staging Layer (`stg_`)**: Camada de aterrissagem dos dados. Aqui, os dados são importados "como estão", permitindo a identificação de ruídos, duplicidades e erros de preenchimento gerados propositalmente por um script Python de simulação.
2.  **Diagnóstico de Qualidade (Data Quality)**: Uma etapa intermediária (alicerce de engenharia) onde o dado é auditado via SQL antes de qualquer transformação.
3.  **Trusted Layer (Dimensões e Fatos)**: Camada final de dados limpos, tipados e padronizados, servindo como a única "fonte da verdade" para o Dashboard.

---

## 🛠️ Tecnologias Utilizadas
* **SQL Server**: Motor principal para processamento, limpeza e modelagem.
* **Python**: Geração de dados sintéticos com regras de sazonalidade e erros controlados.
* **Power BI**: (Em construção) Camada de visualização e cálculo de KPIs.

---

## 📈 Log de Desenvolvimento (Metodologia)

### [28/12/2025] Ingestão e Estrutura Inicial
* Configuração do ambiente e criação da estrutura de banco de dados.
* Carga de 5000+ registros via Bulk Insert na camada de Staging.
* **Decisão técnica:** Uso de **Views** para isolar a lógica de tratamento, permitindo testar a limpeza antes da carga física.

### [03/01/2026] Refatoração: Implementando a Camada de Data Quality
Neste estágio, o projeto foi elevado para um nível de **Analytics Engineering**. Em vez de apenas limpar os dados, criei um pipeline de validação:
* **Detecção de "Sujeira" de String:** Implementação da lógica `LEN(col) > LEN(TRIM(col))` para monitorar automaticamente espaços extras.
* **Tratamento de Dados Vazios:** Validação composta `IS NULL OR LEN(col) = 0` para capturar ausência de dados que o banco não reconhece como nulo.
* **Auditoria de Unicidade:** Uso de `GROUP BY` e `HAVING` para garantir a integridade das Chaves Primárias (PKs) antes da carga na Trusted.
* **Padronização Semântica:** Uso de funções de string para garantir o formato *Initcap* (Primeira letra maiúscula) em todas as dimensões.

---

## 🚀 Próximos Passos
- [ ] Aplicar a régua de Data Quality nas Tabelas Fato (`fato_lancamentos` e `fato_orcamento`).
- [ ] Implementar validação de integridade referencial (Chaves Estrangeiras).
- [ ] Desenvolver o Dashboard no Power BI com foco em indicadores de desvio orçamentário e tendência.

---

**Autor:** Lucas Pires  
**Perfil:** Analista de Dados com foco em processos de ETL e Qualidade de Dados.