-- item
-- equip
-- armadura
-- arma

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

CREATE OR REPLACE FUNCTION update_chave() RETURN TRIGGER AS $update_chave$
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

CREATE TRIGGER update_chave_tg
BEFORE INSERT OR UPDATE OR DELETE ON chave
FOR EACH ROW EXECUTE PROCEDURE update_chave();

