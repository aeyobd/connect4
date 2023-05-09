const N_COLS = 7
const N_ROWS = 6


Base.@kwdef mutable struct Gameboard
    turn::Int = 0
    board1::Int64 = 0
    board2::Int64 = 0
    score::Float64 = 0.5
end


function Base.size(board::Gameboard)
    return (N_ROWS, N_COLS)
end

IndexStyle(board::Gameboard) = CartesianIndex()

function _tuple_to_idx(i::Int, j::Int)
    return (i-1)*N_COLS + j - 1
end

function Base.getindex(board::Gameboard, i::Int64, j::Int64)
    idx = _tuple_to_idx(i, j)
    v1 = board.board1 & 1<<idx
    v2 = board.board2 & 1<<idx

    if v1 != 0
        return 1 
    elseif v2 != 0
        return -1
    else
        return 0
    end
end


function Base.setindex!(board::Gameboard, X::Int, i::Int64, j::Int64)
    idx = _tuple_to_idx(i, j)

    if X == 1
        board.board1 |= 1<<idx
        board.board2 ⊻ 1<<idx
    elseif X == -1
        board.board2 |= 1<<idx
        board.board1 ⊻ 1<<idx
    elseif X == 0
        board.board2 ⊻ 1<<idx
        board.board1 ⊻ 1<<idx
    else
        throw(ValueError("value must be -1, 0, +1 for gameboard"))
    end
    print(board.board1)
    print(board.board2)
end



function move!(board::Gameboard, j)
    if !(j in valid_moves(board))
        throw(ValueError("not a valid move"))
    end

    i = column_height(board, j) 
    idx = _tuple_to_idx(i, j)

    if current_player(board) == 1
        board.board1 |= 1 << idx
    elseif current_player(board) == -1
        board.board2 |= 1 << idx
    end

    board.turn += 1
end


function move(gboard::Gameboard, j)
    if !(j in valid_moves(gboard))
        throw(ValueError("not a valid move"))
    end

    i = column_height(gboard, j) 
    board1 = board.board1
    board2 = board.board2

    if current_player(board) == 1
        board1 |= 1 << idx
    elseif current_player(board) == -1
        board2 |= 1 << idx
    end

    return Gameboard(turn=gboard.turn + 1, board1=board1, board2=board2)
end


function column_height(board::Gameboard, j)
    mask = [1<<_tuple_to_idx(i, j) for i in 1:N_ROWS]
    s1 = sum(m & board.board1 > 0 for m in mask)
    s2 = sum(m & board.board2 > 0 for m in mask)
    return s1 + s2 + 1
end


function valid_moves(board::Gameboard)
    mask = [1<<_tuple_to_idx(N_ROWS, j) for j in 1:N_COLS]
    b1 = [m & board.board1 == 0 for m in mask]
    b2 = [m & board.board2 == 0 for m in mask]
    return collect(1:N_COLS)[b1 .&& b2]
end


function current_player(gboard::Gameboard)
    return gboard.turn % 2 == 0 ? 1 : -1
end



function is_won(board::Gameboard)
    if _is_won(board.board1)
        return 1
    elseif _is_won(board.board2)
        return -1
    end

    return 0
end


function _is_won(x::Int64)
    y = x & (x >> 6)
    if (y & (y >> (2 * 6))) > 0
        return true
    end

    # horizontal
    y = x & (x >> 7)
    if (y & (y >> (2 * 7))) > 0
        return true
    end

    #ascending diagonal
    y = x & (x >> 8)
    if (y & (y >> (2 * 8))) > 0
        return true
    end

    # vertical
    y = x & (x >> 1)
    if (y & (y >> (2 * 1))) > 0
        return true
    end

    return false
end



function Base.show(io::IO, gboard::Gameboard)
    println()
    println(io, "-"^11)
    for i in N_ROWS:-1:1
        for j in 1:N_COLS
            val = gboard[i, j]
            if val == 0
                s = " "
            elseif val == 1
                s = "x"
            else
                s = "o"
            end
            print(io, s, " ")
        end
        println()
    end

    println(io, "-------------")
    println(io, "1 2 3 4 5 6 7")
end




