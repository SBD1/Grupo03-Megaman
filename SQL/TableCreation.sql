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


CREATE TABLE venda (

	id_loja INTEGER CONSTRAINT id_loja_fk REFERENCES loja (codigo),
	id_item INTEGER CONSTRAINT id_item_fk REFERENCES item (id),

	CONSTRAINT venda_pk PRIMARY KEY (id_loja, id_item)
	
);

CREATE TABLE altera (

	chave INTEGER CONSTRAINT chave_fk REFERENCES chave (id),
	posX INTEGER CONSTRAINT posX_fk REFERENCES quadrado (pos_x),
	posY INTEGER CONSTRAINT posY_fk REFERENCES quadrado (pox_y),
	area INTEGER CONSTRAINT area_fk REFERENCES area (mapa, nome),
	mapa INTEGER CONSTRAINT mapa_fk REFERENCES mapa (nome),


	CONSTRAINT altera_pk PRIMARY KEY (chave, posX, posY, area, mapa)
	
);

CREATE TABLE destranca (

	chave INTEGER CONSTRAINT chave_fk REFERENCES chave (id),
	posX INTEGER CONSTRAINT posX_fk REFERENCES quadrado (pos_x),
	posY INTEGER CONSTRAINT posY_fk REFERENCES quadrado (pox_y),
	area INTEGER CONSTRAINT area_fk REFERENCES area (mapa, nome),
	mapa INTEGER CONSTRAINT mapa_fk REFERENCES mapa (nome),


	CONSTRAINT destranca_pk PRIMARY KEY (chave, posX, posY, area, mapa)
	
);

CREATE TABLE usa (

	id_chave INTEGER CONSTRAINT id_loja_fk REFERENCES chave (codigo),
	id_player INTEGER CONSTRAINT id_item_fk REFERENCES player (id),

	CONSTRAINT venda_pk PRIMARY KEY (id_loja, id_item)
	
	--Serve para consultar se um player pode alterar o estado
	-- da porta e salvar no histórico destranca
);

CREATE TABLE chave (
	id SERIAL,
	nome VARCHAR(50) NOT NULL,
	descricao VARCHAR(200),
	valor_compra SMALLINT,
	valor_venda SMALLINT,
	
	CHECK ( (valor_compra > 0) AND (valor_venda > 0))
);

CREATE TABLE npc (
	nome VARCHAR(100),
	inventario INTEGER,
	hp PRIM_STAT,
	energia PRIM_STAT,
	ataque SEC_STAT,
	defesa SEC_STAT,
	evasao SEC_STAT,
	agilidade SEC_STAT,
--	arma
--	armadura
	
	CONSTRAINT npc_pk PRIMARY KEY (nome)
);

CREATE TABLE slot (
	id_inventario INT,
	pos SMALLINT,
	item BIGINT,
	
	CONSTRAINT slot_pk PRIMARY KEY (id_inventario, pos),
	CONSTRAINT slot_inventario_fk FOREIGN KEY (id_inventario) 
		REFERENCES inventario (id),
	CONSTRAINT slot_item_fk FOREIGN KEY (item)
		REFERENCES item (id)
);

CREATE TABLE fala (
	codigo INTEGER,
	texto VARCHAR(200),
	
	CONSTRAINT fala_pk PRIMARY KEY (codigo)
);

CREATE TABLE area (
	mapa VARCHAR(100),
	nome VARCHAR(50),
	largura SMALLINT,
	altura SMALLINT,
	
	CONSTRAINT area_pk PRIMARY KEY (mapa, nome),
	CONSTRAINT area_mapa_fk FOREIGN KEY (mapa)
		REFERENCES mapa (nome)
);

CREATE TABLE quadrado (
	pos_x SMALLINT,
	pos_y SMALLINT,
	area VARCHAR(50),
	mapa VARCHAR(100),
	tipo CHAR(1),
	chance_batalha SMALLINT CHECK(VALUE >= 0 AND VALUE <= 100),
	
	CONSTRAINT quadrado_pk PRIMARY KEY (pos_x, pos_y, area, mapa),
	CONSTRAINT quadrado_area FOREIGN KEY (area, mapa)
		REFERENCES area (nome, mapa)
);

CREATE TABLE bestiario (
	mapa VARCHAR(100),
	npc VARCHAR(100),
	
	CONSTRAINT bestiario_pk PRIMARY KEY (mapa, npc),
	CONSTRAINT bestiario_mapa_fk FOREIGN KEY (mapa)
		REFERENCES mapa (nome),
	CONSTRAINT bestiario_npc_fk FOREIGN KEY (npc)
		REFERENCES npc (nome)
);

CREATE TABLE elemento (
	nome VARCHAR(20) PRIMARY KEY
);

CREATE TABLE resistencia (
	nivel VARCHAR(6) PRIMARY KEY,
	porcentagem SMALLINT NOT NULL CHECK(VALUE >= 0 AND VALUE < 101)
);

CREATE TABLE resiste (
	elemento_a VARCHAR(20),
	elemento_b VARCHAR(20),
	intensidade VARCHAR(6) DEFAULT ('normal'),
	
	CONSTRAINT resiste_pk PRIMARY KEY (elemento_a, elemento_b),
	CONSTRAINT resiste_elemento_a_fk FOREIGN KEY (elemento_a)
		REFERENCES elemento (nome),
	CONSTRAINT resiste_elemento_b_fk FOREIGN KEY (elemento_b)
		REFERENCES elemento (nome),
	CONSTRAINT resiste_intensidade_fk FOREIGN KEY (intensidade)
		REFERENCES resistencia (nivel)
);

CREATE TABLE equip (
	id BIGINT PRIMARY KEY,
	tipo VARCHAR(10) NOT NULL CHECK (VALUE IN ('arma', 'armadura'))
);

CREATE TABLE equip_elem (
	equipamento BIGINT,
	elemento VARCHAR(20),
	
	CONSTRAINT equip_elem_pk PRIMARY KEY (equipamento, elemento),
	CONSTRAINT equip_elem_equipamento_fk FOREIGN KEY (equipamento)
		REFERENCES equip (id),
	CONSTRAINT equip_elem_elemento_fk FOREIGN KEY (elemento)
		REFERENCES elemento (nome)
);

CREATE TABLE equip_skill (
	equipamento BIGINT,
	habilidade INTEGER,
	
	CONSTRAINT equip_skill_pk PRIMARY KEY (equipamento),
	CONSTRAINT equip_skill_equipamento_fk FOREIGN KEY (equipamento)
		REFERENCES equip (id),
	CONSTRAINT equip_skill_habilidade_fk FOREIGN KEY (habilidade)
		REFERENCES habilidade (codigo)
);

CREATE TABLE evento (
	codigo BIGSERIAL PRIMARY KEY,
	condicao VARCHAR(500),
	tipo CHAR(1) NOT NULL CHECK (VALUE IN ('d', 'b')),
	ev_anterior BIGINT,
	acionamento_direto BOOLEAN NOT NULL,
	desbloquado BIGINT DEFAULT false,
	
	CONSTRAINT evento_evento_fk FOREIGN KEY (ev_anterior)
		REFERENCES evento (codigo)
);

CREATE TABLE conecta (
	pos_x1 SMALLINT,
	pos_y1 SMALLINT,
	area1 VARCHAR(50),
	mapa1 VARCHAR(100),
	pos_x2 SMALLINT,
	pos_y2 SMALLINT,
	area2 VARCHAR(50),
	mapa2 VARCHAR(100),
	
	CONSTRAINT conecta_pk PRIMARY KEY (pos_x1, pos_y1, area1, mapa1, pos_x2, pos_y2, area2, mapa2),
	CONSTRAINT quadrado1_fk FOREIGN KEY (pos_x1, pos_y1, area1, mapa1)
		REFERENCES quadrado (pos_x, pos_y, area, mapa),
	CONSTRAINT quadrado2_fk FOREIGN KEY (pos_x2, pos_y2, area2, mapa2)
		REFERENCES quadrado (pos_x, pos_y, area, mapa)
);

CREATE TABLE drop (
	item BIGINT,
	evento BIGINT,
	chance INTEGER,
	
	CONSTRAINT drop_pk PRIMARY KEY (item, evento),
	CONSTRAINT drop_evento_fk FOREIGN KEY (evento) 
	CONSTRAINT drop_item_fk FOREIGN KEY (item)
		REFERENCES item (id)
	CONSTRAINT drop_evento_fk FOREIGN KEY (evento)
		REFERENCES evento (codigo)
);

CREATE TABLE melhoria (
	loja SERIAL,
	equipamento BIGINT,
	
	CONSTRAINT melhoria_pk PRIMARY KEY (loja, equipamento),
	CONSTRAINT melhoria_loja_fk FOREIGN KEY (loja) 
	CONSTRAINT melhoria_equipamento_fk FOREIGN KEY (equipamento) 
	CONSTRAINT melhoria_loja_fk FOREIGN KEY (loja)
		REFERENCES loja (codigo)
	CONSTRAINT melhoria_equipamento_fk FOREIGN KEY (evento)
		REFERENCES equipamento (equipamento)
);


