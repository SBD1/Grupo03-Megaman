INSERT INTO item (id, tipo) VALUES 
('', '');

INSERT INTO consumivel (id, nome, descricao, valor_compra, valor_venda, modificador_dano, modificador_energia) VALUES 
('1', 'Arma-EXP-100', 'Material usado para melhorar as armas', '150', '100', '100', '0'),
('2', 'Arma-EXP-250', 'Material usado para melhorar as armas', '250', '200', '250', '0'),
('3', 'Arma-EXP-500', 'Material usado para melhorar as armas', '400', '300', '500', '0'),
('4', 'Arma-EXP-1000', 'Material usado para melhorar as armas', '600', '500', '1000', '0');

INSERT INTO chave (id, nome, descricao, valor_compra, valor_venda) VALUES 
('', '', '', '', '');

INSERT INTO equip (id, tipo) VALUES 
('', '');

INSERT INTO armadura (id, nome, tipo, descricao, valor_compra, valor_venda, valor_upgrade, nivel, energia, ataque, defesa) VALUES 
('', '', '', '', '', '', '', '', '', '', '');

INSERT INTO arma (id, nome, tipo, descricao, valor_compra, valor_venda, valor_upgrade, nivel, energia, ataque, defesa) VALUES 
('', '', '', '', '', '', '', '', '', '', '');

INSERT INTO inventario (id, tamanho) VALUES 
('', '');

INSERT INTO slot (id_inventario, pos, item) VALUES 
('', '', '');

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
('', '', '', '', '', '', '', '', '', '', '');

INSERT INTO npc (nome, hp, energia, ataque, defesa, evasao, agilidade, arma, armadura) VALUES 
('', '', '', '', '', '', '', '', '');

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
('', '', '', '');

INSERT INTO quadrado (pos_x, pos_y, area, mapa, chance_batalha) VALUES 
('', '', '', '', '');

INSERT INTO quadrado_efeito (pos_x, pos_y, area, hp_mod, mp_mod) VALUES 
('', '', '', '', '', '');

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
