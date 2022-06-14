from connect4 import game
import sys

def main():
    cf = bool(sys.argv[1])
    num_nodes = int(sys.argv[2])
    game().start(computer_first = cf, n_nodes=num_nodes)

if __name__ == "__main__":
    main()
