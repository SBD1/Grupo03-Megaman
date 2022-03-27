INSERT INTO item (id, tipo) VALUES 
('', '');

INSERT INTO consumivel (id, nome, descricao, valor_compra, valor_venda, modificador_dano, modificador_energia) VALUES 
('1', 'Arma-EXP-100', 'Material usado para melhorar as armas', '150', '100', '500', '0'),
('2', 'Arma-EXP-250', 'Material usado para melhorar as armas', '250', '200', '500', '0'),
('3', 'Arma-EXP-500', 'Material usado para melhorar as armas', '400', '300', '500', '0'),
('4', 'Arma-EXP-1000', 'Material usado para melhorar as armas', '600', '500', '500', '0');

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