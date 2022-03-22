CREATE DOMAIN ITEMTYPE 
	AS VARCHAR(10) NOT NULL
	CHECK (VALUE IN ('equip', 'consum', 'chave'));

CREATE DOMAIN CHARTYPE
	AS VARCHAR(7) NOT NULL
	CHECK (VALUE IN ('npc', 'player'));

-- Para HP e Energia
CREATE DOMAIN PRIM_STAT
	AS SMALLINT NOT NULL
	CHECK (VALUE >= 0 AND VALUE < 1000)

-- Para ataque, defesa, evasão, etc
CREATE DOMAIN SEC_STAT
	AS SMALLINT NOT NULL 
	CHECK (VALUE >= 0 AND VALUE < 301)
	
CREATE TABLE loja (
	codigo SERIAL,
	nome VARCHAR(50) NOT NULL,
	
	CONSTRAINT loja_pk PRIMARY KEY (codigo)
);

CREATE TABLE item (
	id BIGSERIAL,
	tipo ITEMTYPE,
	
	CONSTRAINT item_pk PRIMARY KEY (id)
);

CREATE TABLE inventario (
	id SERIAL,
	tamanho SMALLINT CHECK (VALUE > 0 AND VALUE <= 9999),
	
	CONSTRAINT inventario_pk PRIMARY KEY (id),
);

CREATE TABLE personagem (
	nome VARCHAR(100),
	tipo CHARTYPE,
	
	CONSTRAINT personagem_pk PRIMARY KEY (codigo)
);

CREATE TABLE player (
	nome VARCHAR(100),
	inventario INTEGER,
	hp PRIM_STAT,
	energia PRIM_STAT,
	ataque SEC_STAT,
	defesa SEC_STAT,
	evasao SEC_STAT,
	agilidade SEC_STAT,
	creditos INTEGER,
--	arma
--	armadura
	
	CONSTRAINT player_pk PRIMARY KEY (nome),
	CONSTRAINT player_credits_ck CHECK(VALUE >= 0, VALUE <= 99999999)
);

CREATE TABLE mapa (
	nome VARCHAR(100),
	descricao VARCHAR(500),
	
	CONSTRAINT mapa_pk PRIMARY KEY (nome)
);

CREATE TABLE habilidade (
	codigo SERIAL,
	descricao VARCHAR(400),
	
	CONSTRAINT habilidade_pk PRIMARY KEY (codigo)
);

CREATE TABLE armadura (
	id SERIAL CONSTRAINT armadura_pk PRIMARY KEY,
	nome VARCHAR(50) NOT NULL,
	tipo VARCHAR(50) NOT NULL,
	descricao VARCHAR(200),
	valor_compra SMALLINT,
	valor_venda SMALLINT,
	valor_upgrade SMALLINT,
	nivel SMALLINT,
	energia SMALLINT,
	ataque SMALLINT,
	defesa SMALLINT,
	
	CHECK  ((valor_compra > 0 ) AND (valor_venda > 0) AND (valor_upgrade > 0) AND (nivel > 0))
		
);

CREATE TABLE arma (
	id SERIAL CONSTRAINT armadura_pk PRIMARY KEY,
	nome VARCHAR(50) NOT NULL,
	tipo VARCHAR(50) NOT NULL,
	descricao VARCHAR(200),
	valor_compra SMALLINT,
	valor_venda SMALLINT,
	valor_upgrade SMALLINT,
	nivel SMALLINT,
	energia SMALLINT,
	ataque SMALLINT,
	agilidade SMALLINT,
	
	CHECK  ((valor_compra > 0 ) AND (valor_venda > 0) AND (valor_upgrade > 0) AND (nivel > 0))
		
);

CREATE TABLE consumivel (
	id SERIAL CONSTRAINT armadura_pk PRIMARY KEY,
	nome VARCHAR(50) NOT NULL,
	descricao VARCHAR(200),
	valor_compra SMALLINT,
	valor_venda SMALLINT,
	modificador_dano SMALLINT,
	modificador_energia SMALLINT,
	
	CHECK  ((valor_compra > 0 ) AND (valor_venda > 0))
		
);

