include("gameboard.jl")
include("computed_boards.jl")

abstract type ANode end

Base.@kwdef mutable struct Node <: ANode
    gboard::Gameboard

    parent::Union{ANode, Nothing} = Nothing
    children::Vector{Node} = []
    depth::Int = 0

    terminal::Bool = false
    antinode::Bool

    last_move::Int = 0

    score::Float64 = 0.5
    has_children = false
    computed_boards = nothing
end


function Node(parent, j)
    gboard = move(parent.gboard, j)
    depth = parent.depth + 1

    antinode = !parent.antinode

    return Node(;gboard=gboard, parent=parent, depth=depth, 
                last_move=j, antinode=antinode, computed_boards=parent.computed_boards)
end


function add_children!(n::ANode)
    for j in valid_moves(n.gboard)
        child = Node(n, j)
        push!(n.children, child)
        n.computed_boards.node_count += 1
    end
    n.has_children = true
end


function evaluate!(n::Node)
    # if the game is won, the node ends
    if is_won(n.gboard) == 1
        n.score = 0
        n.terminal = true
    elseif is_won(n.gboard) == 2
        n.score = 1
        n.terminal = true

    elseif length(n.children) == 0
        n.score = 0.5 # game is tied
        n.terminal = true
    else
        n.score = 0.5 
    end
end


function reevaluate!(n::Node, depth)
    if !n.terminal
        if !n.has_children
            add_children!(n)
            evaluate!(n)
        end
        if n.depth < depth
            for child in n.children
                reevaluate!(child, depth)
            end
            rescore(n)
        end
    end
end


function rescore(n::Node)
    if n.terminal
        return
    end

    n.terminal = true

    for child in n.children
        n.terminal &= child.terminal
        if child.score == 0
            if n.antinode
                n.score = 0
                n.terminal = true
                break
            end
        elseif child.score == 1
            if !n.antinode
                n.score = 1
                n.terminal = true
                break
            end
        end
    end

    if n.antinode
        score = minimum([child.score for child in n.children])
        if score == 0 || score == 1
            n.terminal = true
            n.score = score
        end
        if !n.terminal
            n.score = score - 0.5 + n.score
        end
    else
        score = maximum([child.score for child in n.children])
        if score == 0 || score == 1
            n.terminal = true
            n.score = score
        end
        if !n.terminal
            n.score = n.score + 0.5 - score
        end
    end
end








