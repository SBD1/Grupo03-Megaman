import pygame as pg
# from pygame.locals import *

from grid import Grid
from player import Player
from constants import ColorConst

screen_width = 832
screen_height = 624
screen_size = (screen_width, screen_height)

def create_surface(size: tuple[int, int], 
                    fill_color: pg.Color|None = None) -> pg.Surface:
    surface = pg.Surface(size)
    surface = surface.convert()
    if fill_color:
        surface.fill(fill_color)
        surface.set_alpha(fill_color.a)
    return surface

pg.init()
screen = pg.display.set_mode((screen_width, screen_height), pg.SCALED)

pg.display.set_caption("MEGAMAN")

layer_zero = create_surface(screen.get_size(), fill_color=ColorConst.BLACK)
screen.blit(layer_zero, (0, 0))
pg.display.update()

layer_one_size = (
    int(screen_width * 90 / 100),
    int(screen_height * 90 / 100)
)

layer_one = create_surface(layer_one_size, fill_color=ColorConst.DEFAULT_COLOR)

grid = Grid((50, 50), (10, 10))

clock = pg.time.Clock()
run = True

player = Player("Zero")

while (run):

    for event in pg.event.get():
        if event.type == pg.KEYDOWN:
            if event.key == pg.K_q:
                run = False
            if event.key in [pg.K_DOWN, pg.K_UP, pg.K_LEFT, pg.K_RIGHT]:
                grid.move_character(event.key, player)

    grid.draw_grid(layer_one)
    screen.blit(layer_one, (0, 0))
    
    pg.display.update()
    clock.tick(30)