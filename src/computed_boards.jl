include("gameboard.jl")
include("node.jl")



Base.@kwdef mutable struct ComputedBoards
    node_count = 0
    nodes  = Array[ Node[] for _ in 1:N_ROWS*N_COLS ]
end



"""
Check if a node with the current gameboard
exists. Otherwise, returns a new node
"""
function add_node!(parent, j)
    nodes = parent.computed_boards.nodes
    gboard= move(parent.gboard, j)

    idx = gboard.turn # each move creates a new turn

    for node in nodes[idx]
        if node.gboard.board == gboard.board
            push!(parent.children, node)
            return node
        end
    end

    node = Node(;gboard=gboard, 
                parent=parent, 
                depth=parent.depth + 1, 
                last_move=j, 
                antinode=!parent.antinode, 
                computed_boards=parent.computed_boards)

    evaluate!(node)
    push!(nodes[idx], node)
    push!(parent.children, node)
    

    return node
end



function evaluate!(n::Node)
    # if the game is won, the node ends
    
    if is_won(n.gboard) == 1
        n.score = 0
        n.terminal = true
    elseif is_won(n.gboard) == -1
        n.score = 1
        n.terminal = true

    elseif length(n.children) == 0
        n.score = 0.5 # game is tied
        n.terminal = true
    else
        n.score = 0.5 
    end
end

