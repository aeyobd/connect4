N_COLS = 7
N_ROWS = 6
import numpy as np



class gameboard:
    def __init__(self, score=None, depth=None):
        self._board = [[0] * N_COLS for _ in range(N_ROWS)]
        self._column_heighths = [0] * N_COLS
        self._player_turn = 1

    @property
    def valid_moves(self):
        """A list of the valid moves a player can make represented as integers for each column"""
        moves = []
        for j in range(N_COLS):
            if self._board[-1][j] == 0:
                moves.append(j)
        return moves

    @property
    def board(self):
        return self._board

    @property
    def score(self):
        return self._score

    @score.setter
    def score(self, value):
        self._score = value

    @property
    def depth(self):
        return self._depth

    @depth.setter
    def depth(self, value):
        self._depth = value

    @property
    def player_turn(self):
        return self._player_turn

    def move(self, j: int):
        """Makes a move which adds a token in the jth column"""
        if j not in self.valid_moves:
            raise ValueError("Not a valid move")

        i = self._column_heighths[j]
        self._board[i][j] = self.player_turn
        self._column_heighths[j] += 1

        # if player 1 now player 2's turn, vice versa
        self._player_turn = 3 - self.player_turn

    @property
    def is_won(self, player=None):
        """Checks if the game has been won,
        i.e. there is a 4 in a row.

        Parameter
        ---------
        player (int): default=None
            The player to check if they have won the game.
            Defaults to the player who made the last move.
        Returns
        -------
        bool: true if the given player has won the game
        """

        if player is None:
            player = 3 - self.player_turn 
        
        # check rows
        max_series = 0
        for i in range(N_ROWS):
            for j in range(N_COLS):
                if self._board[i][j] == player:
                    max_series += 1
                else:
                    max_series = 0
                if max_series >= 4:
                    return True
            max_series = 0

        # check columns
        max_series = 0
        for j in range(N_COLS):
            for i in range(N_ROWS):
                if self._board[i][j] == player:
                    max_series += 1
                else:
                    max_series = 0
                if max_series >= 4:
                    return True
            max_series = 0

        # check ascending diagonals
        max_series = 0
        for a in range(N_ROWS + N_COLS - 7):
            for b in range([4,5,6,6,5,4][a]):
                i = max(0, a - 3) + b
                j = max(0, 3 - a) + b
                if self._board[i][j] == player:
                    max_series += 1
                else:
                    max_series = 0
                if max_series >= 4:
                    return True
            max_series = 0

        # check descending diagonals
        max_series = 0
        for a in range(N_ROWS + N_COLS - 7):
            for b in range([4,5,6,6,5,4][a]):
                i = min(N_ROWS - 1, a + 3) - b
                j = max(0, a - 2) + b
                if self._board[i][j] == player:
                    max_series += 1
                else:
                    max_series = 0
                if max_series >= 4:
                    return True
            max_series = 0

        # if nothing was true, no 4 in a rows
        return False

    def will_be_won(self):
        # check rows

        # check columns

        # check 
        pass

    def __str__(self):
        s = "-------------\n"
        for i in range(N_ROWS -1, -1, -1):
            for j in range(N_COLS):
                val = self._board[i][j]
                if val == 0:
                    s += " "
                elif val == 1:
                    s += "X"
                else:
                    s += "O"
                s += " "
            s += "\n"
        s += "-------------\n"
        s += "0 1 2 3 4 5 6\n"
        return s

    def __repr__(self):
        return str(self)

    def __eq__(self, other):
        for i in range(N_ROWS):
            for j in range(N_COLS):
                if self._board[i][j] != other._board[i][j]:
                    return False
        return True
    
    def __ne__(self, other):
        return not self == other

    @classmethod
    def from_array(cls, arr):
        c = cls()
        c._board = arr
        c._column_heighths = [0] * N_COLS
        n_moves_1 = 0
        n_moves_2 = 0
        for j in N_COLS:
            for i in N_ROWS:
                if c._board[i][j] != 0:
                    c._column_heighths[j] = i
                n_moves_1 +=  c._board[i][j] == 1
                n_moves_2 +=  c._board[i][j] == 2

        if n_moves_1 == n_moves_2:
            c._player_turn = 1
        elif n_moves_1 == n_moves_2 + 1:
            c._player_turn = 2
        else:
            raise ValueError("Invalid Board")
        return c

    def copy(self):
        return from_array(self._board)

    def __getitem__(self, i):
        return self._board[i]



class gameboard2:
    def __init__(self, score=None, depth=None):
        self._board1 = np.int64(0)
        self._board2 = np.int64(0)
        self._player_turn = 1
        self._column_heighths = [0]*N_COLS

    @property
    def valid_moves(self):
        """A list of the valid moves a player can make represented as integers for each column"""
        l = []
        for j in range(N_COLS):
            if self[5][j] == 0:
                l.append(j)
        return l

    @property
    def score(self):
        return self._score

    @score.setter
    def score(self, value):
        self._score = value

    @property
    def depth(self):
        return self._depth

    @depth.setter
    def depth(self, value):
        self._depth = value

    @property
    def player_turn(self):
        return self._player_turn

    def move(self, j: int):
        """Makes a move which adds a token in the jth column"""
        if j not in self.valid_moves:
            raise ValueError("Not a valid move")

        i = self._column_heighths[j]
        if self.player_turn == 1:
            self._board1 += 1 << (i + 7*j)
        else:
            self._board2 += 1 << (i + 7*j)
        self._column_heighths[j] += 1

        # if player 1 now player 2's turn, vice versa
        self._player_turn = 3 - self.player_turn

    def __getitem__(self, i):
        row1 = self._board1 >> i
        row2 = self._board2 >> i

        l = [0] * N_COLS
        for j in range(N_COLS):
            l[j] += (row1 & (1 << j*7)) > 0
            l[j] += 2 * ((row2 & (1 << j*7))>0)
        return l
    @property
    def is_won(self, player=None):
        """Checks if the game has been won,
        i.e. there is a 4 in a row.

        Parameter
        ---------
        player (int): default=None
            The player to check if they have won the game.
            Defaults to the player who made the last move.
        Returns
        -------
        bool: true if the given player has won the game
        """

        if player is None:
            player = 3 - self.player_turn 
        
        if player == 1:
            x = self._board1
        else:
            x = self._board2

        # downward diagonal
        y = x & (x >> 6)
        if (y & (y >> 2 * 6)):
            return True

        # horizontal
        y = x & (x >> 7)
        if (y & (y >> 2 * 7)):
            return True

        #ascending diagonal
        y = x & (x >> 8)
        if (y & (y >> 2 * 8)):
            return True

        # vertical
        y = x & (x >> 1)
        if (y & (y >> 2 * 1)):
            return True

        return False


    def __str__(self):
        s = "-------------\n"
        for i in range(N_ROWS -1, -1, -1):
            for j in range(N_COLS):
                val = self[i][j]
                if val == 0:
                    s += " "
                elif val == 1:
                    s += "X"
                else:
                    s += "O"
                s += " "
            s += "\n"
        s += "-------------\n"
        s += "0 1 2 3 4 5 6\n"
        return s

    def __repr__(self):
        return str(self)

    def __eq__(self, other):
        return self._boards == other._boards 
    
    def __ne__(self, other):
        return not self == other
