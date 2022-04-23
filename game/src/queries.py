insert_player = "INSERT INTO player (nome) VALUES (%s) RETURNING inventario"
create_session = "INSERT INTO sessao (player) VALUES (%s) RETURNING id"
