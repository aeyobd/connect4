from .node import node
from .gameboard import N_COLS, N_ROWS

class parent_node(node):
    def __init__(self, board, computed_boards, depth = 7):
        self.n_children = len(board.valid_moves)
        self.board = board
        self.children = []
        self.path = []
        self.antinode = False
        self.depth = depth + (self.n_children - 7)
        self.computed_boards = computed_boards
        self.computed_boards.end_count = 0
        self.computed_boards.node_count = 0

        if N_COLS * N_ROWS - sum(self.board._column_heighths) < 15:
            self.depth = 20
        if self.n_children < 5:
            self.depth = 24
        if self.n_children == 5:
            self.depth = 10

    def recommend_move(self):
        self.evaluate()
        max_score = -1
        for child in self.children:
            if child.score > max_score:
                max_score = child.score
                best_move = child.path[0]

        print(self)
        print("computer calculates %i with score %f" % (best_move, max_score))
        return best_move

    def evaluate(self):
        for m in self.board.valid_moves:
            child = node(self, m)
            child.evaluate()

            self.children.append(child)

            # trimming the tree
            if child.score == 0:
                if self.antinode:
                    self.score = 0
                    break

            if child.score == 1:
                if not self.antinode:
                    self.score = 1
                    break

        self.score = max([child.score for child in self.children])

