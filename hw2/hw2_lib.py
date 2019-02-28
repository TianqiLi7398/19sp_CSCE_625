import matplotlib.pyplot as plt
from matplotlib import colors
import numpy as np
import copy


class piece():
    def __init__(self, construct, color, num):
        piece = np.matrix(construct) * num
        # from p1 - p4, rotate counter-clock
        self.num = num
        self.color = color
        if 0 not in piece:
            self.p1 = piece
            self.p2 = piece.transpose()
            self.all_shapes = [self.p1, self.p2]
        else:
            self.p1 = piece
            self.p2 = np.fliplr(piece).transpose()
            self.p3 = np.flipud(self.p2.transpose())
            self.p4 = np.flipud(self.p1).transpose()
            self.all_shapes = [self.p1, self.p2, self.p3, self.p4]

    def print_(self):
        for piece in self.all_shapes:
            print(piece)


class board:
    def __init__(self, size, holes):
        self.size = size
        self.board = np.zeros(size)
        self.holes = holes
        self.solution = []

    def problem_init(self, hole_num):
        # make the hole as the number
        self.board = np.zeros(self.size)
        self.board[self.holes[hole_num][0], self.holes[hole_num][1]] = 10
        return

    def manage(sef, unit_que):
        # this func reorder the variables, makes the 'big shape' unit to be searched
        # first, which follows the principle of MRV
        size = []
        for unit in unit_que:
            size.append(sum(unit.p1.shape))

        size_ = -1 * np.asarray(size)
        unit_que_ = np.asarray(unit_que)
        inds = size_.argsort()
        new_que = unit_que_[inds]
        # new_que = [x for _, x in sorted(zip(size, unit_que), reverse=True)]
        return new_que

    def search(self, flat_board, unit_que):
        # This search is an ordinary DFS
        try:
            index = np.where(flat_board == 0)[0][0]
        except IndexError:
            index = -1
        if index < 0:
            # all units are completed
            self.solution.append(flat_board)
            print('find sulution!')
            return
        else:
            # still need to work on it with remained units
            x_res, y_res = 7 - index % 7, 7 - index//7
            for unit in unit_que:
                # print(index, unit.color)
                for piece in unit.all_shapes:
                    # pick different steps
                    y_, x_ = piece.shape

                    direction = [False, False]  # left, right

                    # insert from the upper left:

                    if x_ <= x_res and y_ <= y_res:
                        # have suitable size
                        direction[0] = True
                        level = 0
                        for row in piece:
                            for length in range(x_):
                                if flat_board[index + length + level*7] != 0 and row[0, length] != 0:
                                    # conflict with other unit pieces
                                    direction[0] = False
                            level += 1

                    if x_ <= 7 - x_res + 1 and y_ <= y_res:
                        direction[1] = True
                        level = 0
                        for row in piece:
                            for length in range(x_):
                                if flat_board[index + length + level*7 - x_ + 1] != 0 and row[0, length] != 0:
                                    # conflict with other unit pieces
                                    direction[1] = False
                            level += 1

                    if direction[0] and direction[1]:
                        self_flat_board_left = copy.deepcopy(flat_board)
                        level = 0
                        # add the piece on the board
                        for row in piece:
                            for length in range(x_):
                                if row[0, length] != 0:
                                    if self_flat_board_left[index + length + level*7] == 0:
                                        self_flat_board_left[index +
                                                             length + level*7] = row[0, length]
                                    else:
                                        print('error!!')
                                        break
                            level += 1
                        # delete the unit in the queue
                        new_unit_que = [x for x in unit_que if x != unit]
                        self.search(self_flat_board_left, new_unit_que)

                        self_flat_board_right = copy.deepcopy(flat_board)
                        level = 0
                        # add the piece on the board
                        for row in piece:
                            for length in range(x_):
                                if row[0, length] != 0:
                                    if self_flat_board_right[index + length + level*7 - x_ + 1] == 0:
                                        self_flat_board_right[index + length +
                                                              level*7 - x_ + 1] = row[0, length]
                                    else:
                                        print('error!!')
                                        break
                            level += 1
                        # delete the unit in the queue

                        self.search(self_flat_board_right, new_unit_que)

                    elif direction[0]:
                        # only we can insert from left
                        self_flat_board_left = copy.deepcopy(flat_board)
                        level = 0
                        # add the piece on the board
                        for row in piece:
                            for length in range(x_):
                                if row[0, length] != 0:
                                    if self_flat_board_left[index + length + level*7] == 0:
                                        self_flat_board_left[index +
                                                             length + level*7] = row[0, length]
                                    else:
                                        print('error!!')
                                        break
                            level += 1
                        # delete the unit in the queue
                        new_unit_que = [x for x in unit_que if x != unit]
                        self.search(self_flat_board_left, new_unit_que)

                    elif direction[1]:
                        # only we can insert from left
                        self_flat_board_right = copy.deepcopy(flat_board)
                        level = 0
                        # add the piece on the board
                        for row in piece:
                            for length in range(x_):
                                if row[0, length] != 0:
                                    if self_flat_board_right[index + length + level*7 - x_ + 1] == 0:
                                        self_flat_board_right[index + length +
                                                              level*7 - x_ + 1] = row[0, length]
                                    else:
                                        print('error!!')
                                        break
                            level += 1
                        # delete the unit in the queue
                        new_unit_que = [x for x in unit_que if x != unit]
                        self.search(self_flat_board_right, new_unit_que)
                    else:
                        print(unit.color)
                        print(np.reshape(flat_board, (7, 7)))
                        # return
                        pass

    # def simp_search(self, flat_board, unit_que):
    #     # unit arrange in sequences, but if the sequence break, just jump out
    #     try:
    #         index = np.where(flat_board == 0)[0][0]
    #     except IndexError:
    #         index = -1
    #     if index < 0:
    #         # all units are completed
    #         self.solution.append(flat_board)
    #         print('find sulution!')
    #         return
    #     else:
    #         # still need to work on it with remained units
    #         x_res, y_res = 7 - index % 7, 7 - index//7
    #         for unit in unit_que:
    #             # print(index, unit.color)
    #             for piece in unit.all_shapes:
    #                 # pick different steps
    #                 y_, x_ = piece.shape
    #
    #                 direction = [False, False]  # left, right
    #
    #                 # find the first element in the piece (x,y)
    #                 y_0, x_0 = np.where(piece!= 0)[0][0], np.where(piece!= 0)[0][1]
    #
    #                 if y_ <= y_res:
    #                     if x_ -x_0 <= x_res and x_0 <= 7 - x_res:
    #                         level = 0
    #                         direction[0] = True
    #                         for row in piece:
    #                             for length in range(x_):
    #                                 if flat_board[index + length + level*7 - x_0] != 0 and row[0, length] != 0:
    #                                     direction[0] = False
    #                                 level += 1
    #
    #                 # insert from the upper left:
    #                 if piece[0, 0] != 0:
    #                     if x_ <= x_res and y_ <= y_res:
    #                         # have suitable size
    #                         direction[0] = True
    #                         level = 0
    #                         for row in piece:
    #                             for length in range(x_):
    #                                 if flat_board[index + length + level*7] != 0 and row[0, length] != 0:
    #                                     # conflict with other unit pieces
    #                                     direction[0] = False
    #                             level += 1
    #                 else:
    #                     # insert from the left side
    #                     if x_ <= 7 - x_res + 1 and y_ <= y_res:
    #                         direction[1] = True
    #                         level = 0
    #                         for row in piece:
    #                             for length in range(x_):
    #                                 if flat_board[index + length + level*7 - x_ + 1] != 0 and row[0, length] != 0:
    #                                     # conflict with other unit pieces
    #                                     direction[1] = False
    #                             level += 1
    #
    #                 if direction[0]:
    #                     # only we can insert from left
    #                     self_flat_board_left = copy.deepcopy(flat_board)
    #                     level = 0
    #                     # add the piece on the board
    #                     for row in piece:
    #                         for length in range(x_):
    #                             if row[0, length] != 0:
    #                                 if self_flat_board_left[index + length + level*7] == 0:
    #                                     self_flat_board_left[index +
    #                                                          length + level*7] = row[0, length]
    #                                 else:
    #                                     print('error!!')
    #                                     break
    #                         level += 1
    #                     # delete the unit in the queue
    #                     new_unit_que = [x for x in unit_que if x != unit]
    #                     self.simp_search(self_flat_board_left, new_unit_que)
    #
    #                 elif direction[1]:
    #                     # only we can insert from left
    #                     self_flat_board_right = copy.deepcopy(flat_board)
    #                     level = 0
    #                     # add the piece on the board
    #                     for row in piece:
    #                         for length in range(x_):
    #                             if row[0, length] != 0:
    #                                 if self_flat_board_right[index + length + level*7 - x_ + 1] == 0:
    #                                     self_flat_board_right[index + length +
    #                                                           level*7 - x_ + 1] = row[0, length]
    #                                 else:
    #                                     print('error!!')
    #                                     break
    #                         level += 1
    #                     # delete the unit in the queue
    #                     new_unit_que = [x for x in unit_que if x != unit]
    #                     self.simp_search(self_flat_board_right, new_unit_que)
    #                 else:
    #                     print(unit.color)
    #                     print(np.reshape(flat_board, (7, 7)))
    #                     pass

    def simp_search(self, flat_board, unit_que):
        # unit arrange in sequences, but if the sequence break, just jump out
        try:
            index = np.where(flat_board == 0)[0][0]
        except IndexError:
            index = -1
        if index < 0:
            # all units are completed
            self.solution.append(flat_board)
            print('find sulution!')
            return
        else:
            # still need to work on it with remained units
            x_res, y_res = 7 - index % 7, 7 - index//7
            for unit in unit_que:
                # print(index, unit.color)
                for piece in unit.all_shapes:
                    # pick different steps
                    y_, x_ = piece.shape

                    direction = [False, False]  # left, right

                    # find the first element in the piece (x,y)
                    y_0, x_0 = np.where(piece != 0)[0][0], np.where(piece != 0)[1][0]
                    # print(piece, y_0, x_0)

                    if y_ <= y_res:
                        if x_ - x_0 <= x_res and x_0 <= 7 - x_res:
                            level = 0
                            direction[0] = True
                            for row in piece:
                                for length in range(x_):
                                    if flat_board[index + length + level*7 - x_0] != 0 and row[0, length] != 0:
                                        direction[0] = False
                                level += 1

                    if direction[0]:
                        # insert from the first element of the piece
                        self_flat_board_left = copy.deepcopy(flat_board)
                        level = 0
                        # add the piece on the board
                        for row in piece:
                            for length in range(x_):
                                if row[0, length] != 0:
                                    if self_flat_board_left[index + length + level*7 - x_0] == 0:
                                        self_flat_board_left[index +
                                                             length + level*7 - x_0] = row[0, length]
                                    else:
                                        print('error!!')
                                        break
                            level += 1
                        # delete the unit in the queue
                        new_unit_que = [x for x in unit_que if x != unit]
                        self.simp_search(self_flat_board_left, new_unit_que)

                    else:
                        # print(unit.color)
                        # print(np.reshape(flat_board, (7, 7)))
                        pass


def grid_print(matrix, i, j):
    fig, ax = plt.subplots()
    cmap = colors.ListedColormap(['orange', 'darkgreen', 'lime', 'yellow',
                                  'red', 'orangered', 'violet', 'purple', 'blue', 'grey'])

    ax.imshow(matrix, cmap=cmap)
    plt.savefig('results/H%sSloution%s.png' % (i, j))
    return
