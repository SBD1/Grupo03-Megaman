import pygame as pg
import random

from position import Position
from player import Player
from item import Item
from constants import ColorConst

class Grid:

    def __init__(self, unit_size: tuple[int, int], number_of_squares: tuple[int,int], start_pos=(0, 0)):
        self.draw_start_pos = [0, 0]
        self.grid: list[list[Position]] = [[0]*number_of_squares[1] for _ in range(number_of_squares[0])]
        self.width = number_of_squares[0]
        self.height = number_of_squares[1]

        for i, _ in enumerate(self.grid):
            pos_x = self.draw_start_pos[0]+unit_size[0]*i
            for j, _ in enumerate(self.grid[i]):
                pos_y = self.draw_start_pos[1]+unit_size[1]*j
                self.grid[i][j] = Position(
                    pos_x, pos_y,
                    pg.Rect(pos_x, pos_y, unit_size[0], unit_size[1]),
                    visible=False
                )

        self.current_pos_x = start_pos[0]
        self.current_pos_y = start_pos[1]

        self.set_grid_elements()

    def draw_grid(self, surface: pg.Surface):
        current_color = ColorConst.PLAYER_COLOR
        for i, line in enumerate(self.grid):
            for j, column in enumerate(line):
                if self.current_pos_x == i and self.current_pos_y == j:
                    pg.draw.rect(surface, current_color, column.rect)
                    column.visible = True
                    continue
                if column.visible:
                    pg.draw.rect(surface, column.color, column.rect)

    def set_current_pos(self, x, y):
        self.current_pos_x, self.current_pos_y = (x, y)

    def get_current_pos(self):
        return self.current_pos_x, self.current_pos_y

    def set_grid_elements(self):
        self.grid[2][0].walkable = False
        self.grid[2][0].color = ColorConst.NOWALK_COLOR
        self.grid[2][1].walkable = False
        self.grid[2][1].color = ColorConst.NOWALK_COLOR
        self.grid[2][2].walkable = False
        self.grid[2][2].color = ColorConst.NOWALK_COLOR
        self.grid[2][3].walkable = False
        self.grid[2][3].color = ColorConst.NOWALK_COLOR
        self.grid[4][4].item = Item(1, "energy_capsule")
        self.grid[4][4].color = ColorConst.ITEM_COLOR


    def __next_pos(self, direction_key):
        if direction_key == pg.K_DOWN:
            if self.current_pos_y < self.height - 1:
                return (self.current_pos_x, self.current_pos_y + 1)
        if direction_key == pg.K_UP:
            if self.current_pos_y > 0:
                return (self.current_pos_x, self.current_pos_y - 1)
        if direction_key == pg.K_LEFT:
            if self.current_pos_x > 0:
                return (self.current_pos_x - 1, self.current_pos_y)
        if direction_key == pg.K_RIGHT:
            if self.current_pos_x < self.width-1:
                return (self.current_pos_x + 1, self.current_pos_y)
        return self.current_pos_x, self.current_pos_y

    def move_character(self, direction_key, player: Player):
        x, y = self.__next_pos(direction_key)
        if self.grid[x][y].walkable:
            self.current_pos_x = x
            self.current_pos_y = y
            self.grid[x][y].step_actions(player)
            self.set_visibility_around()
        # else:
        #     self.grid[x][y].set_visible()

    def set_visibility_around(self):
        x, y = self.__next_pos(None)
        self.grid[x][y].set_visible()
        self.grid[x][y].set_visited()
        
        for d in [pg.K_DOWN, pg.K_UP, pg.K_LEFT, pg.K_RIGHT]:
            x, y = self.__next_pos(d)
            self.grid[x][y].set_visible(alpha_mod=0)

    def __repr__(self) -> str:
        return str(self.grid)