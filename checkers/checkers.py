from math import floor

class piece:
    pieceID = None
    team = None
    square = None
    king = None

    def __init__(self, team, square, pieceID):
        self.pieceID = pieceID
        self.team = team
        self.square = square
        self.king = False

    def onBoard(self):
        if self.square: return True
        else: return False

class square:
    squareID = None
    position = None
    even = None
    piece = None
    right = None
    topLeft = None
    topRight = None
    bottomLeft = None
    bottomRight = None

    def __init__(self, id):
        if(id < 32):
            self.id = id

            if floor(id / 4) % 2 == 0:
                self.position = str(floor(id / 4))+'.'+str(id % 4 * 2)
                self.even = True
            else:
                self.position = str(floor(id / 4))+'.'+str(id % 4 * 2 + 1)
                self.even = False

            self.right = square(id + 1)
        else:
            self.right = None
    
    def __init__(self):
        self.id = 0
        self.position = '0.0'
        self.even = True
        self.right = square(1)

class player:
    team = None
    pieces = None
    board = None

    def __init__(self, team, board):
        self.team = team
        self.board = board
        self.pices = []

class board:
    primary = None
    pieces = None
    player0 = None
    player1 = None

    def __init__(self):
        self.player0 = player(0, self)
        self.player1 = player(1, self)

        self.pieces = []

        self.primary = square()

test = board()