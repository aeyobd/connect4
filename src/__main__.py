
from .game import game
from .gameboard import gameboard
from .parent_node import parent_node
from .computed_boards import computed_boards


def main():
    g = game()

    n = parent_node(g.board, computed_boards(), depth=6)
    n.evaluate()
