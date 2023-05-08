const N_COLS = 7
const N_ROWS = 6


Base.@kwdef mutable struct Gameboard
    turn::Int = 0
    board = zeros(Int, N_ROWS, N_COLS)
end


function move!(gboard::Gameboard, j)
    if !(j in valid_moves(gboard))
         error("not a valid move")
    end

    i = column_height(gboard, j) 
    gboard.board[i,j] = current_player(gboard)
    gboard.turn += 1
end


function move(gboard::Gameboard, j)
    if !(j in valid_moves(gboard))
         error("not a valid move")
    end

    i = column_height(gboard, j) 
    board = copy(gboard.board)
    board[i, j] = current_player(gboard)

    return Gameboard(gboard.turn + 1, board)
end


function column_height(gboard::Gameboard, j)
    return argmin(gboard.board[:,j])
end


function valid_moves(gboard::Gameboard)
    return collect(1:N_COLS)[gboard.board[end, :] .== 0]
end


function current_player(gboard::Gameboard)
    return gboard.turn % 2 == 0 ? 1 : 2
end



function is_won(gboard::Gameboard)
    board = gboard.board
    rows, cols = size(board)

    # Check horizontal lines
    for i in 1:rows
        for j in 1:(cols - 3)
            if board[i, j] != 0 &&
               board[i, j] == board[i, j + 1] &&
               board[i, j] == board[i, j + 2] &&
               board[i, j] == board[i, j + 3]
               return board[i, j]
            end
        end
    end

    # Check vertical lines
    for i in 1:(rows - 3)
        for j in 1:cols
            if board[i, j] != 0 &&
               board[i, j] == board[i + 1, j] &&
               board[i, j] == board[i + 2, j] &&
               board[i, j] == board[i + 3, j]
               return board[i, j]
            end
        end
    end

    # Check diagonal lines from bottom left to top right
    for i in 1:(rows - 3)
        for j in 1:(cols - 3)
            if board[i, j] != 0 &&
               board[i, j] == board[i + 1, j + 1] &&
               board[i, j] == board[i + 2, j + 2] &&
               board[i, j] == board[i + 3, j + 3]
               return board[i, j]
            end
        end
    end

    # Check diagonal lines from top left to bottom right
    for i in 4:rows
        for j in 1:(cols - 3)
            if board[i, j] != 0 &&
               board[i, j] == board[i - 1, j + 1] &&
               board[i, j] == board[i - 2, j + 2] &&
               board[i, j] == board[i - 3, j + 3]
               return board[i, j]
            end
        end
    end

    return 0
end



function Base.show(io::IO, gboard::Gameboard)
    println()
    println(io, "-"^11)
    for i in N_ROWS:-1:1
        for j in 1:N_COLS
            val = gboard.board[i,j]
            if val == 0
                s = " "
            elseif val == 1
                s = "X"
            else
                s = "O"
            end
            print(io, s, " ")
        end
        println()
    end

    println(io, "-------------")
    println(io, "1 2 3 4 5 6 7")
end




