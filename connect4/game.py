from .gameboard import gameboard, gameboard2
from .parent_node import parent_node
from random import randint
from .computed_boards import computed_boards

class game:
    def __init__(self):
        self.board = gameboard()
        self.computed_boards = computed_boards()
        print("Game has begun")

    def read_move(self):
        while True:
            inp = input("Enter a move\n")
            if len(inp) == 0:
                continue
            m = int(inp)
            if not isinstance(m, int) or m >= 7:
                print("please enter an integer less than 7")
            else:
                self.board.move(m)
                break

    def rand_move(self):
        m = randint(0, len(self.board.valid_moves) - 1)
        self.board.move(self.board.valid_moves[m])

    def computer_move(self):
        node = parent_node(self.board, computed_boards(), max_nodes = self.n_nodes)
        m = node.recommend_move()
        self.board.move(m)


    def start(self, computer_first=False, n_nodes=10_000):
        self.n_nodes = n_nodes
        if computer_first:
            self.board._player_turn = 2
        while not self.board.is_won:
            if self.board.player_turn == 1:
                self.read_move()
            else:
                print("Computer moves")
                self.computer_move()
            print(self.board)
        print("player %d WON!" % (3-self.board._player_turn))

    def start_2player(self):
        while not self.board.is_won:
            print("player %ds turn" % self.board.player_turn)
            self.read_move()
            print(self.board)
        print("player %d WON!" % (3-self.board._player_turn))
