
-------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------- CRIAÇÃO DE TABELAS --------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------
GO

CREATE TABLE dim_camp_marketing(
       id_camp INT,
       nome_campanha VARCHAR(200),
       mes_referente INT,
       CONSTRAINT dim_camp_marketing_id_camp_pk PRIMARY KEY(id_camp)
)
GO

CREATE TABLE dim_centro_custo(
       id_cc INT,
       nome_cc VARCHAR(200),
       CONSTRAINT dim_centro_custo_id_cc_pk PRIMARY KEY(id_cc)
)
GO

CREATE TABLE dim_categoria(
       id_categoria INT,
       id_cc INT,
       nome_categoria VARCHAR(200)
       CONSTRAINT dim_categoria_id_categoria_pk PRIMARY KEY(id_categoria)
       CONSTRAINT dim_categoria_id_cc_fk FOREIGN KEY (id_cc) REFERENCES dim_centro_custo(id_cc)
)      
GO

CREATE TABLE dim_fornecedores(
       id_forn INT,
       nome_forn VARCHAR(200),
       CONSTRAINT dim_fornecedores_id_forn_pk PRIMARY KEY(id_forn)
)
GO

-------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------- VERIFICAÇÃO DE TRATAMENTOS NECESSÁRIOS --------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------

-- DIM_CAMPANHA ---------------------------------------------------

SELECT * FROM stg_dim_campanha -- OVERVIEW

-- VERIFICAÇÃO DE ESPAÇO EXTRAS
SELECT
       (SELECT
              COUNT(*) 
       FROM
              stg_dim_campanha
       WHERE 
              LEN(id_camp) > LEN(TRIM(id_camp))
       ) AS 'espaços_ID',
       (SELECT
              COUNT(*)
       FROM 
              stg_dim_campanha
       WHERE
              LEN(nome_camp) > LEN(TRIM(nome_camp))
       ) AS 'espaços_Nome',
       (SELECT
              COUNT(*)
       FROM 
              stg_dim_campanha
       WHERE
              LEN(mes_ref) > LEN(TRIM(mes_ref))
       ) AS 'espaços_Mes_ref'

-- VERIFICAÇÃO DE NULOS OU VAZIOS

SELECT
       (SELECT
              COUNT(*) 
       FROM
              stg_dim_campanha
       WHERE 
              id_camp IS NULL OR LEN(id_camp) = 0
       ) AS 'ID_nulo',
       (SELECT
              COUNT(*) 
       FROM
              stg_dim_campanha
       WHERE 
              nome_camp IS NULL OR LEN(nome_camp) = 0
       ) AS 'nome_nulo',
       (SELECT
              COUNT(*) 
       FROM
              stg_dim_campanha
       WHERE 
              mes_ref IS NULL OR LEN(mes_ref) = 0
       ) AS 'mes_ref_nulo'

-- VERIFICAÇÃO DE DUPLICIDADE DE CHAVE PRIMARIA

SELECT
       id_camp,
       COUNT(id_camp) AS 'contagem'
FROM
       stg_dim_campanha
GROUP BY
       id_camp
HAVING COUNT(id_camp) > 1

-- VERIFICAÇÃO DE MESES INVALIDOS

SELECT
       COUNT(*) AS 'meses_invalidos'
FROM
       stg_dim_campanha
WHERE mes_ref < 1 OR mes_ref > 12

-- VERIFICACAO DE TIPOS DE DADOS

SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'stg_dim_campanha'

/* RESULTADO DA VERIFICAÇÃO:
- ESPAÇOS EXTRAS: 0 ENCONTRADOS, NENHUM TRATAMENTO NECESSÁRIO
- NULOS OU VAZIOS: 0 ENCONTRADOS, NENHUM TRATAMENTO NECESSÁRIO
- DUPLICIDADE DE CHAVE PRIMARIA: 0 ENCONTRADAS, NENHUM TRATAMENTO NECESSÁRIO
- MESES INVALIDOS: 0 ENCONTRADOS, NENHUM TRATAMENTO NECESSÁRIO
- TIPOS DE DADOS: ID E MES_REF ESTÃO COMO VARCHAR AO INVÉS DE INT. TRATAMENTO A SER REALIZADO: CONVERTER EM INT
*/
-- DIM_CENTRO_CUSTO -----------------------------------------------

SELECT * FROM stg_dim_centro_custo -- OVERVIEW

-- VERIFICAÇÃO DE ESPAÇOS EXTRAS

SELECT
       (SELECT 
              COUNT(*)
       FROM
              stg_dim_centro_custo
       WHERE
              LEN(id_cc) > LEN(TRIM(id_cc))
       ) AS 'espaços_ID',
       (SELECT
              COUNT(*)
       FROM
              stg_dim_centro_custo
       WHERE
              LEN(nome_cc) > LEN(TRIM(nome_cc))
       ) AS 'espaços_nome'

-- FOI IDENTIFICADO QUE 2 NOMES ESTAVAM COM ESPAÇOS EXTRAS



-- DIM_CATEGORIA --------------------------------------------------



-- DIM_FORNECEDORES-------------------------------------------------

SELECT * FROM stg_dim_fornecedores

-- VERIFICAÇÃO DE ESPAÇO ANTES OU DEPOIS DO ID DO FORNECEDOR

SELECT
       COUNT(*) AS 'Espaços vazios'
FROM stg_dim_fornecedores
WHERE LEN(id_forn) > LEN(TRIM(id_forn))

-- VERIFICAÇÃO DE ESPAÇO ANTES OU DEPOIS DO NOME DO FORNECEDOR

SELECT
       COUNT(*) AS 'Espaços vazios'
FROM stg_dim_fornecedores
WHERE LEN(nome_forn) > LEN(TRIM(nome_forn))

-- VERIFICAÇÃO DE NULOS

SELECT
       COUNT(*) AS 'Espaços vazios'
FROM stg_dim_fornecedores
WHERE id_forn IS NULL OR nome_forn IS NULL
-- 

-------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------TRANSFORMAÇÃO, LIMPEZA E CRIAÇÃO DE VIEWS -----------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------
GO
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
              CAST(TRIM(REPLACE(id_cat, '.0', '')) AS INT) AS 'id_cat',
              CAST(TRIM(REPLACE(id_cc, '.0', '')) AS INT)  AS 'id_cc',
              UPPER(LEFT(TRIM(nome_cat),1))
            + LOWER(RIGHT(TRIM(nome_cat),LEN(TRIM(nome_cat))-1)) AS 'nome_cat'
       FROM stg_dim_categoria
       WHERE id_cat IS NOT NULL
GO

-- dim_fornecedores


CREATE OR ALTER VIEW vw_fornecedores AS
       SELECT
              CAST(id_forn AS INT) AS 'id_forn',
              nome_forn
       FROM
              stg_dim_fornecedores
GO

-------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------- VERIFICAÇÃO DE QUALIDADE DAS VIEWS -----------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------

SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'vw_campanhas'

SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'vw_centro_custo'

SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'vw_categoria'

SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'vw_fornecedores'

-------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------- CARGA DE DADOS --------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO dim_camp_marketing
SELECT * FROM vw_campanhas

INSERT INTO dim_centro_custo
SELECT * FROM vw_centro_custo

INSERT INTO dim_categoria
SELECT * FROM vw_categoria

INSERT INTO dim_fornecedores
SELECT * FROM vw_fornecedores
-------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------- AUDITORIA FINAL -------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------
SELECT 'dim_camp_marketing' AS Tabela, COUNT(*) AS Total_Registros FROM dim_camp_marketing
UNION ALL
SELECT 'dim_centro_custo' AS Tabela, COUNT(*) AS Total_Registros FROM dim_centro_custo
UNION ALL
SELECT 'dim_categoria' AS Tabela, COUNT(*) AS Total_Registros FROM dim_categoria
UNION ALL
SELECT 'dim_fornecedores' AS Tabela, COUNT(*) AS Total_Registros FROM dim_fornecedores











