include("node.jl")
include("computed_boards.jl")
include("gameboard.jl")

const MAX_NODES = 10000


Base.@kwdef mutable struct ParentNode <: ANode
    gboard::Gameboard
    children = Node[]
    antinode = false
    

    depth::Int = 0
    score::Float64 = 0.5
    terminal = false
    has_children = false
    computed_boards = ComputedBoards()
end


function recommend_move!(p_node::ParentNode)
    depth = 3
    add_children!(p_node)

    while p_node.computed_boards.node_count < MAX_NODES
        println("evaluating at depth $depth")
        reevaluate!(p_node, depth)

        terminate = true
        for child in p_node.children
            terminate &= child.terminal
        end

        if terminate
            break
        end

        depth += 1
    end

    max_score = -1
    best_move = 0

    for child in p_node.children
        if child.score > max_score
            max_score = child.score
            best_move = child.last_move
        end
    end

    println("computer calculates $best_move with score $max_score")
    println("evaluated $(p_node.computed_boards.node_count) boards")
    return best_move
end
    
function reevaluate!(p_node::ParentNode, depth)
    for child in p_node.children
        reevaluate!(child, depth)
    end
    p_node.score = maximum(child.score for child in p_node.children)
end
    

function evaluate!(p_node::ParentNode)
    for m in valid_moves(p_node.gboard)
        child = node(p_node, m)
        child.evaluate()

        push!(p_node.children, child)

        # trimming the tree
        if child.score == 0 && p_node.antinodex
            p_node.score = 0
            return
        end

        if child.score == 1 && !p_node.antinode
            p_node.score = 1
            return
        end

        p_node.score = maximum(child.score for child in p_node.children)
    end
end



