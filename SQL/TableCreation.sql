DROP DATABASE megaman;

CREATE DATABASE megaman;

\c megaman

BEGIN;

CREATE DOMAIN ITEMTYPE 
	AS VARCHAR(10) NOT NULL
	CHECK (VALUE IN ('equip', 'consumivel', 'chave'));

CREATE DOMAIN EQUIPTYPE
	AS VARCHAR(10) NOT NULL 
	CHECK (VALUE IN ('arma', 'armadura'));

CREATE DOMAIN CHARTYPE
	AS VARCHAR(7) NOT NULL
	CHECK (VALUE IN ('npc', 'player'));

-- Para HP e Energia
CREATE DOMAIN PRIM_STAT
	AS SMALLINT NOT NULL
	CHECK (VALUE >= 0 AND VALUE < 1000);

-- Para ataque, defesa, evasão, etc
CREATE DOMAIN SEC_STAT
	AS SMALLINT NOT NULL 
	CHECK (VALUE >= 0 AND VALUE < 301);

-- entrada0 e saida0 são entradas/saídas sem nenhuma conexão com outro quadrado
CREATE DOMAIN QUADRADO_TYPE
	AS VARCHAR(10) NOT NULL
	CHECK (VALUE IN ('item', 'barreira', 'efeito', 'evento', 'conexao', 'loja', 'entrada', 'saida', 'entrada0', 'saida0'));

CREATE TABLE item (
	id BIGSERIAL,
	tipo ITEMTYPE,
	
	CONSTRAINT item_pk PRIMARY KEY (id)
);

CREATE TABLE consumivel (
	id BIGINT CONSTRAINT consumivel_pk PRIMARY KEY,
	nome VARCHAR(50) NOT NULL UNIQUE,
	descricao VARCHAR(200),
	valor_compra SMALLINT,
	valor_venda SMALLINT,
	modificador_dano SMALLINT,
	modificador_energia SMALLINT,
	
	CHECK  ((valor_compra > 0 ) AND (valor_venda > 0))
		
);

CREATE TABLE chave (
	id BIGINT,
	nome VARCHAR(50) NOT NULL UNIQUE,
	descricao VARCHAR(200),
	valor_compra SMALLINT,
	valor_venda SMALLINT,
	
	CHECK ((valor_compra > 0) AND (valor_venda > 0)),
	CONSTRAINT chave_pk PRIMARY KEY (id)
);

CREATE TABLE equip (
	id BIGINT,
	tipo EQUIPTYPE,
	
	CONSTRAINT equip_pk PRIMARY KEY (id)
);

CREATE TABLE armadura (
	id BIGINT CONSTRAINT armadura_pk PRIMARY KEY,
	nome VARCHAR(50) NOT NULL UNIQUE,
	descricao VARCHAR(200),
	valor_compra SMALLINT,
	valor_venda SMALLINT,
	valor_upgrade SMALLINT,
	nivel SMALLINT,
	energia SMALLINT,
	ataque SMALLINT,
	defesa SMALLINT,
	evasao SMALLINT,

	CHECK  ((valor_compra > 0 ) AND (valor_venda > 0) AND (valor_upgrade > 0) AND (nivel > 0))
		
);

CREATE TABLE arma ( 
	id BIGINT CONSTRAINT arma_pk PRIMARY KEY,
	nome VARCHAR(50) NOT NULL UNIQUE,
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

CREATE TABLE inventario (
	id SERIAL,
	tamanho SMALLINT CHECK (tamanho > 0 AND tamanho <= 9999),
	
	CONSTRAINT inventario_pk PRIMARY KEY (id)
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

CREATE TABLE personagem (
	nome VARCHAR(100),
	tipo CHARTYPE,
	
	CONSTRAINT personagem_pk PRIMARY KEY (nome)
);

CREATE TABLE player (
-- Player é uma instância dinâmica de personagem
	nome VARCHAR(100),
	inventario INTEGER,
	hp PRIM_STAT DEFAULT (50),
	hp_atual PRIM_STAT DEFAULT (50),
	energia PRIM_STAT DEFAULT (30),
	energia_atual PRIM_STAT DEFAULT (30),
	ataque SEC_STAT DEFAULT (10),
	defesa SEC_STAT DEFAULT (10),
	evasao SEC_STAT DEFAULT (10),
	agilidade SEC_STAT DEFAULT (10),
	creditos INTEGER DEFAULT (100),
	arma BIGINT,
	armadura BIGINT,
	
	CONSTRAINT player_pk PRIMARY KEY (nome),
	CONSTRAINT player_credits_ck CHECK(creditos >= 0 AND creditos <= 99999999),
	CONSTRAINT player_inventario_fk FOREIGN KEY (inventario)
		REFERENCES inventario (id),
	CONSTRAINT player_arma_fk FOREIGN KEY (arma)
		REFERENCES arma (id),
	CONSTRAINT player_armadura_fk FOREIGN KEY (armadura)
		REFERENCES armadura (id)
);

CREATE TABLE npc (
-- NPCs são dados estáticos de personagens
	nome VARCHAR(100),
	hp PRIM_STAT,
	energia PRIM_STAT,
	ataque SEC_STAT,
	defesa SEC_STAT,
	evasao SEC_STAT,
	agilidade SEC_STAT,
	arma BIGINT,
	armadura BIGINT,
	
	CONSTRAINT npc_pk PRIMARY KEY (nome),
	CONSTRAINT npc_arma_fk FOREIGN KEY (arma)
		REFERENCES arma (id),
	CONSTRAINT npc_armadura_fk FOREIGN KEY (armadura)
		REFERENCES armadura (id)
);

CREATE TABLE mapa (
	nome VARCHAR(100),
	descricao VARCHAR(500),
	
	CONSTRAINT mapa_pk PRIMARY KEY (nome)
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
	chance_batalha SMALLINT CHECK(chance_batalha >= 0 AND chance_batalha <= 100),
	
	CONSTRAINT quadrado_pk PRIMARY KEY (pos_x, pos_y, area, mapa),
	CONSTRAINT quadrado_area FOREIGN KEY (area, mapa)
		REFERENCES area (nome, mapa)
);

CREATE TABLE quadrado_tipo (
	pos_x SMALLINT,
	pos_y SMALLINT,
	area VARCHAR(50),
	mapa VARCHAR(100),
	tipo QUADRADO_TYPE,
	
	CONSTRAINT quadrado_tipo_pk PRIMARY KEY (pos_x, pos_y, area, mapa, tipo),
	CONSTRAINT quadrado_tipo_fk FOREIGN KEY (pos_x, pos_y, area, mapa)
		REFERENCES quadrado (pos_x, pos_y, area, mapa)
);

CREATE TABLE quadrado_efeito (
	pos_x SMALLINT,
	pos_y SMALLINT,
	area VARCHAR(50),
	mapa VARCHAR(100),
	hp_mod SMALLINT NOT NULL,
	mp_mod SMALLINT NOT NULL,
	
	CONSTRAINT quadrado_efeito_pk PRIMARY KEY (pos_x, pos_y, area, mapa),
	CONSTRAINT quadrado_efeito_fk FOREIGN KEY (pos_x, pos_y, area, mapa)
		REFERENCES quadrado (pos_x, pos_y, area, mapa)
);

CREATE TABLE quadrado_item (
	pos_x SMALLINT,
	pos_y SMALLINT,
	area VARCHAR(50),
	mapa VARCHAR(100),
	item BIGINT,
	
	CONSTRAINT quadrado_item_pk PRIMARY KEY (pos_x, pos_y, area, mapa),
	CONSTRAINT quadrado_item_fk FOREIGN KEY (pos_x, pos_y, area, mapa)
		REFERENCES quadrado (pos_x, pos_y, area, mapa)
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

CREATE TABLE altera (
	chave INTEGER,
	pos_x SMALLINT,
	pos_y SMALLINT,
	area VARCHAR(50),
	mapa VARCHAR(100),

	CONSTRAINT altera_pk PRIMARY KEY (chave, pos_x, pos_y, area, mapa),
	CONSTRAINT altera_chave_fk FOREIGN KEY (chave)
		REFERENCES chave (id),
	CONSTRAINT altera_quadrado_fk FOREIGN KEY (pos_x, pos_y, area, mapa)
		REFERENCES quadrado (pos_x, pos_y, area, mapa)
);

CREATE TABLE destranca (
	chave BIGINT,
	pos_x SMALLINT,
	pos_y SMALLINT,
	area VARCHAR(50),
	mapa VARCHAR(100),

	CONSTRAINT destranca_pk PRIMARY KEY (pos_x, pos_y, area, mapa),
	CONSTRAINT destranca_chave_fk FOREIGN KEY (chave)
		REFERENCES chave (id),
	CONSTRAINT altera_quadrado_fk FOREIGN KEY (pos_x, pos_y, area, mapa)
		REFERENCES quadrado (pos_x, pos_y, area, mapa)
);

CREATE TABLE usa (

	id_chave INTEGER CONSTRAINT usa_id_chave_fk REFERENCES chave (id),
	id_player VARCHAR(100) CONSTRAINT usa_id_player_fk REFERENCES player (nome),

	CONSTRAINT usa_pk PRIMARY KEY (id_chave, id_player)
	
	--Serve para consultar se um player pode alterar o estado
	-- da porta e salvar no histórico destranca
);

CREATE TABLE chaveiro (

	id_chave INTEGER CONSTRAINT chaveiro_id_chave_fk REFERENCES chave (id),
	id_player VARCHAR(100) CONSTRAINT chaveiro_id_player_fk REFERENCES player (nome),

	CONSTRAINT chaveiro_pk PRIMARY KEY (id_chave, id_player)
	
	--Serve para consultar se um player pode alterar o estado
	-- da porta e salvar no histórico destranca
);

CREATE TABLE habilidade (
	id SERIAL,
	descricao VARCHAR(400),
	
	CONSTRAINT habilidade_pk PRIMARY KEY (id)
);

CREATE TABLE loja (
	id SERIAL,
	nome VARCHAR(50) NOT NULL,
	
	CONSTRAINT loja_pk PRIMARY KEY (id)
);

CREATE TABLE estoque (
-- Nos outros documentos, este é o relacionamento "venda"
	id_loja INTEGER CONSTRAINT id_loja_fk REFERENCES loja (id),
	id_item INTEGER CONSTRAINT id_item_fk REFERENCES item (id),

	CONSTRAINT estoque_pk PRIMARY KEY (id_loja, id_item),
	CONSTRAINT estoque_id_loja_fk FOREIGN KEY (id_loja)
		REFERENCES loja (id),
	CONSTRAINT estoque_id_item_fk FOREIGN KEY (id_item)
		REFERENCES item (id)
);

CREATE TABLE melhoria (
	loja SERIAL,
	equipamento BIGINT,
	
	CONSTRAINT melhoria_pk PRIMARY KEY (loja, equipamento),
	CONSTRAINT melhoria_loja_fk FOREIGN KEY (loja)
		REFERENCES loja (id),
	CONSTRAINT melhoria_equipamento_fk FOREIGN KEY (equipamento)
		REFERENCES equip (id)
);

CREATE TABLE fala (
	id BIGSERIAL,
	texto VARCHAR(200),
	
	CONSTRAINT fala_pk PRIMARY KEY (id)
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
	porcentagem SMALLINT NOT NULL CHECK(porcentagem >= 0 AND porcentagem < 101)
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
	
	CONSTRAINT equip_skill_pk PRIMARY KEY (equipamento, habilidade),
	CONSTRAINT equip_skill_equipamento_fk FOREIGN KEY (equipamento)
		REFERENCES equip (id),
	CONSTRAINT equip_skill_habilidade_fk FOREIGN KEY (habilidade)
		REFERENCES habilidade (id)
);

CREATE TABLE evento (
	id BIGSERIAL PRIMARY KEY,
	condicao VARCHAR(500),
	tipo CHAR(1) NOT NULL CHECK (tipo IN ('d', 'b')),
	acionamento_direto BOOLEAN NOT NULL,
	estado_desbloqueio_inicial BOOLEAN DEFAULT (FALSE)
);

CREATE TABLE dialogo (
	id_evento BIGINT,
	id_fala INTEGER,
	ordem SMALLINT,
	
	CONSTRAINT dialogo_pk PRIMARY KEY (id_evento, id_fala),
	CONSTRAINT dialogo_evento_fk FOREIGN KEY (id_evento)
		REFERENCES evento (id),
	CONSTRAINT dialogo_fala_fk FOREIGN KEY (id_fala)
		REFERENCES fala (id)
);

CREATE TABLE batalha (
	id_evento BIGINT,
	id_npc VARCHAR(100),
	
	CONSTRAINT batalha_pk PRIMARY KEY (id_evento, id_npc),
	CONSTRAINT batalha_evento FOREIGN KEY (id_evento)
		REFERENCES evento (id),
	CONSTRAINT batalha_npc FOREIGN KEY (id_npc)
		REFERENCES npc (nome)
);

CREATE TABLE event_chain (
--	evento A desbloqueia evento B
	evento_a BIGINT,
	evento_b BIGINT,
	
	CONSTRAINT event_chain_pk PRIMARY KEY (evento_a, evento_b),
	CONSTRAINT event_chain_evento_a_fk FOREIGN KEY (evento_a)
		REFERENCES evento (id),
	CONSTRAINT event_chain_evento_b_fk FOREIGN KEY (evento_b)
		REFERENCES evento (id)
);

CREATE TABLE quadrado_evento (
	pos_x SMALLINT,
	pos_y SMALLINT,
	area VARCHAR(50),
	mapa VARCHAR(100),
	evento BIGINT,
	
	CONSTRAINT quadrado_evento_pk PRIMARY KEY (pos_x, pos_y, area, mapa, evento),
	CONSTRAINT quadrado_evento_quadrado_fk FOREIGN KEY (pos_x, pos_y, area, mapa)
		REFERENCES quadrado (pos_x, pos_y, area, mapa),
	CONSTRAINT quadrado_evento_evento_fk FOREIGN KEY (evento)
		REFERENCES evento (id)
);

CREATE TABLE drop (
	item BIGINT,
	evento BIGINT,
	chance INTEGER,
	
	CONSTRAINT drop_pk PRIMARY KEY (item, evento),	
	CONSTRAINT drop_item_fk FOREIGN KEY (item)
		REFERENCES item (id),
	CONSTRAINT drop_evento_fk FOREIGN KEY (evento)
		REFERENCES evento (id)
);

CREATE TABLE sessao (
-- Equivalente a um save slot
	id BIGSERIAL,
	criado_em TIMESTAMP DEFAULT Now(),
	player VARCHAR(100) NOT NULL,
	
	CONSTRAINT sessao_pk PRIMARY KEY (id),
	CONSTRAINT sessao_player_fk FOREIGN KEY (player)
		REFERENCES player (nome)
);

CREATE TABLE sessao_quadrado (
	sessao BIGINT,
	pos_x SMALLINT,
	pos_y SMALLINT,
	area VARCHAR(50),
	mapa VARCHAR(100),
	visitado BOOLEAN DEFAULT FALSE,
	item_pego BOOLEAN DEFAULT FALSE,
	obstaculo_ativo BOOLEAN DEFAULT FALSE,
	efeito_ativo BOOLEAN DEFAULT FALSE,
	
	CONSTRAINT sessao_quadrado_pk PRIMARY KEY (sessao, pos_x, pos_y, area, mapa),
	CONSTRAINT sessao_quadrado_sessao_fk FOREIGN KEY (sessao)
		REFERENCES sessao (id),
	CONSTRAINT sessao_quadrado_quadrado_fk FOREIGN KEY (pos_x, pos_y, area, mapa)
		REFERENCES quadrado (pos_x, pos_y, area, mapa)
);

CREATE TABLE estado_evento (
	sessao BIGINT,
	evento BIGINT,
	desbloqueado BOOLEAN DEFAULT FALSE,
	ativo BOOLEAN DEFAULT FALSE,
	
	CONSTRAINT estado_evento_pk PRIMARY KEY (sessao, evento),
	CONSTRAINT estado_evento_sessao_fk FOREIGN KEY (sessao)
		REFERENCES sessao (id),
	CONSTRAINT estado_evento_evento_fk FOREIGN KEY (evento)
		REFERENCES evento (id),
	CONSTRAINT estado_evento_ck CHECK (NOT (desbloqueado = FALSE AND ativo = TRUE))
);

CREATE TABLE mapa_completo (
	sessao BIGINT,
	mapa VARCHAR(100),
	completo BOOLEAN DEFAULT FALSE,
	
	CONSTRAINT mapa_completo_pk PRIMARY KEY (sessao, mapa),
	CONSTRAINT mapa_completo_sessao FOREIGN KEY (sessao)
		REFERENCES sessao (id),
	CONSTRAINT mapa_completo_mapa FOREIGN KEY (mapa)
		REFERENCES mapa (nome)
);

CREATE TABLE comercio (

	pos_x SMALLINT, 
	pos_y SMALLINT,
	area VARCHAR(50),
	mapa VARCHAR(100),
	id_loja INTEGER,

	CONSTRAINT comercio_pk PRIMARY KEY (pos_x, pos_y, area, mapa),
--	CONSTRAINT area_fk FOREIGN KEY (area, mapa) REFERENCES area (nome, mapa),
	CONSTRAINT comercio_quadrado_fk FOREIGN KEY (pos_x, pos_y, area, mapa)
		REFERENCES quadrado (pos_x, pos_y, area, mapa),
	CONSTRAINT id_loja_fk FOREIGN KEY (id_loja) REFERENCES loja (id)
);

CREATE TABLE instancia_batalha (
	id BIGSERIAL,
	nome_player VARCHAR(100),
	nome_npc 	VARCHAR(100),

	CONSTRAINT instancia_batalha_pk PRIMARY KEY (id),
	CONSTRAINT instancia_batalha_player_fk FOREIGN KEY (nome_player) REFERENCES player (nome),
	CONSTRAINT instancia_batalha_npc_fk FOREIGN KEY (nome_npc) REFERENCES npc (nome)
);

CREATE TABLE instancia_inimigo (
	-- instancias de npcs em batalhas.
	batalha_id BIGINT,
	nome VARCHAR(100),
	hp PRIM_STAT,
	energia PRIM_STAT,
	ataque SEC_STAT,
	defesa SEC_STAT,
	evasao SEC_STAT,
	agilidade SEC_STAT,
	arma BIGINT,
	armadura BIGINT,
	
	CONSTRAINT npc_inst_pk PRIMARY KEY (batalha_id, nome),
	CONSTRAINT npc_inst_arma_fk FOREIGN KEY (arma)
		REFERENCES arma (id),
	CONSTRAINT npc_inst_armadura_fk FOREIGN KEY (armadura)
		REFERENCES armadura (id),
	CONSTRAINT npc_inst_batalha_fk FOREIGN KEY (batalha_id)
		REFERENCES instancia_batalha (id)
);

--CREATE TABLE venda (
--
--	id_loja SMALLINT,
--	id_item INTEGER,
--	
--
--	CONSTRAINT venda_pk PRIMARY KEY (id_loja, id_item),
--	CONSTRAINT loja_fk FOREIGN KEY (id_loja) REFERENCES loja (id),
--	CONSTRAINT id_item_fk FOREIGN KEY (id_item) REFERENCES item (id)
--
--);

COMMIT;
