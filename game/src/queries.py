insert_player = "INSERT INTO player (nome) VALUES (%s) RETURNING inventario"
create_session = "INSERT INTO sessao (player) VALUES (%s) RETURNING id"

# Recupera dimensões de uma área
"SELECT largura, altura FROM area WHERE mapa=%s AND nome=%s"

# Para printar o mapa
"SELECT pos_x, pos_y, visitado FROM sessao_quadrado WHERE sessao=%s AND area=%s AND mapa=%s"

# cria instâncias de eventos para a progressão nesta sessão (ou save slot) 
"SELECT copy_events(%s)"

# cria instâncias para o estado dos quadrados na sessão atual e retorna 
# o quadrado onde o player começa
"SELECT * FROM enter_area(%s, %s, %s);"

# Lista todas as sessões (save slots)
"SELECT id, to_char(criado_em, 'DD/MM/YYYY HH24:MI'), player FROM sessao;"

# Recupera algumas informações do player pra manter instanciado no código
"SELECT player.nome, player.inventario FROM player, sessao WHERE sessao.id=%s AND player.nome=sessao.player;"

# A função walk_to verifica se o personagem pode andar para o próximo quadrado
# e retorna true ou false
"SELECT * FROM walk_to(%s, %s, %s, %s, %s)"

# mark_visited marca o quadrado como visitado. Assim é possível exibir por onde o player já passou
"SELECT mark_visited(%s, %s, %s, %s, %s)"

# Recupera as falas de um evento de dialogo
"""SELECT fala.texto FROM dialogo, fala 
        WHERE id_evento=%s AND fala.id=dialogo.id_fala 
        ORDER BY dialogo.ordem;"""

# Recupera o id do npc que participa em um evento do tipo batalha
"SELECT id_npc FROM batalha WHERE id_evento=%s"

# Cria uma instância de batalha contra um npc
"SELECT * FROM create_battle_instance(%s, %s)"

# O próprio banco cuida da lógica de dano de quando o player ataca o inimigo e vice-versa
"SELECT * FROM player_ataca(%s, %s, %s);"
"SELECT * FROM npc_ataca(%s, %s, %s);"

# Retorna dados da instância do inimigo contra quem o player está batalhando
"SELECT * FROM instancia_inimigo WHERE batalha_id=%s AND nome=%s;"

# Retorna dados de estado do player
"SELECT * FROM player WHERE player.nome = %s"

# Finaliza uma instância de batalha
"SELECT finish_battle_instance(%s)"

# Retorna os itens que podem ser usados em batalha
"SELECT L.invent_id, L.slot_pos, L.item_id, L.item_name FROM (SELECT * FROM list_itens(%s)) AS L, item WHERE L.item_id=item.id AND item.tipo='consumivel'"

# Recupera as informações de quanto determinado item cura
"SELECT modificador_dano, modificador_energia FROM consumivel WHERE id=%s"

# Usa um consumível
"SELECT * FROM altera_hp_energia(%s, %s, %s);"

# Dropa um item
"SELECT drop_item(%s::TEXT, %s::SMALLINT);"

# Verifica se há um evento desbloqueado e ativo no quadrado
"SELECT * FROM get_active_event(%s, %s, %s, %s, %s)"

# Retorna o tipo de evento
"SELECT tipo FROM evento WHERE id=%s"

# Desbloqueia eventos conforme a event_chain
"SELECT unblock_event(%s, %s);"

# Retorna o item disponível no quadrado, se tiver algum
"SELECT item FROM quadrado_item WHERE pos_x=%s AND pos_y=%s AND area=%s AND mapa=%s;"

# Retorna se um item existente no quadrado foi pego ou não 
"SELECT item_pego FROM sessao_quadrado WHERE sessao=%s AND pos_x=%s AND pos_y=%s AND area=%s AND mapa=%s"

# Pega o item do quadrado
"SELECT * FROM take_item(%s, %s, %s, %s, %s);"

# Retorna estado do player
"SELECT * FROM see_player_status(%s);"

# Lista os itens do inventário
"SELECT * FROM list_itens(%s)"

# Verifica o tipo de um item
"SELECT * FROM verifica_tipo_item(%s, %s);"

# Equipa um item do tipo equip
"SELECT equipa_armamento(%s, %s, %s);"

# Retorna os dados de uma arma/armadura equipados
"SELECT arma FROM (SELECT player.arma as wid FROM player WHERE nome=%s) as W, arma WHERE arma.id=W.wid;"
"SELECT armadura FROM (SELECT player.armadura as aid FROM player WHERE nome=%s) as A, armadura WHERE armadura.id=A.aid;"

# Desequipa armamento
"SELECT desequipa_armamento(%s, %s);"

# Retorna a posição que um player começa em uma determinada área
"""SELECT QT.pos_x, QT.pos_y, QT.area::TEXT, QT.mapa::TEXT FROM quadrado_tipo QT
            WHERE QT.tipo='entrada0' AND QT.mapa=%s AND QT.area=%s;"""