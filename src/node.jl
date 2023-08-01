include("board.jl")

const ϵ = 1e-4
F = Float64


Base.@kwdef mutable struct ComputedBoards
    node_count = 0
    node_links = 0
    nodes  = Dict{Tuple{UInt64, UInt64}, F}()
    moves  = Dict{Tuple{UInt64, UInt64}, Int}()
end

Base.@kwdef mutable struct node_state
    α::F
    β::F
    depth::Int
end

function emminant_win(board::Gameboard, moves)
    for j in moves
        if is_won(move(board, j))
            return true
        end
    end
    return false
end


function score(board::Gameboard, depth, α, β, boards)

    k = (board.board1, board.board2)
    if k in keys(boards.nodes)
        return boards.nodes[k], boards.moves[k]
    end

    descend = true
    moves = valid_moves(board)

    if is_tied(board) || length(moves) < 1
        descend = false
        α = 0
    end
    
    if emminant_win(board, moves)
        descend = false
        α =  100 + depth
    end

    if depth < 1
        descend = false
        α = pos_score(board)
    end

    best_move = -1
    if descend
        scores = [pos_score(move(board, j)) for j in moves]
        for i in sortperm(scores, rev=true)
            j = moves[i]
            s = -score(move(board, j), depth-1, -β, -α, boards)[1]
            if s >= β
                α = β
                break
            end
            if s > α
                α = s
                best_move = j
            end
        end
    end

    push!(boards.nodes, k => α)
    push!(boards.moves, k => best_move)

    return α, best_move
end








