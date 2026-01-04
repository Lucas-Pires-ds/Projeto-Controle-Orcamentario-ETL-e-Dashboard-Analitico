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