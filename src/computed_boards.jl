
include("gameboard.jl")


Base.@kwdef mutable struct ComputedBoards
    node_count = 0
end


# H = 42
# L = 2**7 * 0
#     def find_board(self, in_board):
#         i = sum(in_board._column_heighths)
#         j = 0
#         for m in range(7):
#             j += 2**m * (in_board.board[0][m] > 0)
#         for b in self.boards[i*L + j]:
#             if b == in_board:
#                 if b.score != 0.5:
#                     return b 
#                 if b.depth >= in_board.depth:
#                     return b
#         return None
# 
#     def add_board(self, board):
#         i = sum(board._column_heighths)
#         j = 0
#         for m in range(7):
#             j += 2**m * (board.board[0][m] > 0)
#         self.boards[i*L + j].append(board)
#     end
