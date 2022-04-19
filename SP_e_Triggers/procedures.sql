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
        INSERT INTO fala (texto) VALUES (fala_) RETURNING id INTO fala_id;
        INSERT INTO dialogo (id_evento, id_fala, ordem) VALUES (event_id, fala_id, i);
        i := i + 1;
    END LOOP;
    RETURN event_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION check_quad_is_walkable(x INT, y INT, area_ TEXT, mapa_ TEXT) RETURNS BOOLEAN AS $$
DECLARE
    num_records INT;
BEGIN
    SELECT count(*) INTO num_records FROM quadrado Q WHERE Q.pos_x = x AND Q.pox_y = y AND Q.area = area_ AND Q.mapa = mapa_;
    IF (num_records == 0) THEN
        RETURN FALSE;
    END IF;
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

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
    END IF;

    is_barrier := TRUE;

    -- Pega o id da chave necessária pra desbloquear o quadrado
    SELECT D.chave INTO chave_id FROM destranca D WHERE D.pos_x = x AND D.pos_y = y
        AND D.area = area_ AND D.mapa = mapa_;

    IF (chave_id == -1 OR chave_id IS NULL) THEN
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

    SELECT check_quad_barrier(player_, x, y, area_, mapa_) INTO is_barrier, is_barrier_blocked;

    IF (is_barrier = FALSE) THEN
        RETURN TRUE;
    END IF;

    IF (is_barrier_blocked = TRUE) THEN
        RETURN FALSE;
    END IF;

    RETURN TRUE;
    
END;
$$ LANGUAGE plpgsql;

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
            FROM estado_quadrado ST
            WHERE ST.evento = rec.evento AND ST.sessao = sessao_;
        
        IF (e_desbloqueado AND e_ativo) THEN
            RETURN rec.evento;
        END IF;
    END LOOP;
    RETURN -1;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION unblock_event(event_id BIGINT, session_ BIGINT) RETURNS void AS $$
DECLARE
    rec record;
BEGIN
    UPDATE estado_evento SET desbloqueado=TRUE, ativo=TRUE WHERE evento=event_id AND sessao=session_;
    FOR rec in SELECT * FROM event_chain WHERE evento_a = event_id
    LOOP
        UPDATE estado_evento SET desbloquado=TRUE WHERE sessao=session_ AND evento=rec.evento_b;
    END LOOP;
END;
$$ LANGUAGE plpgsql;


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


-- Busca os itens do usuário na sessão
CREATE OR REPLACE FUNCTION list_itens(session_player TEXT) RETURNS SETOF slot AS $$
DECLARE
	invent_id INTEGER;

BEGIN
	SELECT player.inventario INTO invent_id FROM player where nome = session_player;
	RETURN QUERY SELECT * FROM slot WHERE id_inventario = invent_id;
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