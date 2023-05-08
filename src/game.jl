include("gameboard.jl")
# include("parent_node.jl")


function get_move()
    while true
        println("Enter a move")
        inp = readline()
        if length(inp) == 0
            continue
        end

        m = 0
        try
            m = parse(Int, inp)
            if m >= 8 || m <= 0 
                throw(ArgumentError)
            end
        catch ArgumentError
            println("must enter a digit between 0 and 6")
        else
            return m
        end

    end
end


function rand_move!(gboard)
    moves = valid_moves(gboard)
    m = rand(Int) % length(moves) + 1
    move!(gboard, moves[m])
    return m
end

function computer_move!(gboard)
    node = parent_node(self.board, computed_boards(), max_nodes = self.n_nodes)
    m = node.recommend_move()
    self.board.move(m)
end


function start_2player()
    gboard = Gameboard()
    while is_won(gboard) == 0
        println("player $(current_player(gboard)) turn")
        move = get_move()
        move!(gboard, move)
        println(gboard)
    end

    ply = is_won(gboard)
    print("player $ply WON!")
end


#     def start(self, computer_first=False, n_nodes=10_000):
#         self.n_nodes = n_nodes
#         if computer_first:
#             self.board._player_turn = 2
#         while not self.board.is_won:
#             if self.board.player_turn == 1:
#                 self.read_move()
#             else:
#                 print("Computer moves")
#                 self.computer_move()
#             print(self.board)
#         print("player %d WON!" % (3-self.board._player_turn))

