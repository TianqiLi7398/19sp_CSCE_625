import matplotlib.pyplot as plt
from matplotlib import colors
import numpy as np
from hw2_lib import piece, board, grid_print

orange = [[1, 1]]
dark_green = [[1, 1, 1, 1, 1]]
green = [[0, 1, 1, 0], [1, 1, 1, 0], [0, 1, 1, 1]]
yellow = [[1, 1, 0], [0, 1, 1], [0, 0, 1]]
red = [[1, 1, 0], [1, 1, 1], [1, 1, 0]]
red_orange = [[1, 1, 1, 1], [0, 1, 1, 0]]

dark_purple = [[1, 0, 0], [1, 1, 0], [1, 1, 1]]
purple = [[0, 1, 0], [1, 1, 1]]
blue = [[1, 1, 1, 1], [0, 0, 1, 0]]

holes = [[0, 3], [1, 0], [1, 4], [1, 5], [3, 2], [3, 3],
         [4, 1], [4, 4], [4, 6], [5, 3], [6, 0], [6, 4], [6, 5]]

Units = [piece(orange, 'orange', 1),
         piece(dark_green, 'dark_green', 2),
         piece(green, 'green', 3),
         piece(yellow, 'yellow', 4),
         piece(red, 'red', 5),
         piece(red_orange, 'red_orange', 6),
         piece(dark_purple, 'dark_purple', 7),
         piece(purple, 'purple', 8),
         piece(blue, 'blue', 9)]


Total_solu = []

for i in range(len(holes)):
    print('problem %s' % (i+1))

    Board = board((7, 7), holes)

    Board.problem_init(i)

    Board.simp_search(Board.board.flatten(), Board.manage(Units))

    Total_solu.append(Board.solution)

    # f = open('result.txt', 'w')
    # f.write('Problem %s' % i)
    # f.write('\n')
    # f.write(str(Board.solution))
    # f.close()

i = 1
for solution in Total_solu:
    print('*****problem %s' % i)

    if solution == []:
        print('nope')
    else:
        print('%s solutions found!' % len(solution))
        j = 1
        for board_ in solution:
            print(np.reshape(board_, (7, 7)))
            grid_print(np.reshape(board_, (7, 7)), i, j)
            j += 1
    i += 1
