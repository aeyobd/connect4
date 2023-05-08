include("gameboard.jl")
include("parent_node.jl")


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


function computer_move!(gboard, max_nodes=10000)
    p_node = ParentNode(gboard=gboard)
    j = recommend_move!(p_node, max_nodes)
    move!(gboard, j)
end


function start_2player()
    gboard = Gameboard()
    while is_won(gboard) == 0
        ply = current_player(gboard) == 1 ? 1 : 2
        println("player $ply turn")
        move = get_move()
        move!(gboard, move)
        println(gboard)
    end

    ply =  is_won(gboard)
    if ply == -1 
        println("player 2 Won")
    elseif  ply == 1 
        println("player 1 won")
    else 
        println("tie?")
    end
end


function start(;computer_first=false, max_nodes=10000)
    gboard = Gameboard()

    if computer_first
        gboard.turn += 1
    end

    while is_won(gboard) == 0
        turn = current_player(gboard)
        if turn == 1
            j = get_move()
            move!(gboard, j)
        else
            println("Computer moves")
            computer_move!(gboard, max_nodes)
        end
        print(gboard)
    end
    ply = is_won(gboard)
    print("player $ply WON!")

end









