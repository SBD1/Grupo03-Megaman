from item import Item

class Player:

    name: str
    inventory: list

    def __init__(self, name):
        self.name = name
        self.inventory = []

    def take_item(self, item:Item):
        self.inventory.append(item)
        print(f"{self.name} took {item.name}")
