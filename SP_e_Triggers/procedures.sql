-- Adiciona item no quadrado
CREATE OR REPLACE FUNCTION add_item_to_quadrado(x INT, y INT, area TEXT, mapa TEXT, item_name TEXT, item_type TEXT) RETURNS void AS $$
DECLARE
    item_id item.id%TYPE;
BEGIN
    IF (item_type = 'consumivel') THEN
        SELECT consumivel.id INTO item_id FROM consumivel WHERE consumivel.nome = item_name;
    ELSIF (item_type = 'chave') THEN
        SELECT chave.id INTO item_id FROM chave WHERE chave.nome = item_name;
    ELSIF (item_type = 'armadura') THEN
        SELECT armadura.id INTO item_id FROM armadura WHERE armadura.nome = item_name;
    ELSIF (item_type = 'arma') THEN
        SELECT arma.id INTO item_id FROM arma WHERE arma.nome = item_name;
    END IF;

    INSERT INTO quadrado_tipo (pos_x, pos_y, area, mapa, tipo) VALUES (x, y, area, mapa, 'item');
    INSERT INTO quadrado_item (pos_x, pos_y, area, mapa, item) VALUES (x, y, area, mapa, item_id);
END;
$$ LANGUAGE plpgsql;

-- Cria a relação de qual chave destranca qual quadrado
CREATE OR REPLACE FUNCTION set_destranca(x INT, y INT, area_ TEXT, mapa_ TEXT, item_name TEXT) RETURNS void AS $$
DECLARE
    item_id item.id%TYPE;
    num INT;
BEGIN
    -- primeiro testa se quadrado é do tipo barreira
    SELECT count(*) INTO num FROM quadrado_tipo WHERE 
        quadrado_tipo.pos_x = x AND quadrado_tipo.pos_y = y AND quadrado_tipo.area = area_
        AND quadrado_tipo.mapa = mapa_ AND quadrado_tipo.tipo = 'barreira';
    
    IF (num != 1) THEN
        RAISE EXCEPTION 'Quadrado não é do tipo barreira';
    END IF;

    SELECT chave.id INTO item_id FROM chave WHERE chave.nome = item_name;

    IF (num IS NULL) THEN
        RAISE EXCEPTION 'Não existe uma chave com este nome';
    END IF;

    INSERT INTO destranca (chave, pos_x, pos_y, area, mapa) 
        VALUES (item_id, x, y, area_, mapa_);
END;
$$ LANGUAGE plpgsql;

-- Cria um evento do tipo diálogo.
CREATE OR REPLACE FUNCTION create_event_dialog(personagem TEXT, texto TEXT, condicao TEXT, 
    acionamento_direto BOOLEAN, estado_desbloqueio_inicial BOOLEAN) RETURNS BIGINT AS $$
DECLARE
    falas TEXT[];
    fala_ TEXT;
    fala_id INT;
    event_id evento.id%TYPE;
    i INT := 0;
BEGIN
    falas := string_to_array(texto, '\n');
    INSERT INTO evento (tipo, condicao, acionamento_direto, estado_desbloqueio_inicial) VALUES 
        ('d', condicao, acionamento_direto, estado_desbloqueio_inicial) RETURNING id INTO event_id;

    FOREACH fala_ IN ARRAY falas
    LOOP
        INSERT INTO fala (texto) VALUES (personagem || ': ' || fala_) RETURNING id INTO fala_id;
        INSERT INTO dialogo (id_evento, id_fala, ordem) VALUES (event_id, fala_id, i);
        i := i + 1;
    END LOOP;
    RETURN event_id;
END;
$$ LANGUAGE plpgsql;

-- Checa se um quadrado é andável
CREATE OR REPLACE FUNCTION check_quad_is_walkable(x INT, y INT, area_ TEXT, mapa_ TEXT) RETURNS BOOLEAN AS $$
DECLARE
    num_records INT;
BEGIN
    SELECT count(*) INTO num_records FROM quadrado Q WHERE Q.pos_x = x AND Q.pos_y = y AND Q.area = area_ AND Q.mapa = mapa_;
    IF (num_records = 0) THEN
        RETURN FALSE;
    END IF;
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- checa se há uma barreira no quadrado
CREATE OR REPLACE FUNCTION check_quad_barrier(player_ TEXT, x INT, y INT, area_ TEXT, mapa_ TEXT, OUT is_barrier BOOLEAN, OUT is_locked BOOLEAN) AS $$
DECLARE
    rslt INT;
    chave_id BIGINT DEFAULT -1;
BEGIN
    -- checa se é uma barreira
    SELECT count(*) INTO rslt FROM quadrado_tipo QT WHERE
        QT.pos_x = x AND QT.pos_y = y AND QT.area = area_ AND QT.mapa = mapa_ AND QT.tipo = 'barreira';

    IF (rslt != 1) THEN
        is_barrier := FALSE;
        is_locked := FALSE;
        RETURN;
    END IF;

    is_barrier := TRUE;

    -- Pega o id da chave necessária pra desbloquear o quadrado
    SELECT D.chave INTO chave_id FROM destranca D WHERE D.pos_x = x AND D.pos_y = y
        AND D.area = area_ AND D.mapa = mapa_;

    IF (chave_id = -1 OR chave_id IS NULL) THEN
        RAISE EXCEPTION 'Não há chave associada a barreira';
    END IF;

    -- checa se o player tem a chave
    SELECT count(*) INTO rslt FROM chaveiro C WHERE C.id_chave = chave_id AND C.id_player = player_;

    IF (rslt = 1) THEN
        is_locked := FALSE;
    ELSE 
        is_locked := TRUE;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- checa se o player pode andar para um quadrado
CREATE OR REPLACE FUNCTION walk_to(player_ TEXT, x INT, y INT, area_ TEXT, mapa_ TEXT) RETURNS BOOLEAN AS $$
DECLARE
    is_walkable BOOLEAN;
    is_barrier BOOLEAN;
    is_barrier_blocked BOOLEAN;
BEGIN
    SELECT check_quad_is_walkable(x, y, area_, mapa_) INTO is_walkable;

    IF (is_walkable = FALSE) THEN
        RETURN FALSE;
    END IF;

    SELECT * FROM check_quad_barrier(player_, x, y, area_, mapa_) INTO is_barrier, is_barrier_blocked;

    IF (is_barrier_blocked = TRUE) THEN
        RETURN FALSE;
    END IF;

    RETURN TRUE;
    
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION mark_visited(session_id BIGINT, x INT, y INT, area_ TEXT, mapa_ TEXT) RETURNS void AS $$
BEGIN
    UPDATE sessao_quadrado SET visitado=TRUE 
        WHERE sessao=session_id AND pos_x=x AND pos_y=y AND area=area_ AND mapa=mapa_;
END;
$$ LANGUAGE plpgsql;

-- Retorna o id de um evento que ainda deve acontecer no quadrado, se tiver algum
CREATE OR REPLACE FUNCTION get_active_event(x INT, y INT, area_ TEXT, mapa_ TEXT, sessao_ BIGINT) RETURNS BIGINT AS $$
DECLARE
    event_id evento.id%TYPE;
    rec record;
    e_desbloqueado BOOLEAN;
    e_ativo BOOLEAN;
BEGIN
    FOR rec IN SELECT * FROM quadrado_evento QE WHERE 
        QE.pos_x = x AND QE.pos_y = y AND QE.area = area_ AND QE.mapa = mapa_
    LOOP
        SELECT ST.desbloqueado, ST.ativo INTO e_desbloqueado, e_ativo
            FROM estado_evento ST
            WHERE ST.evento = rec.evento AND ST.sessao = sessao_;
        
        IF (e_desbloqueado AND e_ativo) THEN
            RETURN rec.evento;
        END IF;
    END LOOP;
    RETURN -1;
END;
$$ LANGUAGE plpgsql;

-- desbloqueia os eventos
CREATE OR REPLACE FUNCTION unblock_event(event_id BIGINT, session_ BIGINT) RETURNS void AS $$
DECLARE
    rec record;
BEGIN
    UPDATE estado_evento SET desbloqueado=TRUE, ativo=TRUE WHERE evento=event_id AND sessao=session_;
    FOR rec in SELECT * FROM event_chain WHERE evento_a = event_id
    LOOP
        UPDATE estado_evento SET desbloqueado=TRUE WHERE sessao=session_ AND evento=rec.evento_b;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- pega um item do chão e coloca no inventário do player
CREATE OR REPLACE FUNCTION take_item(mapa text, area text, x INT, y INT, session_id BIGINT) RETURNS void AS $$
DECLARE
    item_id BIGINT;
    tipo_item TEXT;
    session_player text;
    not_null_count INT;
    inventario_id inventario.id%TYPE;
    rec record;
BEGIN
    -- pega o nome do player
    SELECT sessao.player INTO session_player FROM sessao
        WHERE sessao.id = session_id;

    -- pega id do item
    SELECT quadrado_item.item INTO item_id FROM quadrado_item 
        WHERE quadrado_item.mapa = mapa AND quadrado_item.area = area 
        AND quadrado_item.pos_x = x AND quadrado_item.pos_y = y;

    SELECT item.tipo INTO tipo_item FROM tipo WHERE item.id = item_id;

    IF (tipo_item = 'chave') THEN
        INSERT INTO chaveiro (id_chave, id_player) VALUES (item_id, session_player);
        RETURN;
    END IF;

    SELECT player.inventario INTO inventario_id FROM player WHERE player.nome = session_player;

    FOR rec IN SELECT * INTO rec FROM slot WHERE id_inventario = inventario_id
    LOOP
        IF (rec.item IS NULL) THEN
            UPDATE slot SET item=item_id WHERE id_inventario = rec.id_inventario AND pos = rec.pos;
            UPDATE sessao_quadrado SET item_pego=TRUE
                WHERE quadrado_item.mapa = mapa AND quadrado_item.area = area 
                AND quadrado_item.pos_x = x AND quadrado_item.pos_y = y AND quadrado_item.sessao = session_id;
            RETURN;
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_item_name(item_id BIGINT) RETURNS TEXT as $$
DECLARE
    item_type TEXT;
    equip_type TEXT;
    item_name TEXT;
BEGIN
    IF (item_id IS NULL) THEN
        RETURN 'Não equipado';
    END IF;

    SELECT tipo INTO item_type FROM item WHERE id = item_id;

    IF (item_type = 'consumivel') THEN
        SELECT nome::TEXT INTO item_name FROM consumivel WHERE id = item_id;
        RETURN item_name;
    END IF;

    IF (item_type = 'chave') THEN
        SELECT nome::TEXT INTO item_name FROM chave WHERE id = item_id;
        RETURN item_name;
    END IF;

    IF (item_type = 'equip') THEN
        SELECT tipo INTO equip_type FROM equip WHERE id = item_id;

        IF (equip_type = 'arma') THEN
            SELECT nome::TEXT INTO item_name FROM arma WHERE id = item_id;
            RETURN item_name;
        END IF;

        IF (equip_type = 'armadura') THEN
            SELECT nome::TEXT INTO item_name FROM armadura WHERE id = item_id;
            RETURN item_name;
        END IF;
    END IF;

    RAISE EXCEPTION 'ID de item inexistente.';
END;
$$ LANGUAGE plpgsql;

-- Busca os itens do usuário na sessão
CREATE OR REPLACE FUNCTION list_itens(session_player TEXT) RETURNS 
    TABLE (
        invent_id INT,
        slot_pos SMALLINT,
        item_id BIGINT,
        item_name TEXT
    ) AS $$
DECLARE
	invent_id INTEGER;

BEGIN
	SELECT player.inventario INTO invent_id FROM player where nome = session_player;
	RETURN QUERY SELECT slot.id_inventario, slot.pos, item.id, get_item_name(item.id) FROM slot, item WHERE id_inventario = invent_id AND slot.item = item.id;
END;
$$ LANGUAGE plpgsql;


-- Dropa um item do usuário
CREATE OR REPLACE FUNCTION drop_item(session_player TEXT, pos_item SMALLINT) RETURNS VOID AS $$
DECLARE
	invent_id INTEGER;

BEGIN
	SELECT player.inventario INTO invent_id FROM player where nome = session_player;
	UPDATE slot SET item=NULL WHERE id_inventario = invent_id AND pos=pos_item;
END;
$$ LANGUAGE plpgsql;


-- Cria instancia de batalha entre um player e um npc
CREATE OR REPLACE FUNCTION create_battle_instance(player_ TEXT, npc_ TEXT) RETURNS BIGINT AS $$
DECLARE 
    battle_id BIGINT;
BEGIN
    INSERT INTO instancia_batalha (nome_player, nome_npc) VALUES (player_, npc_)
        RETURNING id INTO battle_id;

    INSERT INTO instancia_inimigo (batalha_id, nome, hp, energia, ataque, defesa, evasao, agilidade, arma, armadura)
        SELECT battle_id, npc.nome, npc.hp, npc.energia, 
        npc.ataque, npc.defesa, npc.evasao, 
        npc.agilidade, npc.arma, npc.armadura 
        FROM npc WHERE npc.nome = npc_;
    
    RETURN battle_id;
END;
$$ LANGUAGE plpgsql;

-- interação de ataque do player
CREATE OR REPLACE FUNCTION player_ataca(player_ TEXT, npc_ TEXT, battle_id BIGINT) RETURNS TEXT AS $$
DECLARE
    ataque_player INT;
    agilidade_player INT;
    arma_id BIGINT;
    ataque_arma INT;
    agilidade_arma INT;
    defesa_npc INT;
    evasao_npc INT;
    armadura_id BIGINT;
    defesa_armadura INT;
    evasao_armadura INT;
    acerto BOOLEAN;
    critico BOOLEAN;
    rand_value INT;
    dano INT;
BEGIN
    -- calcula ataque e agilidade total do player
    SELECT ataque, agilidade, arma INTO ataque_player, agilidade_player, arma_id 
        FROM player WHERE nome=player_;
    IF (arma_id IS NOT NULL) THEN
        SELECT ataque, agilidade INTO ataque_arma, agilidade_arma
            FROM arma WHERE id=arma_id;
        ataque_player := ataque_player + ataque_arma;
        agilidade_player := agilidade_player + agilidade_arma;
    END IF;

    -- calcula defesa e evasao total do npc
    SELECT defesa, evasao, armadura INTO defesa_npc, evasao_npc, armadura_id
        FROM instancia_inimigo WHERE batalha_id = battle_id AND nome = npc_;

    IF (armadura_id IS NOT NULL) THEN
        SELECT defesa, evasao INTO defesa_armadura, evasao_armadura
            FROM armadura WHERE id=armadura_id;
        defesa_npc := defesa_npc + defesa_armadura;
        evasao_npc := evasao_npc + evasao_armadura;
    END IF;

    -- testa se o ataque vai acertar
    IF (agilidade_player <= evasao_npc) THEN
        RETURN player_ || 'errou o ataque';
    END IF;

    rand_value := floor(random() * 10+1);

    IF (rand_value > 8) THEN
        ataque_player := ataque_player * 2;
        critico := TRUE;
    ELSE
        critico := FALSE;
    END IF;

    IF (ataque_player - defesa_npc > 0) THEN
        UPDATE instancia_inimigo SET hp=ataque_player-defesa_npc
            WHERE batalha_id = battle_id AND nome = npc_;
        RETURN player_ || 'causou' || quote_literal(ataque_player-defesa_npc) || 'de dano a' || npc_;
    ELSE
        RETURN player_ || 'causou' || quote_literal(0) || 'de dano a' || npc_;
    END IF;

END;
$$ LANGUAGE plpgsql;

-- interação de ataque do npc
CREATE OR REPLACE FUNCTION npc_ataca(player_ TEXT, npc_ TEXT, battle_id BIGINT) RETURNS TEXT AS $$
DECLARE
    ataque_npc INT;
    agilidade_npc INT;
    arma_id BIGINT;
    ataque_arma INT;
    agilidade_arma INT;
    defesa_player INT;
    evasao_player INT;
    armadura_id BIGINT;
    defesa_armadura INT;
    evasao_armadura INT;
    acerto BOOLEAN;
    critico BOOLEAN;
    rand_value INT;
    dano INT;
BEGIN
    -- calcula ataque e agilidade total do npc
    SELECT ataque, agilidade, arma INTO ataque_npc, agilidade_npc, arma_id 
        FROM instancia_inimigo WHERE batalha_id=battle_id AND nome=npc_;
    IF (arma_id IS NOT NULL) THEN
        SELECT ataque, agilidade INTO ataque_arma, agilidade_arma
            FROM arma WHERE id=arma_id;
        ataque_npc := ataque_npc + ataque_arma;
        agilidade_npc := agilidade_npc + agilidade_arma;
    END IF;

    -- calcula defesa e evasao total do player
    SELECT defesa, evasao, armadura INTO defesa_player, evasao_player, armadura_id
        FROM player WHERE nome=player_;

    IF (armadura_id IS NOT NULL) THEN
        SELECT defesa, evasao INTO defesa_armadura, evasao_armadura
            FROM armadura WHERE id=armadura_id;
        defesa_player := defesa_player + defesa_armadura;
        evasao_player := evasao_player + evasao_armadura;
    END IF;

    -- testa se o ataque vai acertar
    IF (agilidade_npc <= evasao_player) THEN
        RETURN npc_ || 'errou o ataque';
    END IF;

    rand_value := floor(random() * 10+1);

    IF (rand_value > 8) THEN
        ataque_npc := ataque_npc * 2;
        critico := TRUE;
    ELSE
        critico := FALSE;
    END IF;

    IF (ataque_npc - defesa_player > 0) THEN
        UPDATE player SET hp_atual=ataque_npc-defesa_player
            WHERE nome = player_;
        RETURN npc_ || 'causou' || quote_literal(ataque_npc-defesa_player) || 'de dano a' || player_;
    ELSE
        RETURN npc_ || 'causou' || quote_literal(0) || 'de dano a' || player_;
    END IF;

END;
$$ LANGUAGE plpgsql;

-- Deleta as instancias de inimigo e da batalha
CREATE OR REPLACE FUNCTION finish_battle_instance(battle_id BIGINT) RETURNS void AS $$
BEGIN
    DELETE FROM instancia_inimigo WHERE batalha_id=battle_id;
    DELETE FROM instancia_batalha WHERE id=battle_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION enter_area(session_id BIGINT, mapa_ TEXT, area_ TEXT) RETURNS
    TABLE (
        pos_x SMALLINT,
        pos_y SMALLINT,
        area TEXT,
        mapa TEXT
) as $$
DECLARE
    already_created INT;
BEGIN
    SELECT count(*) INTO already_created FROM sessao_quadrado SQ WHERE SQ.sessao=session_id AND SQ.mapa=mapa_ AND SQ.area=area_;

    IF (already_created > 0) THEN
        RETURN QUERY SELECT QT.pos_x, QT.pos_y, QT.area::TEXT, QT.mapa::TEXT FROM quadrado_tipo QT
            WHERE tipo='entrada0' AND QT.mapa=mapa_ AND QT.area=area_;
    END IF;

    INSERT INTO sessao_quadrado (sessao, pos_x, pos_y, area, mapa)
        SELECT session_id, Q.pos_x, Q.pos_y, Q.area, Q.mapa FROM quadrado Q
        WHERE Q.area=area_ AND Q.mapa=mapa_;

    RETURN QUERY SELECT QT.pos_x, QT.pos_y, QT.area::TEXT, QT.mapa::TEXT FROM quadrado_tipo QT
        WHERE QT.tipo='entrada0' AND QT.mapa=mapa_ AND QT.area=area_;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION verifica_tipo_item(session_id BIGINT, slot_pos INT,  
    OUT item_type text, OUT item_id bigint ) RETURNS void AS $$

DECLARE 
    id_inventario int;
    session_player text;
    inventario_id inventario.id%TYPE;
BEGIN

    SELECT sessao.player INTO session_player FROM sessao
        WHERE sessao.id = session_id;

    SELECT player.inventario INTO inventario_id FROM player
        WHERE player.nome = session_player;

    SELECT item.tipo, item.id INTO item_type, item_id FROM inventario, slot, item
        WHERE slot.id_inventario = inventario_id and slot.pos = slot_pos and slot.item = item.id;

END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION equipa_armamento(session_id BIGINT, item_type text, item_id bigint ) RETURNS void AS $$

DECLARE
    session_player text;
    arma player.arma%TYPE;
    armamento equip.tipo%TYPE;

BEGIN

    SELECT sessao.player INTO session_player FROM sessao
        WHERE sessao.id = session_id;

    SELECT equip.tipo INTO armamento FROM equip
        WHERE equip.id = item_id;

    IF (armamento = 'arma') THEN 
        UPDATE player SET arma=item_id WHERE player.nome = session_player;
    ELSIF (armamento = 'armadura') THEN
       PERFORM equipa_armadura (session_player, item_type, item_id);
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION equipa_armadura(session_player TEXT, item_type text, item_id bigint ) RETURNS void AS $$

DECLARE
    armadura player.armadura%TYPE;

BEGIN

    UPDATE player SET armadura=item_id WHERE player.nome = session_player;

END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION desequipa_armamento(session_id BIGINT, armamento text ) RETURNS void AS $$

DECLARE
    session_player text;
    arma player.arma%TYPE;

BEGIN

    SELECT sessao.player INTO session_player FROM sessao
        WHERE sessao.id = session_id;

    IF (armamento = 'arma') THEN 

        UPDATE player SET arma = NULL WHERE player.nome = session_player;

    ELSIF (armamento = 'armadura') THEN
       PERFORM desequipa_armadura (session_player, item_type, item_id);
    END IF;

END;

$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION desequipa_armadura(session_player TEXT, armamento text) RETURNS void AS $$

DECLARE
    armadura player.armadura%TYPE;

BEGIN
    UPDATE player SET armadura = null WHERE player.nome = session_player;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION see_player_status(player_name_ TEXT) RETURNS
    TABLE (
        player_name TEXT,
        hp_max INT,
        hp_current INT,
        energy_max INT,
        energy_current INT,
        player_ataque INT,
        player_defesa INT,
        player_evasao INT,
        player_agilidade INT,
        player_creditos INT,
        player_arma TEXT,
        player_armadura TEXT
    ) AS $$
DECLARE
    arma_id BIGINT;
    armadura_id BIGINT;
BEGIN
    SELECT player.nome, player.hp, player.hp_atual, player.energia,
        player.energia_atual, player.ataque, player.defesa, player.evasao,
        player.agilidade, player.creditos, player.arma, player.armadura
    INTO player_name, hp_max, hp_current, energy_max, energy_current,
        player_ataque, player_defesa, player_evasao, player_agilidade, player_creditos,
        arma_id, armadura_id
    FROM player WHERE player.nome=player_name_;

    IF (arma_id IS NOT NULL) THEN
        SELECT arma.ataque + player_ataque, arma.agilidade + player_agilidade INTO player_ataque, player_agilidade
            FROM arma WHERE arma.id=arma_id;
    END IF;

    IF (armadura_id IS NOT NULL) THEN
        SELECT armadura.defesa + player_defesa, armadura.evasao + player_evasao INTO player_defesa, player_evasao
            FROM armadura WHERE armadura.id=armadura_id;
    END IF;

    player_arma := get_item_name(arma_id);
    player_armadura := get_item_name(armadura_id);

    RETURN QUERY SELECT player_name, hp_max, hp_current, energy_max, energy_current, player_ataque,
        player_defesa, player_evasao, player_agilidade, player_creditos, player_arma, player_armadura;

END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION copy_events(session_id BIGINT) RETURNS void AS $$
BEGIN
    INSERT INTO estado_evento (sessao, evento, desbloqueado, ativo)
        SELECT session_id, id, estado_desbloqueio_inicial, estado_desbloqueio_inicial FROM evento;
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION altera_hp_energia(session_id BIGINT, hp INT, energia INT ) RETURNS TEXT AS $$

DECLARE 
    session_player text;
    inventario_id inventario.id%TYPE;
BEGIN

    SELECT sessao.player INTO session_player FROM sessao
        WHERE sessao.id = session_id;

    UPDATE player SET hp_atual = hp_atual + hp, energia_atual = energia_atual + energia WHERE player.nome = session_player;

    RETURN 'HP e/ou Energia alterada com sucesso!';

END;
$$ LANGUAGE plpgsql;
