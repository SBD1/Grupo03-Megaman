import pygame as pg
from player import Player

from constants import ColorConst

class Position:
    x: int
    y: int
    rect: pg.Rect    
    color: pg.Color
    visible: bool
    visited: bool
    walkable: bool
    item: object
    lock: object
    events: list[object]

    def __init__(self, x, y, rect: pg.Rect, 
        color: pg.Color = ColorConst.DEFAULT_COLOR, 
        visible: bool = False, visited: bool = False, 
        walkable: bool = True, 
        item=None, 
        lock=None, 
        events=[]
    ):
        self.x = x
        self.y = y
        self.rect = rect
        self.color = color
        self.visible = visible
        self.visited = visited
        self.walkable = walkable
        self.item = item
        self.lock = lock
        self.events = events

    def set_visible(self, visible: bool = True, alpha_mod: int = 0):
        self.visible = visible

    def set_visited(self, visited: bool = True):
        self.visited = visited
        self.color = ColorConst.VISITED_COLOR

    def step_actions(self, player: Player, new_color=ColorConst.DEFAULT_COLOR):
        if self.item:
            player.take_item(self.item)
            self.item = None
            self.color = new_color
            

