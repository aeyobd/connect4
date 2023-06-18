include("node.jl")
include("gameboard.jl")


Base.@kwdef mutable struct ParentNode <: ANode
    board::Gameboard
    children = Node[]
    
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

        if max_depth >= N_ROWS*N_COLS
            break
        end
            
        max_depth += 1
    end

    max_idx = argmax(child.score for child in p_node.children)

    for child in p_node.children
        s = child.score
        if s > -0.99
            println(child.last_move, "\t", child.score)
        else
            println(child.last_move, "\t x")
        end
    end

    best_move = p_node.children[max_idx].last_move
    max_score = p_node.children[max_idx].score

    println("computer calculates $best_move with score $max_score")
    println("evaluated $(p_node.computed_boards.node_count) boards")
    println("$(p_node.computed_boards.node_links) links")
    return best_move
end



function reevaluate!(p_node::ParentNode, max_depth)
    for child in p_node.children
        reevaluate!(child, max_depth)
    end
end



