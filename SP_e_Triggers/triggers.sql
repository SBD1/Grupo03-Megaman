-- consumivel

CREATE OR REPLACE FUNCTION update_consumivel() RETURNS trigger AS $update_consumivel$
DECLARE
    id_item consumivel.id%TYPE;
BEGIN
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO item (tipo) VALUES ('consumivel') RETURNING id INTO id_item;
        NEW.id := id_item;
        RETURN NEW;
    ELSIF (TG_OP = 'UPDATE') THEN
        IF (NEW.id != OLD.id) THEN
            RAISE EXCEPTION 'Proibido modificar o id';
        END IF;
    ELSIF (TG_OP = 'DELETE') THEN
        DELETE FROM item WHERE id = OLD.id;
        RETURN OLD;
    END IF;
    RETURN NEW;
END;
$update_consumivel$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_consumivel_tg ON consumivel;

CREATE TRIGGER update_consumivel_tg
BEFORE INSERT OR UPDATE OR DELETE ON consumivel
FOR EACH ROW EXECUTE PROCEDURE update_consumivel();

-- chave

CREATE OR REPLACE FUNCTION update_chave() RETURNS TRIGGER AS $update_chave$
DECLARE
    id_item chave.id%TYPE;
BEGIN
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO item (tipo) VALUES ('chave') RETURNING id INTO id_item;
        NEW.id := id_item;
        RETURN NEW;
    ELSIF (TG_OP = 'UPDATE') THEN
        IF (NEW.id != OLD.id) THEN
            RAISE EXCEPTION 'Proibido modificar o id';
        END IF;
    ELSIF (TG_OP = 'DELETE') THEN
        DELETE FROM item WHERE id = OLD.id;
        RETURN OLD;
    END IF;
    RETURN NEW;
END;
$update_chave$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_chave_tg ON chave;

CREATE TRIGGER update_chave_tg
BEFORE INSERT OR UPDATE OR DELETE ON chave
FOR EACH ROW EXECUTE PROCEDURE update_chave();

-- arma

CREATE OR REPLACE FUNCTION update_arma() RETURNS TRIGGER AS $update_arma$
DECLARE
    id_item arma.id%TYPE;
BEGIN
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO item (tipo) VALUES ('equip') RETURNING id INTO id_item;
        INSERT INTO equip (id, tipo) VALUES (id_item, 'arma');
        NEW.id := id_item;
        RETURN NEW;
    ELSIF (TG_OP = 'UPDATE') THEN
        IF (NEW.id != OLD.id) THEN
            RAISE EXCEPTION 'Proibido modificar o id';
        END IF;
    ELSIF (TG_OP = 'DELETE') THEN 
        DELETE FROM item WHERE id = OLD.id;
        DELETE FROM equip WHERE id = OLD.id;
        RETURN OLD;
    END IF;
    RETURN NEW;
END;
$update_arma$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_arma_tg ON arma;

CREATE TRIGGER update_arma_tg
BEFORE INSERT OR UPDATE OR DELETE ON arma
FOR EACH ROW EXECUTE PROCEDURE update_arma();


-- armadura

CREATE OR REPLACE FUNCTION update_armadura() RETURNS TRIGGER AS $update_armadura$
DECLARE
    id_item armadura.id%TYPE;
BEGIN
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO item (tipo) VALUES ('equip') RETURNING id INTO id_item;
        INSERT INTO equip (id, tipo) VALUES (id_item, 'armadura');
        NEW.id = id_item;
        RETURN NEW;
    ELSIF (TG_OP = 'UPDATE') THEN
        IF (NEW.id != OLD.id) THEN
            RAISE EXCEPTION 'Proibido modificar o id';
        END IF;
    ELSIF (TG_OP = 'DELETE') THEN
        DELETE FROM item WHERE id = OLD.id;
        DELETE FROM equip WHERE id = OLD.id;
        RETURN OLD;
    END IF;
    RETURN NEW;
END;
$update_armadura$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_armadura_tg ON armadura;

CREATE TRIGGER update_armadura_tg
BEFORE INSERT OR UPDATE OR DELETE ON armadura
FOR EACH ROW EXECUTE PROCEDURE update_armadura();

CREATE OR REPLACE FUNCTION check_quadrado_evento() RETURNS TRIGGER AS $check_quadrado_evento$
DECLARE
    is_event_type INT;
BEGIN
    SELECT count(*) FROM quadrado_tipo Q WHERE NEW.pos_x = Q.pos_x AND NEW.pos_y = Q.pos_y
        AND NEW.area = Q.area AND NEW.mapa = Q.mapa AND Q.tipo = 'evento' INTO is_event_type;

    IF (is_event_type != 1) THEN
        RAISE EXCEPTION 'quadrado não é do tipo evento';
    END IF;

    RETURN NEW;
END;
$check_quadrado_evento$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS check_quad_ev_tg ON quadrado_evento;

CREATE TRIGGER check_quad_ev_tg
BEFORE INSERT ON quadrado_evento
FOR EACH ROW EXECUTE PROCEDURE check_quadrado_evento();



-- player
-- TODO criar um parecido para npc
-- Atualizar tabela personagem automaticamente quando modifica player
CREATE OR REPLACE FUNCTION update_player() RETURNS TRIGGER AS $update_player$

BEGIN
	IF (TG_OP = 'INSERT') THEN
		INSERT INTO personagem(nome, tipo) VALUES (NEW.nome, 'player');
		RETURN NEW;
	ELSIF (TG_OP = 'UPDATE') THEN
		IF(NEW.nome != OLD.nome) THEN
			RAISE EXCEPTION 'Proibido modificar o nome';
		END IF;
	ELSIF (TG_OP = 'DELETE') THEN
		DELETE FROM personagem WHERE nome = OLD.nome;
		RETURN OK;
	END IF;
	RETURN NEW;
END;
$update_player$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_player_tg ON player;

CREATE TRIGGER update_player_tg
	AFTER INSERT OR UPDATE OR DELETE ON player
	FOR EACH ROW
	EXECUTE PROCEDURE update_player();



-- Atualiza inventário automaticamente de acordo com o player
CREATE OR REPLACE FUNCTION update_inventario_player() RETURNS TRIGGER AS $update_inventario_player$
DECLARE
	id_invent inventario.id%TYPE;
BEGIN
	IF (TG_OP = 'INSERT') THEN
		INSERT INTO inventario(tamanho) VALUES (30) RETURNING id INTO id_invent;
		NEW.inventario := id_invent;
		RETURN NEW;
	ELSIF (TG_OP = 'UPDATE') THEN
		IF(NEW.inventario != OLD.inventario) THEN
			RAISE EXCEPTION 'Proibido modificar o id';
		END IF;
	ELSIF (TG_OP = 'DELETE') THEN
		DELETE FROM inventario WHERE id = OLD.inventario;
		RETURN OK;
	END IF;
	RETURN NEW;
END;
$update_inventario_player$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_inventario_player_tg ON player;

CREATE TRIGGER update_inventario_player_tg
	BEFORE INSERT OR UPDATE OR DELETE ON player
	FOR EACH ROW
	EXECUTE PROCEDURE update_inventario_player();



-- atualiza slots de acordo com mudanças nos inventários
CREATE OR REPLACE FUNCTION update_slots_inventario() RETURNS TRIGGER AS $update_slots_inventario$
BEGIN
	IF (TG_OP = 'INSERT') THEN
		INSERT INTO slot(id_inventario, pos)	
		SELECT NEW.id, generate_series(1, NEW.tamanho);
		RETURN NEW;
	ELSIF (TG_OP = 'UPDATE') THEN
		IF(NEW.id != OLD.id) THEN
			RAISE EXCEPTION 'Proibido modificar o id';
		END IF;
	ELSIF (TG_OP = 'DELETE') THEN
		DELETE FROM slot WHERE id_inventario = OLD.id;
		RETURN OK;
		END IF;
	RETURN NEW;
END;
$update_slots_inventario$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_slots_inventario_tg ON player;

CREATE TRIGGER update_slots_inventario_tg
	AFTER INSERT OR UPDATE OR DELETE ON inventario
	FOR EACH ROW
	EXECUTE PROCEDURE update_slots_inventario();
