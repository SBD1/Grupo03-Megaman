-- BEGIN;

-- INSERT INTO item (tipo) VALUES 
-- ('chave'),
-- ('consumivel'),
-- ('consumivel'),
-- ('consumivel'),
-- ('consumivel'),
-- ('equip'),
-- ('equip');

INSERT INTO chave (nome, descricao) VALUES 
('Chave da base abandonada', 'Chave feita para destrancar a porta da base');

INSERT INTO consumivel (nome, descricao, valor_compra, valor_venda, modificador_dano, modificador_energia) VALUES 
('Arma-EXP-100', 'Material usado para melhorar as armas', '150', '100', '100', '0'),
('Arma-EXP-250', 'Material usado para melhorar as armas', '250', '200', '250', '0'),
('Arma-EXP-500', 'Material usado para melhorar as armas', '400', '300', '500', '0'),
('Arma-EXP-1000', 'Material usado para melhorar as armas', '600', '500', '1000', '0');

-- INSERT INTO equip (id, tipo) VALUES 
-- (6,'arma'),
-- (7,'armadura');

INSERT INTO armadura (nome, descricao, valor_compra, valor_venda, valor_upgrade, nivel, energia, ataque, defesa) VALUES 
('Armadura contra explosões', 'Armadura feita para ser resistente contra explosões de inimigos', '300', '260', '200', '1', '50', '0', '100');

INSERT INTO arma (nome, descricao, valor_compra, valor_venda, valor_upgrade, nivel, energia, ataque, agilidade) VALUES 
('Canhão Fumegante', 'Canhão feito de energia e metal. Arma lenta mas muito potente. Ideal para inimigos agrupados', '300', '260', '200', '1', '50', '400', '0');

--INSERT INTO inventario (tamanho) VALUES 
--(50);

--INSERT INTO slot (id_inventario, pos, item) VALUES 
--(1, '1', '2');

INSERT INTO personagem (nome, tipo) VALUES 
-- ('Mega Man', 'player' ),
-- ('Zero', 'player'),
('Ball De Voux', 'npc'),
('Metall C-15', 'npc'),
('Spiky', 'npc'),
('Chill Penguin', 'npc'),
('Armored Armadillo', 'npc'),
('Thunder Slimer', 'npc'),
('Utobolus', 'npc'),
('Launcher Octopus', 'npc'),
('RT-55J', 'npc'),
('Sting Chameleon', 'npc'),
('Storm Eagle', 'npc'),
('Flame Mamooth', 'npc'),
('Vile', 'npc'),
('Bospider', 'npc'),
('Rangda Bangda', 'npc'),
('D-Rex', 'npc'),
('Velguader', 'npc'),
('Aika', 'npc');

INSERT INTO player (nome, hp, energia, ataque, defesa, evasao, agilidade, creditos) VALUES 
('Mega Man', '999', '999', '20', '300', '300', '100', '1000');

INSERT INTO npc (nome, hp, energia, ataque, defesa, evasao, agilidade) VALUES 
('Utobolus', '25', '50', '5', '6', '10', '10');

INSERT INTO mapa (nome, descricao) VALUES 
('MONTANHA NEVADA', 'Uma montanha dominada pelo Chill Penguin');
-- ('AUTO ESTRADA', 'Vá seguindo em frente, só tenha cuidado com as plataformas que desabam'),
-- ('USINA DE ENERGIA', 'O maior problema aqui é a escuridão em alguns pontos, preste atenção na posição dos inimigos para não cair em buracos'),
-- ('MINAS', 'Cuidado com os buracos, cuidado também com o rolo compressor'),
-- ('OCEANO', 'Cuidado com espinhos no chão, principalmente quando enfrentar o robô que te empurra com um jato de água'),
-- ('TORRE', 'Tenha cuidado na hora que for subir no elevador para não morrer nos espinhos'),
-- ('FLORESTA', 'O maior problema aqui é na parte em que arvorés caem'),
-- ('CÉUS', 'Logo no começo quando estiver subindo nas plataformas móveis, pode ter problemas com robos que te jogam no abismo'),
-- ('FÁBRICA', 'Tenha cuidado na hora que for passar pelas máquinas'),
-- ('FORTALEZA DE SIGMA', 'Cuidado com as armadilhas espalhadas pelo castelo');


INSERT INTO area (mapa, nome, largura, altura) VALUES 
-- ('AUTO ESTRADA', 'Início', '120', '60'),
('MONTANHA NEVADA', 'Entrada', 9, 9);

INSERT INTO quadrado (pos_x, pos_y, area, mapa, chance_batalha) VALUES 
(5, 9, 'Entrada', 'MONTANHA NEVADA', 0),
(5, 8, 'Entrada', 'MONTANHA NEVADA', 30),
(5, 7, 'Entrada', 'MONTANHA NEVADA', 30),
(5, 6, 'Entrada', 'MONTANHA NEVADA', 30),
(5, 5, 'Entrada', 'MONTANHA NEVADA', 30),
(5, 4, 'Entrada', 'MONTANHA NEVADA', 30),
(5, 3, 'Entrada', 'MONTANHA NEVADA', 30),
(5, 2, 'Entrada', 'MONTANHA NEVADA', 0),
(1, 3, 'Entrada', 'MONTANHA NEVADA', 0),
(2, 3, 'Entrada', 'MONTANHA NEVADA', 30),
(3, 3, 'Entrada', 'MONTANHA NEVADA', 30),
(4, 3, 'Entrada', 'MONTANHA NEVADA', 30),
(4, 4, 'Entrada', 'MONTANHA NEVADA', 30),
(5, 1, 'Entrada', 'MONTANHA NEVADA', 0),
(6, 7, 'Entrada', 'MONTANHA NEVADA', 30),
(7, 7, 'Entrada', 'MONTANHA NEVADA', 30),
(8, 7, 'Entrada', 'MONTANHA NEVADA', 30),
(9, 7, 'Entrada', 'MONTANHA NEVADA', 30),
(9, 4, 'Entrada', 'MONTANHA NEVADA', 30),
(9, 5, 'Entrada', 'MONTANHA NEVADA', 30),
(9, 6, 'Entrada', 'MONTANHA NEVADA', 0);
-- (1, 1, 'Início', 'AUTO ESTRADA', '50'),
-- (1, 2, 'Início', 'AUTO ESTRADA', '50'),
-- (1, 3, 'Início', 'AUTO ESTRADA', '50'),
-- (2, 1, 'Início', 'AUTO ESTRADA', '50'),
-- (2, 2, 'Início', 'AUTO ESTRADA', '50'),
-- (2, 3, 'Início', 'AUTO ESTRADA', '50'),
-- (3, 1, 'Início', 'AUTO ESTRADA', '50'),
-- (3, 2, 'Início', 'AUTO ESTRADA', '50'),
-- (3, 3, 'Início', 'AUTO ESTRADA', '50');

INSERT INTO quadrado_tipo (pos_x, pos_y, area, mapa, tipo) VALUES
(5, 9,'Entrada', 'MONTANHA NEVADA', 'entrada0'),
(5, 2,'Entrada', 'MONTANHA NEVADA', 'barreira'),
-- (5, 8,'Entrada', 'MONTANHA NEVADA', 'evento'),
(5, 1,'Entrada', 'MONTANHA NEVADA', 'saida0');
-- (1, 1, 'Início', 'AUTO ESTRADA', 'entrada'),
-- (1, 2, 'Início', 'AUTO ESTRADA', 'efeito'),
-- (2, 2, 'Início', 'AUTO ESTRADA', 'item'),
-- (3, 3, 'Início', 'AUTO ESTRADA', 'saida');

-- INSERT INTO quadrado_efeito (pos_x, pos_y, area, mapa, hp_mod, mp_mod) VALUES 
-- (1, 2, 'Início', 'AUTO ESTRADA', 10, 10);

SELECT add_item_to_quadrado(9, 4, 'Entrada', 'MONTANHA NEVADA', 'Chave da base abandonada', 'chave');
SELECT add_item_to_quadrado(1, 3, 'Entrada', 'MONTANHA NEVADA', 'Arma-EXP-100', 'consumivel');
SELECT add_item_to_quadrado(4, 4, 'Entrada', 'MONTANHA NEVADA', 'Canhão Fumegante', 'arma');
SELECT add_item_to_quadrado(5, 6, 'Entrada', 'MONTANHA NEVADA', 'Arma-EXP-100', 'consumivel');

-- INSERT INTO conecta (pos_x1, pos_y1, area1, mapa1, pos_x2, pos_y2, area2, mapa2) VALUES 
-- ('', '', '', '', '', '', '', '');

--INSERT INTO altera (chave, pos_x, pos_y, area, mapa) VALUES 
--('', '', '', '', '');

SELECT set_destranca(5, 2, 'Entrada', 'MONTANHA NEVADA', 'Chave da base abandonada');

--INSERT INTO destranca (chave, pos_x, pos_y, area, mapa) VALUES 
--('', '', '', '', '');

--INSERT INTO usa (id_chave, id_player) VALUES 
--('', '');

--INSERT INTO habilidade (id, descricao) VALUES 
--('', '');

INSERT INTO loja (nome) VALUES 
('Hunter Store');

--INSERT INTO estoque (id_loja, id_item) VALUES 
--(1, 2),
--(1, 3),
--(1, 4),
--(1, 5),
--(1, 6),
--(1, 7);

--INSERT INTO melhoria (loja, equipamento) VALUES 
--(1, 6),
--(1, 7);

--INSERT INTO fala (id, texto) VALUES 
--('', '');

--('Mega Man', 'player' ),
--('Zero', 'player'),
--('Ball De Voux', 'npc'),
--('Metall C-15', 'npc'),
--('Spiky', 'npc'),
--('Chill Penguin', 'npc'),
--('Armored Armadillo', 'npc'),

-- INSERT INTO bestiario (mapa, npc) VALUES 
-- ('AUTO ESTRADA', 'Utobolus');

INSERT INTO elemento (nome) VALUES 
('fogo'),
('agua');

INSERT INTO resistencia (nivel, porcentagem) VALUES 
('normal', 50),
('nulo', 0),
('fraco', 25),
('forte', 75),
('total', 100);

INSERT INTO resiste (elemento_a, elemento_b, intensidade) VALUES 
('fogo', 'agua', 'fraco'),
('agua', 'fogo', 'forte');

--INSERT INTO equip_elem (equipamento, elemento) VALUES 
--('', '');

--INSERT INTO equip_skill (equipamento, habilidade) VALUES 
--('', '');

-- INSERT INTO evento (tipo, acionamento_direto, estado_desbloqueio_inicial) VALUES 
-- ('d', , '', '', '', '');

DO $$ DECLARE event_id BIGINT;
BEGIN
    SELECT create_event_dialog('Aika', 
        'O Chill Penguin está criando mísseis na base abandonada.\nCuidado com a área congelada.',
        '', TRUE, TRUE) INTO event_id;
    
    INSERT INTO quadrado_tipo (pos_x, pos_y, area, mapa, tipo) VALUES
        (5, 8, 'Entrada', 'MONTANHA NEVADA', 'evento');

    INSERT INTO quadrado_evento (pos_x, pos_y, area, mapa, evento) VALUES 
        (5, 8, 'Entrada', 'MONTANHA NEVADA', event_id);

END $$;

DO $$ DECLARE event_id BIGINT;
BEGIN
    SELECT create_event_dialog('Dev',
        'Área passada!\nObrigado por jogar :)',
        '', TRUE, TRUE) INTO event_id;

    INSERT INTO quadrado_tipo (pos_x, pos_y, area, mapa, tipo) VALUES
        (5, 2, 'Entrada', 'MONTANHA NEVADA', 'evento');

    INSERT INTO quadrado_evento (pos_x, pos_y, area, mapa, evento) VALUES 
        (5, 2, 'Entrada', 'MONTANHA NEVADA', event_id);
END $$;

DO $$ DECLARE event_id BIGINT;
BEGIN
    SELECT create_battle_event('Utobolus', '', TRUE, TRUE) INTO event_id;

    INSERT INTO quadrado_tipo (pos_x, pos_y, area, mapa, tipo) VALUES 
        (3, 3, 'Entrada', 'MONTANHA NEVADA', 'evento');

    INSERT INTO quadrado_evento (pos_x, pos_y, area, mapa, evento) VALUES
        (3, 3, 'Entrada', 'MONTANHA NEVADA', event_id);
END $$;

--INSERT INTO evento_chain (evento_a, evento_b) VALUES 
--('', '');

--INSERT INTO quadrado_evento (pos_x, pos_y, area, mapa, evento) VALUES 
--('', '', '', '', '');

--INSERT INTO drop (item, evento, chance) VALUES 
--('', '', '');

--INSERT INTO sessao (id, criado_em, player) VALUES 
--('', '', '');

--INSERT INTO sessao_quadrado (sessao, pos_x, pos_y, area, mapa, visado, item_pego, obstaculo_ativo, efeito_ativo) VALUES 
--('', '', '', '', '', '', '', '', '');

--INSERT INTO estado_evento (sessao, evento, desbloqueado, ativo) VALUES 
--('', '', '', '');

--INSERT INTO mapa_completo (sessao, mapa, completo) VALUES 
--('', '', '');

--INSERT INTO comercio (pos_x, pos_y, area, mapa, id_loja) VALUES 
--('', '', '', '', '');

-- COMMIT;
