-------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------TRANSFORMAÇÃO, LIMPEZA E CRIAÇÃO DE VIEWS -----------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------

-- dim_camp_marketing

CREATE OR ALTER VIEW vw_campanhas AS 
       SELECT
              CAST(id_camp AS INT) AS 'ID_camp',
              nome_camp,
              CAST(mes_ref AS INT) AS 'mes_ref' 
       FROM stg_dim_campanha

GO


-- dim_centro_custo

CREATE OR ALTER VIEW vw_centro_custo AS
       SELECT
              CAST(id_cc AS INT) AS 'id_cc',
              UPPER(LEFT(TRIM(nome_cc),1))+LOWER(RIGHT(TRIM(nome_cc),LEN(TRIM(nome_cc))-1)) AS 'nome_cc'
       FROM stg_dim_centro_custo

GO


-- dim_categoria

CREATE OR ALTER VIEW vw_categoria AS 
       SELECT
              CAST(CAST(id_cat AS FLOAT) AS INT) AS 'id_cat',
              CAST(CAST(id_cc AS FLOAT) AS INT)  AS 'id_cc',
              nome_cat AS 'nome_cat'
       FROM stg_dim_categoria
       WHERE id_cat IS NOT NULL AND id_cc IS NOT NULL
GO


-- dim_fornecedores

CREATE OR ALTER VIEW vw_fornecedores AS
       SELECT
              CAST(id_forn AS INT) AS 'id_forn',
              nome_forn
       FROM
              stg_dim_fornecedores
GO



GO
-- fact_lancamentos

CREATE OR ALTER VIEW vw_lancamentos AS 
SELECT  
       CAST(id_lancamento AS INT) AS 'id_lancamento',
       CAST(CAST(data_lancamento AS DATE) AS DATETIME) AS 'data_lancamento',
       CAST(CASE WHEN
               id_centro_custo NOT IN (SELECT id_cc FROM dim_centro_custo)
                THEN -1 ELSE id_centro_custo END AS INT) AS 'id_cc',
       CAST(id_categoria AS INT) AS 'id_categoria',
       CAST(id_fornecedor AS INT) AS 'id_fornecedor',
       CAST(CAST(id_campanha_marketing AS FLOAT) AS INT) AS 'id_campanha',
       ABS(CAST(valor_lancamento AS DECIMAL(16,2))) AS 'valor_absoluto',
       CAST(valor_lancamento AS DECIMAL(16,2)) AS 'valor_original',
       CASE 
              WHEN status_pagamento IN ('PAGO', 'Paga', 'Pago') THEN 'Pago'
              WHEN status_pagamento IN ('Pending', 'Aberto') THEN 'Aberto'
              ELSE 'Outros'
       END AS 'status_pagamento'
FROM
       stg_lancamentos
WHERE data_lancamento IS NOT NULL

GO

-- fact_orcamento

CREATE OR ALTER VIEW vw_orcamento AS

SELECT
       CAST(id_orcamento AS INT) AS 'id_orcamento',
       CAST(EOMONTH(DATEFROMPARTS(CAST(ANO AS INT), CAST(mes AS INT), 1)) AS DATETIME) AS 'data',
       CAST(ano AS INT) AS 'ano',
       CAST(mes AS INT) AS 'mes',
       CAST(id_centro_custo AS INT) AS 'id_centro_custo',
       CAST(id_categoria AS INT) AS 'id_categoria',
       CAST(valor_orcado AS DECIMAL(18,2)) AS 'valor_orcado',
       CASE
              WHEN CAST(valor_orcado AS DECIMAL(18,2)) / AVG(CAST(valor_orcado AS DECIMAL(18,2))) 
              OVER (PARTITION BY id_centro_custo, id_categoria) - 1 > 9 THEN 'Dado suspeito' ELSE 'Dado confiavel'
       END AS 'status_dado'
FROM 
    stg_orcamento

GO


-- CAMADA GOLD


GO


-- GOLD_ORCAMENTO


CREATE OR ALTER VIEW vw_gold_orcamento AS 

WITH BASE AS (
              SELECT 
                     FO.ano AS 'Ano',
                     FO.mes AS 'Mes',
                     CC.id_cc AS 'ID_Centro_de_custo',
                     CC.nome_cc AS 'Centro_de_custo',
                     FO.id_categoria,
                     CAT.nome_categoria AS 'Categoria',
                     SUM(FO.valor) AS 'Orcado',
                     FO.status_dado AS 'Status_dado'
              FROM
              fact_orcamento FO
              LEFT JOIN
                     dim_centro_custo CC  
                            ON CC.id_cc = FO.id_centro_custo
              LEFT JOIN
                     dim_categoria CAT  
                            ON CAT.id_categoria = FO.id_categoria
              GROUP BY 
                     FO.ano, FO.mes, CC.id_cc, CC.nome_cc, FO.id_categoria, CAT.nome_categoria, FO.status_dado
              )
SELECT 
       Ano,
       Mes,
       ID_centro_de_custo,
       Centro_de_custo,
       ID_categoria,
       Categoria,
       NULLIF(Orcado, 0) AS 'Orcado_mensal',
       SUM(Orcado) OVER (
                            PARTITION BY Ano, ID_centro_de_custo, ID_categoria, status_dado 
                            ORDER BY Mes
                            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
       ) AS 'Orcado_YTD',
       NULLIF(SUM(Orcado) OVER (
                            PARTITION BY Ano, ID_centro_de_custo, Mes, status_dado), 0) 
       / NULLIF(SUM(Orcado) OVER(
                            PARTITION BY Ano, Mes, status_dado), 0
       ) AS 'Peso_centro_custo',
       NULLIF(SUM(Orcado) OVER (
                            PARTITION BY Ano, ID_categoria, Mes, status_dado), 0) 
       / NULLIF(SUM(Orcado) OVER(
                            PARTITION BY Ano, Mes, status_dado), 0
       ) AS 'Peso_categoria',
       AVG(NULLIF(Orcado, 0)) OVER (
                            PARTITION BY Ano, ID_centro_de_custo, ID_categoria, status_dado
       ) AS 'Media_mensal',
       CASE 
              WHEN NULLIF(Orcado, 0) > 2 * AVG(NULLIF(Orcado, 0)) OVER (PARTITION BY Ano, ID_centro_de_custo, ID_categoria, status_dado) 
              OR NULLIF(Orcado, 0) < 0.5 * AVG(NULLIF(Orcado, 0)) OVER (PARTITION BY Ano, ID_centro_de_custo, ID_categoria, status_dado)
              THEN 'Valor_atipico' ELSE 'Valor_normal' 
       END AS 'Flag_valor_atipico_orcamento',
       Status_dado
FROM 
       BASE



GO
























-------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------- VERIFICAÇÃO DA TIPAGEM DE DADOS DAS VIEWS ----------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------

SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'vw_campanhas'
UNION ALL
SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'vw_centro_custo'
UNION ALL
SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'vw_categoria'
UNION ALL
SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'vw_fornecedores'
UNION ALL
SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'vw_lancamentos'
UNION ALL
SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'vw_orcamento'
