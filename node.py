import copy
from gameboard import N_COLS, N_ROWS

class node:
    def __init__(self, parent, j):
        self.board = copy.deepcopy(parent.board)
        self.board.move(j)
        self.parent = parent

        # redundant, will fix
        self.depth = parent.depth - 1
        self.board.depth = self.depth
            
        self.path = copy.copy(parent.path)
        self.path.append(j)
    
        self.computed_boards = parent.computed_boards

        self.computed_boards.node_count += 1
        # an antinode is evaluating potential moves of other player
        self.antinode = self.board.player_turn == 1

        self.children = []
        self.n_children = len(self.board.valid_moves)

        if N_COLS * N_ROWS - sum(self.board._column_heighths) < 20:
            self.depth = 100

    def evaluate(self):
        # if the game is won, the node ends
        # searched_board = self.computed_boards.find_board(self.board)
        self.score = None
        if self.board.is_won:
            self.score = self.antinode
            self.computed_boards.find_count += 1
        # elif searched_board is not None:
        #     self.score = searched_board.score
        #     self.computed_boards.find_count += 1
        elif self.n_children == 0:
            self.score = 0.5 # game is tied
            self.computed_boards.find_count += 1
        elif self.depth == 0:
            # the default score if evaluation is halted.
            # TODO: use positional arguments to determine a better estimate
            self.computed_boards.end_count += 1
            if self.antinode:
                self.score = 1 - self.calculate_positional_score()
            else:
                self.score = self.calculate_positional_score()
            # self.score = 0.5
        else:
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

            if self.antinode:
                self.score = min([child.score for child in self.children])
                if self.score != 0 and self.score != 1:
                    self.score = (self.score + 1 - self.calculate_positional_score())/2

            else:
                self.score = max([child.score for child in self.children])
                if self.score != 0 and self.score != 1:
                    self.score = (self.score + self.calculate_positional_score())/2

            
        self.board.score = self.score
        self.board.depth = self.depth

        # self.computed_boards.add_board(self.board)
        del self.board
        return self.score

    def add_in_direction(self, ih, jh):
        j0 = self.path[-1]
        i0 = self.board._column_heighths[j0] - 1

        c0 = 0
        l = 0
        s = 0
        for a in range(1, 4):
            i = i0 + a*ih 
            j = j0 + a*jh
            if i < 0 or i >= N_ROWS or \
               j < 0 or j >= N_COLS:
                break
            c = self.board.board[i][j]

            if c0 == 0:
                c0 = c
                s += 1
            elif c != c0:
                break
            l += 1

        return c0, l, s

    def score_in_direction(self, ih, jh):
        c1, l1, s1 = self.add_in_direction(ih, jh)
        c2, l2, s2 = self.add_in_direction(-ih, -jh)
        s = s1 + s2
        l = l1 + l2
        c = c1 == c2 or c1 == 0 or c2 == 0
        score = 0
        if c and (l +1 >= 4):
            return l - s/2
        if l1 + s2 + 1 > 3 and l2 + s1 + 1 > 3:
            score += l - s/2 
        elif l1 + s2 + 1 > 3:
            score += l1 - s1/2 + s2/s
        elif l2 + s1 + 1 > 3:
            score += l2 - s2/2 + s1/s
        return score

    def calculate_positional_score(self):
        """Calculates the effect of the move at the ends of each branch"""
        score = 0
        score += self.score_in_direction(1, 0)
        score += self.score_in_direction(0, 1)
        score += self.score_in_direction(1, 1)
        score += self.score_in_direction(1, -1)
        score = score/20*0.1 + 0.5
        return score

    @property
    def score(self):
        """The score of the node
        The default is 0.5
        A score of 1 means that the computer always wins from this node,
        a score of 0 is when the computer always looses from this node
        Interpreted as the probability of a win from this position.
        """
        return self._score

    @score.setter
    def score(self, value):
        self._score = value


    def __str__(self):
        s = ""
        s += "path = %s\n" % str(self.path)
        if self.score is not None:
            s += "score = %f\n" % self.score
        s += "end count %d\n" % self.computed_boards.end_count
        s += "find count %d\n" % self.computed_boards.find_count
        s += "num nodes %d\n" % self.computed_boards.node_count
        s += "children: [\n"
        for child in self.children:
            s += "\t %s" % (child.path[-1])
            s += ": %1.3f\n" % child.score

        s += "]\n"
        return s

    def __repr__(self):
        return str(self)

