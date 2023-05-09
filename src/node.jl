include("gameboard.jl")
abstract type ANode end

const ϵ = 1e-4

Base.@kwdef mutable struct Node <: ANode
    board::Gameboard

    parent::Union{ANode, Nothing} = Nothing
    children::Vector{Node} = []
    depth::Int = 0

    terminal::Bool = false
    eval_depth::Int = 0
    antinode::Bool

    last_move::Int = 0

    score::Float64 = 0.5
    has_children = false
    computed_boards = nothing
end



Base.@kwdef mutable struct ComputedBoards
    node_count = 0
    node_links = 0
    nodes  = Dict{Tuple{UInt64, UInt64}, Node}()
end




function add_children!(node::ANode)
    for j in valid_moves(node.board)
        add_node!(node, j)
        node.computed_boards.node_count += 1
    end
end



function reevaluate!(node::Node, depth)
    if node.terminal || depth < node.depth || depth < node.eval_depth
        return
    end

    if !node.has_children
        add_children!(node)
        node.has_children = true
    end

    for child in node.children
        reevaluate!(child, depth)
    end

    node.eval_depth = depth
    rescore!(node)
end








"""
Check if a node with the current gameboard
exists. Otherwise, returns a new node
"""
function add_node!(parent, j)
    nodes = parent.computed_boards.nodes
    board= move(parent.board, j)

    idx = (board.board1, board.board2)
    if idx in keys(nodes)
        node = nodes[idx]
        push!(parent.children, node)
        parent.computed_boards.node_links += 1
        return node
    end

    node = Node(;board=board, 
                parent=parent, 
                depth=parent.depth + 1, 
                last_move=j, 
                antinode=!parent.antinode, 
                computed_boards=parent.computed_boards,
                terminal = false,
                has_children = false)

    evaluate!(node)
    push!(nodes, idx => node)

    push!(parent.children, node)
    return node
end



function evaluate!(n::Node)
    # if the game is won, the node ends
    if is_won(n.board) == 1
        n.score = 0
        n.terminal = true
    elseif is_won(n.board) == -1
        n.score = 1
        n.terminal = true
    elseif is_tied(n.board)
        n.score = 0.5
        n.terminal = true
    else
        j = n.last_move
        i = column_height(n.board, j) - 1
        n.score = pos_score(n.board, i, j)
        n.terminal = false
    end
end


function rescore!(node::Node)
    terminal = true

    for child in node.children
        terminal &= child.terminal
        if child.score == 0 && node.antinode
            node.score = 0 + ϵ
            terminal = true
            break
        elseif child.score == 1 && !node.antinode
            node.score = 1 - ϵ
            terminal = true
            break
        end
    end
    node.terminal = terminal

    if node.antinode
        score = minimum([child.score for child in node.children])
        if score == 0 || score == 1
            node.terminal = true
            node.score = score
        end
        if !node.terminal
            node.score = score - 0.5 + node.score
        end
    else
        score = maximum([child.score for child in node.children])
        if score == 0 || score == 1
            node.terminal = true
            node.score = score
        end
        if !node.terminal
            node.score = node.score + 0.5 - score
        end
    end
end


function Base.show(io::IO, node::Node)
    println(io, "move = ", node.last_move)
    println(io, "score = ", node.score)
    println(io, "children ", length(node.children))
    println(io, "end ", node.terminal)
end





