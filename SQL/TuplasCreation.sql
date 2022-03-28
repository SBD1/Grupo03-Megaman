INSERT INTO item (tipo) VALUES 
('chave');

INSERT INTO consumivel (nome, descricao, valor_compra, valor_venda, modificador_dano, modificador_energia) VALUES 
('Arma-EXP-100', 'Material usado para melhorar as armas', '150', '100', '100', '0'),
('Arma-EXP-250', 'Material usado para melhorar as armas', '250', '200', '250', '0'),
('Arma-EXP-500', 'Material usado para melhorar as armas', '400', '300', '500', '0'),
('Arma-EXP-1000', 'Material usado para melhorar as armas', '600', '500', '1000', '0');

INSERT INTO chave (id, nome, descricao, valor_compra, valor_venda) VALUES 
('', 'Chave da Nave', 'Chave feita para destrancar a porta da nave', '100', '80');

INSERT INTO equip (id, tipo) VALUES 
('1','arma'),
('2','armadura');

INSERT INTO armadura (nome, tipo, descricao, valor_compra, valor_venda, valor_upgrade, nivel, energia, ataque, defesa) VALUES 
('Armadura contra explosões', 'Armadura feita para ser resistente contra explosões de inimigos', '300', '260', '200', '1', '50', '0', '100');

INSERT INTO arma (nome, tipo, descricao, valor_compra, valor_venda, valor_upgrade, nivel, energia, ataque, defesa) VALUES 
('Canhão Fumegante', 'Canhão feito de energia e metal. Arma lenta mas muito potente. Ideal para inimigos agrupados', '300', '260', '200', '1', '50', '400', '0');

INSERT INTO inventario (tamanho) VALUES 
('50');

INSERT INTO slot (id_inventario, pos, item) VALUES 
('1', '1', '15');

INSERT INTO personagem (nome, tipo) VALUES 
('Mega Man', 'player' ),
('Zero', 'player'),
('Chill Penguin', 'npc'),
('Thunder Slimer', 'npc'),
('Armored Armadillo', 'npc'),
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
('Velguader', 'npc');

INSERT INTO player (nome, inventario, hp, energia, ataque, defesa, evasao, agilidade, creditos, arma, armadura) VALUES 
('Mega Man', '50', '1000', '1000', '301', '301', '100', '100', '1000', '15', '2');

INSERT INTO npc (nome, hp, energia, ataque, defesa, evasao, agilidade, arma, armadura) VALUES 
('Utobolus', '300', '300', '100', '100', '30', '30', '1', '0');

INSERT INTO mapa (nome, descricao) VALUES 
('AUTO ESTRADA', 'Vá seguindo em frente, só tenha cuidado com as plataformas que desabam'),
('MONTANHA NEVADA', 'O maior problema aqui é na parte em que o chão desliza, você pode escorregar direto para o abismo'),
('USINA DE ENERGIA', 'O maior problema aqui é a escuridão em alguns pontos, preste atenção na posição dos inimigos para não cair em buracos'),
('MINAS', 'Cuidado com os buracos, cuidado também com o rolo compressor'),
('OCEANO', 'Cuidado com espinhos no chão, principalmente quando enfrentar o robô que te empurra com um jato de água'),
('TORRE', 'Tenha cuidado na hora que for subir no elevador para não morrer nos espinhos'),
('FLORESTA', 'O maior problema aqui é na parte em que arvorés caem'),
('CÉUS', 'Logo no começo quando estiver subindo nas plataformas móveis, pode ter problemas com robos que te jogam no abismo'),
('FÁBRICA', 'Tenha cuidado na hora que for passar pelas máquinas'),
('FORTALEZA DE SIGMA', 'Cuidado com as armadilhas espalhadas pelo castelo');


INSERT INTO area (mapa, nome, largura, altura) VALUES 
('AUTO ESTRADA', 'Início', '120', '60');

INSERT INTO quadrado (pos_x, pos_y, area, mapa, chance_batalha) VALUES 
('10', '20', 'Início', 'AUTO ESTRADA', '50');

INSERT INTO quadrado_tipo (pos_x, pos_y, area, mapa, tipo) VALUES 
('10', '20', 'Início', 'AUTO ESTRADA', 'efeito');

INSERT INTO quadrado_efeito (pos_x, pos_y, area, hp_mod, mp_mod) VALUES 
('10', '20', 'Início', '10', '10', '10');

INSERT INTO quadrado_item (pos_x, pos_y, area, mapa, item) VALUES 
('', '', '', '', '');

INSERT INTO conecta (pos_x1, pos_y1, area1, mapa1, pos_x2, pos_y2, area2, mapa2) VALUES 
('', '', '', '', '', '', '', '');

INSERT INTO altera (chave, pos_x, pos_y, area, mapa) VALUES 
('', '', '', '', '');

INSERT INTO destranca (chave, pos_x, pos_y, area, mapa) VALUES 
('', '', '', '', '');

INSERT INTO usa (id_chave, id_player) VALUES 
('', '');

INSERT INTO habilidade (id, descricao) VALUES 
('', '');

INSERT INTO loja (id, nome) VALUES 
('', '');

INSERT INTO estoque (id_loja, id_item) VALUES 
('', '');

INSERT INTO melhoria (loja, equipamento) VALUES 
('', '');

INSERT INTO fala (id, texto) VALUES 
('', '');

INSERT INTO bestiario (mapa, npc) VALUES 
('', '');

INSERT INTO elemento (nome) VALUES 
('');

INSERT INTO resistencia (nivel, porcentagem) VALUES 
('', '');

INSERT INTO resiste (elemento_a, elemento_b, intensidade) VALUES 
('', '', '');

INSERT INTO equip_elem (equipamento, elemento) VALUES 
('', '');

INSERT INTO equip_skill (equipamento, habilidade) VALUES 
('', '');

INSERT INTO evento (id, condicao, tipo, ev_anterior, acionamento_direito, desbloqueado) VALUES 
('', '', '', '', '', '');

INSERT INTO evento_chain (evento_a, evento_b) VALUES 
('', '');

INSERT INTO quadrado_evento (pos_x, pos_y, area, mapa, evento) VALUES 
('', '', '', '', '');

INSERT INTO drop (item, evento, chance) VALUES 
('', '', '');

INSERT INTO sessao (id, criado_em, player) VALUES 
('', '', '');

INSERT INTO sessao_quadrado (sessao, pos_x, pos_y, area, mapa, visado, item_pego, obstaculo_ativo, efeito_ativo) VALUES 
('', '', '', '', '', '', '', '', '');

INSERT INTO estado_evento (sessao, evento, desbloqueado, ativo) VALUES 
('', '', '', '');

INSERT INTO mapa_completo (sessao, mapa, completo) VALUES 
('', '', '');

INSERT INTO comercio (pos_x, pos_y, area, mapa, id_loja) VALUES 
('', '', '', '', '');

INSERT INTO venda (id_loja, id_item) VALUES 
('', '');
