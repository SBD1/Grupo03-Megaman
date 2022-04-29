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

def wait_input(command="voltar"):
    input('Digite "enter" para %s' % command)

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

            cur.execute("SELECT copy_events(%s)", (sessao.session,))

            cur.execute("SELECT * FROM enter_area(%s, %s, %s);", (sessao.session, "MONTANHA NEVADA", "Entrada"))
            cur.fetchone()

            return sessao

        elif option == 2:
            cur.execute("SELECT id, to_char(criado_em, 'DD/MM/YYYY HH24:MI'), player FROM sessao;")
            sessions = cur.fetchall()
            print("Selecione um dos slots (pelo número) ou digite 0 para voltar")
            for i, s in enumerate(sessions, start=1):
                print(f'{i} - {s[2]}    criado em: {s[1]}')
            if len(sessions) == 0:
                print("Nenhum jogo salvo encontrado")
            session_choice = get_int_input("")
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
    if direction == "up" or direction == "u":
        new_pos.y -= 1
    elif direction == "down" or direction == "d":
        new_pos.y += 1
    elif direction == "right" or direction == "r":
        new_pos.x += 1
    elif direction == "left" or direction == "l":
        new_pos.x -= 1
    cur.execute("SELECT * FROM walk_to(%s, %s, %s, %s, %s)", 
        (session.player.nome, new_pos.x, new_pos.y, new_pos.area, new_pos.mapa))

    can_move = cur.fetchone()[0]
    if can_move:
        session.current_pos = new_pos
        cur.execute("SELECT mark_visited(%s, %s, %s, %s, %s)",
            (session.session, session.current_pos.x, session.current_pos.y,
             session.current_pos.area, session.current_pos.mapa))

def show_dialog(cur: 'pg.cursor', session: State, event_id: int):
    cur.execute("""SELECT fala.texto FROM dialogo, fala 
        WHERE id_evento=%s AND fala.id=dialogo.id_fala 
        ORDER BY dialogo.ordem;""", 
        (event_id,))
    falas = cur.fetchall()
    for i in falas:
        print(i[0])        
    wait_input("continuar")

def battle_loop(cur: 'pg.cursor', session: State, event_id: int):
    cur.execute("SELECT id_npc FROM batalha WHERE id_evento=%s", (event_id,))
    against = cur.fetchone()[0]
    
    cur.execute("SELECT * FROM create_battle_instance(%s, %s)", (session.player.nome, against))
    battle_id = cur.fetchone()[0]

    while True:

        command = get_str_input("Selecione a ação\n'atacar', 'item', 'status enemy', 'status player'")
        if command == 'atacar':
            cur.execute("SELECT * FROM player_ataca(%s, %s, %s);",
                (session.player.nome, against, battle_id))
            print(f"\n{cur.fetchone()[0]}")
        
            cur.execute("SELECT * FROM instancia_inimigo WHERE batalha_id=%s AND nome=%s;",
                (battle_id, against))
            instance = cur.fetchone()
            if instance[2] <= 0:
                print(f'{session.player.nome} venceu!!')
                cur.execute("SELECT finish_battle_instance(%s)", (battle_id,))
                return

        elif command == 'item':
            cur.execute("SELECT L.invent_id, L.slot_pos, L.item_id, L.item_name FROM (SELECT * FROM list_itens(%s)) AS L, item WHERE L.item_id=item.id AND item.tipo='consumivel'", (session.player.nome,))
            items = cur.fetchall()

            for i, item in enumerate(items, start=1):
                print(f'{i} - {item[3]}')
            
            action = get_int_input("Digite o número do item que se quer usar ou '0' para sair")
            if action == 0:
                continue

            if action == 0:
                break
            if action > len(items):
                print("Número inválido.")
            
            cur.execute("SELECT modificador_dano, modificador_energia FROM consumivel WHERE id=%s", (items[action-1][2],))
            hp, mp = cur.fetchone()

            cur.execute("SELECT * FROM altera_hp_energia(%s, %s, %s);",
                (session.session, hp, mp))

            print(cur.fetchone()[0])

            cur.execute("SELECT drop_item(%s::TEXT, %s::SMALLINT);",
                (session.player.nome, items[action-1][1]))

        elif command == 'status enemy':
            cur.execute("SELECT * FROM instancia_inimigo WHERE batalha_id=%s AND nome=%s;",
                (battle_id, against))
            instance = cur.fetchone()
            print(f'Nome: {instance[1]}')
            print(f'HP(atual): {instance[2]}')
            print(f'Energia(atual): {instance[3]}')
            print('')
            continue

        elif command == 'status player':
            cur.execute("SELECT * FROM player WHERE player.nome = %s", (session.player.nome,)) 
            player_stats = cur.fetchone()
            print(f'Nome: {player_stats[0]}')
            print(f'HP(atual): {player_stats[3]}')
            print(f'Energia(atual): {player_stats[5]}')
            print('')
            continue

        else:
            continue
        
        cur.execute("SELECT * FROM npc_ataca(%s, %s, %s);",
            (session.player.nome, against, battle_id))
        print(f"\n{cur.fetchone()[0]}")
        print('')

        cur.execute("SELECT * FROM player WHERE player.nome = %s", (session.player.nome,)) 
        player_stats = cur.fetchone()
        if player_stats[3] <= 0:
                print(f'{session.player.nome} venceu!!')
                cur.execute("SELECT finish_battle_instance(%s)", (battle_id,))
                return

def check_and_execute_event(cur: 'pg.cursor', session: State):
    cur.execute("SELECT * FROM get_active_event(%s, %s, %s, %s, %s)",
        (session.current_pos.x, session.current_pos.y, session.current_pos.area,
         session.current_pos.mapa, session.session))
    event_id = cur.fetchone()[0]
    
    if event_id is None or event_id == -1:
        return

    cur.execute("SELECT tipo FROM evento WHERE id=%s", (event_id,))
    event_type = cur.fetchone()[0]

    if event_type == 'd':
        show_dialog(cur, session, event_id)
    elif event_type == 'b':       
        battle_loop(cur, session, event_id)
        

    cur.execute("SELECT unblock_event(%s, %s);", (event_id, session.session))

def check_pos_has_item(cur: 'pg.cursor', session: State):
    pos = session.current_pos
    cur.execute("SELECT item FROM quadrado_item WHERE pos_x=%s AND pos_y=%s AND area=%s AND mapa=%s;", 
        (pos.x, pos.y, pos.area, pos.mapa))
    
    item = cur.fetchone()
    if item is None:
        return
    else:
        item = item[0]
        cur.execute("SELECT item_pego FROM sessao_quadrado WHERE sessao=%s AND pos_x=%s AND pos_y=%s AND area=%s AND mapa=%s", 
            (session.session, pos.x, pos.y, pos.area, pos.mapa))
        taken = cur.fetchone()[0]
        if taken:
            return
        else:
            cur.execute("SELECT * FROM take_item(%s, %s, %s, %s, %s);",
                (pos.mapa, pos.area, pos.x, pos.y, session.session))
            print(cur.fetchone()[0])

def display_status(cur: 'pg.cursor', session: State, show_equip=True):
    cur.execute("SELECT * FROM see_player_status(%s);", (session.player.nome,))
    status = cur.fetchone()

    print(f"-"*20)
    print(f"{status[0]}")
    print('')
    print(f"HP {status[2]}/{status[1]}")
    print(f"MP {status[4]}/{status[3]}")
    print(f"ATK {status[5]} DEF {status[6]}")
    print(f"EVA {status[7]} AGL {status[8]}")

    if show_equip:
        print('')
        print(f"arma: {status[10]}")
        print(f"armadura: {status[11]}")

    print("-"*20)

def inventory_loop(cur: 'pg.cursor', session: State):
    while True:
        cur.execute("SELECT * FROM list_itens(%s)", (session.player.nome,))
        items = cur.fetchall()
    
        for i, item in enumerate(items, start=1):
            print(f'{i} - {item[3]}')
        command = get_int_input("Digite o número do item que se deseja interagir ou '0' para sair do inventário")
        if command == 0:
            break
        if command > len(items):
            print("Número inválido.")
        else:
            cur.execute("SELECT * FROM verifica_tipo_item(%s, %s);",
                (session.session, items[command-1][1]))
            tipo, item_id = cur.fetchone()
            
            if tipo == 'equip':
                action = get_str_input("Digite a ação desejada para o item\nAções disponíveis: 'equip', 'drop'")
                if action == 'equip':
                    cur.execute("SELECT equipa_armamento(%s, %s, %s);", 
                        (session.session, tipo, item_id))
                elif action == 'drop':
                    confirm = get_str_input("O item não poderá ser recuperado. Tem certeza que deseja descartá-lo? (y/n)")
                    if confirm in ['yes', 'y']:
                        cur.execute("SELECT drop_item(%s::TEXT, %s::SMALLINT);",
                            (session.player.nome, items[command-1][1]))
                    elif confirm in ['no', 'n']:
                        continue
                    else:
                        print("opção inválida.")

            elif tipo == 'consumivel':
                action = get_str_input("Digite a ação desejada para o item\nAções diponíveis: 'use', 'drop'")
                if action == 'use':
                    cur.execute("SELECT modificador_dano, modificador_energia FROM consumivel WHERE id=%s", (item_id,))
                    hp, mp = cur.fetchone()

                    cur.execute("SELECT * FROM altera_hp_energia(%s, %s, %s);",
                        (session.session, hp, mp))

                    print(cur.fetchone()[0])

                    cur.execute("SELECT drop_item(%s::TEXT, %s::SMALLINT);",
                        (session.player.nome, items[command-1][1]))

                elif action == 'drop':
                    confirm = get_str_input("O item não poderá ser recuperado. Tem certeza que deseja descartá-lo? (y/n)")
                    if confirm in ['yes', 'y']:
                        cur.execute("SELECT drop_item(%s::TEXT, %s::SMALLINT);",
                            (session.player.nome, items[command-1][1]))
                    elif confirm in ['no', 'n']:
                        continue
                    else:
                        print("opção inválida.")

def menu(cur: 'pg.cursor', session: State):
    while True:
        display_status(cur, session)
        command = get_str_input("")
        if command in ["quit", "exit"]:
            break
        elif command == "inventory" or command == 'i':
            inventory_loop(cur, session)

        elif command == "describe weapon":
            cur.execute("SELECT arma FROM (SELECT player.arma as wid FROM player WHERE nome=%s) as W, arma WHERE arma.id=W.wid;", 
                (session.player.nome, ))
            print(cur.fetchone())
            wait_input()

        elif command == "unequip weapon":
            cur.execute("SELECT desequipa_armamento(%s, %s);",
                (session.session, 'arma'))

        elif command == "describe armor":
            cur.execute("SELECT armadura FROM (SELECT player.armadura as aid FROM player WHERE nome=%s) as A, armadura WHERE armadura.id=A.aid;", 
                (session.player.nome, ))
            print(cur.fetchone())
            wait_input()

        elif command == "unequip armor":
            cur.execute("SELECT desequipa_armamento(%s, %s);",
                (session.session, 'armadura'))

        elif command == "help" or command == "h":
            print("Comandos no menu:")
            print("'help' | 'h'\t mostra os comandos disponíveis")
            print("'exit  | quit'\t saí do menu")
            print("'inventory' | 'i'\t vai para o menu de inventário")
            print("'describe weapon'\t mostra informações da arma equipada")
            print("'unequip weapon'\t desequipa arma")
            print("'describe armor'\t mostra informações da armadura equipada")
            print("'unequip armor'\t desequipa armadura")
            wait_input()

def game_loop(cur: 'pg.cursor', session: State):
    move_to(cur, session, 'stay')
    while True:
        draw_map(cur, session)
        command = get_str_input("")
        if command in ["up", "u", "down", "d", "left", "l", "right", "r"]:
            move_to(cur, session, command)
            check_and_execute_event(cur, session)
            check_pos_has_item(cur, session)
        elif command == "menu" or command == "m":
            menu(cur, session)
        elif command in ['quit', 'q']:
            commit()
            close_all()
            return
        elif command == "help" or command == "h":
            print("Comandos:")
            print("'help' | 'h'\t mostra os comandos disponíveis")
            print("'up'   | 'u'\t move o personagem pra frente")
            print("'down' | 'd'\t move o personagem pra trás")
            print("'right'| 'r'\t move o personagem pra direita")
            print("'left' | 'l'\t move o personagem pra esquerda")
            print("'menu' | 'm'\t mostra os status do personagem e habilita acesso ao inventário e equipamentos")
            print("'quit' | 'q'\t sai do jogo")
            wait_input()
        commit()

if __name__ == "__main__":
    try:
        cur = get_cursor()

        print("\n ------- MEGAMAN SBD ---------\n")

        session: State = get_or_create_session(cur)
        # print(session.session, session.player.nome, session.player.inventario)
        commit()
        
        cur.execute("""SELECT QT.pos_x, QT.pos_y, QT.area::TEXT, QT.mapa::TEXT FROM quadrado_tipo QT
            WHERE QT.tipo='entrada0' AND QT.mapa=%s AND QT.area=%s;""",
            ('MONTANHA NEVADA', 'Entrada'))
        start_pos = cur.fetchone()
        session.current_pos = Position(*start_pos)

        game_loop(cur, session)
    
    except Exception as e:
        close_all()
        raise e
    else:
        close_all()