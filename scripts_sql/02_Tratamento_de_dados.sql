SELECT * FROM stg_dim_campanha

-- criando a tabela 
CREATE TABLE dim_camp_marketing(
       id_camp INT,
       nome_campanha VARCHAR(200),
       mes_referente INT,
       CONSTRAINT dim_camp_marketing_id_camp_pk PRIMARY KEY(id_camp))
GO
-- usando view para tratar os dados enquanto observo se os tratamentos dão certo antes de insertar na tabela trusted
CREATE VIEW vw_campanhas AS (
SELECT
       CAST(id_camp AS INT) AS ID_camp,
       nome_camp,
       CAST(mes_ref AS INT) AS mes_ref 
FROM stg_dim_campanha)

GO
-- verificando o tratamento deu certo

SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'vw_campanhas'

-- inserindo dados na tabela trusted dim_camp_marketing

INSERT INTO dim_camp_marketing
SELECT * FROM vw_campanhas
