from locale import currency
import psycopg2 as pg
import queries as query
from postgres_handler import get_cursor, close_all, commit

class Player:
    nome: str
    inventario: int

class Position:
    x: int
    y: int
    area: str
    mapa: str

    def __init__(self, x, y, area, mapa):
        self.x = x
        self.y = y
        self.area = area
        self.mapa = mapa

    def __repr__(self):
        return f'{self.x}, {self.y}, {self.area}, {self.mapa}'

class State:
    session: int
    player: Player
    current_pos: Position

def get_int_input(text: str):
    if text != '':
        print(text)
    return int(input('> ').strip())

def get_str_input(text: str):
    if text != '':
        print(text)
    return input('> ').strip()

def draw_map(cur: 'pg.cursor', session: State):
    current_pos = session.current_pos
    cur.execute("SELECT largura, altura FROM area WHERE mapa=%s AND nome=%s", 
        (current_pos.mapa, current_pos.area))
    largura, altura = cur.fetchone()

    grid = dict()
    cur.execute("SELECT pos_x, pos_y, visitado FROM sessao_quadrado WHERE sessao=%s AND area=%s AND mapa=%s",
        (session.session, current_pos.area, current_pos.mapa))

    for x, y, visited in cur.fetchall():
        grid[(x, y)] = visited

    print('')
    for line in range(1, altura+1):
        line_str = ["x"] * altura
        for column in range(1, largura+1):
            if grid.get((column, line)):
                if current_pos.y == line and current_pos.x == column:
                    line_str[column-1] = "@"     
                else:
                    line_str[column-1] = "#"
        print("".join(line_str))
    print('')

def get_or_create_session(cur: 'pg.cursor') -> State:
    while True:
        option: int = get_int_input("1 - New Game\n2 - Load Game")
        if option == 1:
            # cria sessao
            name = get_str_input("Digite o nome do personagem")
            cur.execute(query.insert_player, (name,))
            invent_id = cur.fetchone()
            cur.execute(query.create_session, (name,))
            session_id = cur.fetchone()

            player = Player()
            player.inventario = invent_id[0]
            player.nome = name

            sessao = State()
            sessao.session = session_id[0]
            sessao.player = player

            return sessao

        elif option == 2:
            cur.execute("SELECT id, to_char(criado_em, 'DD/MM/YYYY HH24:MI'), player FROM sessao;")
            sessions = cur.fetchall()
            for i, s in enumerate(sessions, start=1):
                print(f'{i} - {s[2]}    criado em: {s[1]}')
            session_choice = get_int_input("Selecione um dos slots ou digite 0 para voltar")
            if session_choice == 0:
                continue
            if session_choice <= len(sessions):
                session = State()
                session.session = sessions[session_choice-1][0]
                
                cur.execute("SELECT player.nome, player.inventario FROM player, sessao WHERE sessao.id=%s AND player.nome=sessao.player;", (session.session,))
                player = Player()
                player_data = cur.fetchone()
                player.nome = player_data[0]
                player.inventario = player_data[1]

                session.player = player
                return session
            else:
                print("Opção inválida.")
        else:
            print('Opção inexistente')

def move_to(cur: 'pg.cursor',session: State, direction: str):
    current_pos = session.current_pos
    new_pos = Position(current_pos.x, current_pos.y, current_pos.area, current_pos.mapa)
    if direction == "up":
        new_pos.y -= 1
    elif direction == "down":
        new_pos.y += 1
    elif direction == "right":
        new_pos.x += 1
    elif direction == "left":
        new_pos.x -= 1
    cur.execute("SELECT * FROM walk_to(%s, %s, %s, %s, %s)", 
        (session.player.nome, new_pos.x, new_pos.y, new_pos.area, new_pos.mapa))

    can_move = cur.fetchone()[0]
    if can_move:
        session.current_pos = new_pos
        cur.execute("SELECT mark_visited(%s, %s, %s, %s, %s)",
            (session.session, session.current_pos.x, session.current_pos.y,
             session.current_pos.area, session.current_pos.mapa))

def game_loop(cur: 'pg.cursor', session: State):
    move_to(cur, session, 'stay')
    while True:
        draw_map(cur, session)
        command = get_str_input("")
        if command in ["up", "down", "left", "right"]:
            move_to(cur, session, command)
        elif command == "items":
            ...
        elif command == "status":
            ...
        elif command == "look_around":
            ...
        elif command == "take item":
            ...
        elif command == "help":
            ...
        

if __name__ == "__main__":
    try:
        cur = get_cursor()
        session: State = get_or_create_session(cur)
        print(session.session, session.player.nome, session.player.inventario)
        commit()

        cur.execute("SELECT * FROM enter_area(%s, %s, %s);", (session.session, "MONTANHA NEVADA", "Entrada"))
        start_pos = cur.fetchone()
        session.current_pos = Position(*start_pos)
        
        print(start_pos)

        game_loop(cur, session)
    
    except Exception as e:
        close_all()
        raise e
    else:
        close_all()