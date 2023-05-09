const N_COLS = 7
const N_ROWS = 6


Base.@kwdef mutable struct Gameboard
    turn::Int = 0
    board1::UInt64 = 0
    board2::UInt64 = 0
    score::Float64 = 0.5
end


function Base.size(board::Gameboard)
    return (N_ROWS, N_COLS)
end

IndexStyle(board::Gameboard) = CartesianIndex()

function _tuple_to_idx(i::Int, j::Int)
    return (i-1)*(N_COLS+1) + j - 1
end

function Base.getindex(board::Gameboard, i::Integer, j::Integer)
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


function Base.setindex!(board::Gameboard, X::Int, i::Integer, j::Integer)
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


function move(board::Gameboard, j)
    if !(j in valid_moves(board))
        throw(ValueError("not a valid move"))
    end

    i = column_height(board, j) 
    idx = _tuple_to_idx(i, j)
    board1 = board.board1
    board2 = board.board2

    if current_player(board) == 1
        board1 |= 1 << idx
    elseif current_player(board) == -1
        board2 |= 1 << idx
    end

    return Gameboard(turn=board.turn + 1, board1=board1, board2=board2)
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

function is_tied(board::Gameboard)
    mask = sum(1<<_tuple_to_idx(6, j) for j in 1:7)
    c = mask == mask & (board.board1 | board.board2)
    return c
end


function _is_won(x::UInt64)
    for q in [7,8,9,1]
        y = x & (x >>> q)
        if (y & (y >>> (2 * q))) > 0
            return true
        end
    end

    return false
end



function Base.show(io::IO, gboard::Gameboard)
    fgcolor = "\u001b[38;5;8m"
    colorclear = "\u001b[0m"
    println(io)
    println(io, fgcolor, "┌───┬───┬───┬───┬───┬───┬───┐", colorclear)

    for i in reverse(1:N_ROWS)
        print(io, fgcolor, "│ ", colorclear)
        for j in 1:N_COLS
            val = gboard[i, j]
            if val == 0
                s = " "
            elseif val == 1
                s = "\u001b[31mX\u001b[0m"
            else
                s = "\u001b[34mO\u001b[0m"
            end
            print(io, s, fgcolor, " │ ", colorclear)
        end
        println(io)
        if i != 1
            println(io, fgcolor, "├───┼───┼───┼───┼───┼───┼───┤", colorclear)
        end
    end

    println(io, fgcolor, "└───┴───┴───┴───┴───┴───┴───┘", colorclear)
    println(io, "  1   2   3   4   5   6   7 ")
end


BOARD_MASK = sum(1 << _tuple_to_idx(i, j) for i in 1:N_ROWS, j in 1:N_COLS)



function pos_score(board::Gameboard, i, j)
    score = 0

    # count whitespace for each player and see
    # how many points...
    b1 = board.board1 & (~board.board2)
    b2 = board.board2 & (~board.board1)
    b0 = (~board.board2) & (~board.board1) & BOARD_MASK

    s1 = _pos_score(b1, i, j)
    s2 = _pos_score(b2, i, j)
    s0 = _pos_score(b0, i, j)

    return 1/4*(s1 + s2 - s0) + 0.5
end



function _pos_score(x::UInt64, i, j)
    score = 0
    for q in [7,8,9,1]
        scorel = 0
        scorer = 0

        for l in 1:3
            yl = x
            yr = x
            for _ in 1:l
                yl &= (x >> (q*l))
                yr &= (x << (q*l))
            end
            if yl > 0
                scorel = l
            end
            if yr > 0
                scorer = l
            end
        end

        score += scorel + scorer
    end

    return (score - 12)/24
end

