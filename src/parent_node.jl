include("node.jl")
include("gameboard.jl")


Base.@kwdef mutable struct ParentNode <: ANode
    gboard::Gameboard
    children = Node[]
    antinode = false
    
    score::Float64 = 0.5
    depth = 0
    computed_boards = ComputedBoards()
end


function recommend_move!(p_node::ParentNode, max_nodes=10000)
    max_depth = 3
    add_children!(p_node)

    while p_node.computed_boards.node_count < max_nodes
        println("evaluating at depth $max_depth")
        reevaluate!(p_node, max_depth)

        if 1 >= sum(!child.terminal for child in p_node.children)
            break
        end
            
        max_depth += 1
    end

    max_idx = argmax(child.score for child in p_node.children)

    best_move = p_node.children[max_idx].last_move
    max_score = p_node.children[max_idx].score

    println("computer calculates $best_move with score $max_score")
    println("evaluated $(p_node.computed_boards.node_count) boards")
    return best_move
end
    


function reevaluate!(p_node::ParentNode, max_depth)
    for child in p_node.children
        reevaluate!(child, max_depth)

        if child.score == 0 && p_node.antinode
            p_node.score = 0
            return
        end

        if child.score == 1 && !p_node.antinode
            p_node.score = 1
            return
        end
    end

    p_node.score = maximum(child.score for child in p_node.children)
end



