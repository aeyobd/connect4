include("board.jl")
include("node.jl")


function get_move(board)
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
        end

        if m in valid_moves(board)
            return m
        else
            print("invalid move: %m")
        end

    end
end


function rand_move!(board)
    moves = valid_moves(board)
    m = rand(Int) % length(moves) + 1
    move!(board, moves[m])
    return m
end


function computer_move!(board, depth=5)
    boards = ComputedBoards()
    s_n, move = score(board, depth, -Inf, Inf, boards)

    println(s_n)
    println(move)
    move!(board, move)
end


function start_2player()
    board = Gameboard()
    while is_won(board) == 0
        ply = current_player(board) == 1 ? 1 : 2
        println("player $ply turn")
        move = get_move()
        move!(board, move)
        println(board)
    end

    ply =  is_won(board)
    if ply == -1 
        println("player 2 Won")
    elseif  ply == 1 
        println("player 1 won")
    else 
        println("tie?")
    end
end


function start(;computer_first=false, depth=5)
    board = Gameboard()

    if computer_first
        board.turn += 1
    end

    while is_won(board) == 0
        turn = current_player(board)
        if turn == 1
            j = get_move(board)
            move!(board, j)
        else
            println("Computer moves")
            computer_move!(board, depth)
        end
        print(board)
    end
    ply = is_won(board)
    print("player $ply WON!")

end









