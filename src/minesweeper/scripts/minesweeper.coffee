Events = require("/utils/events")
Square = require("./square")

class Minesweeper extends Events
  constructor: (options={})->
    super()
    @options = options
    {@rows, @columns, @bombs} = @options
    @newGame()
    window.minesweeper = @
    @setClickFace()

  setClickFace: ->
    $(".face").on "mousedown", =>
      @updateFace("pressed")
    $(".face").on "mouseup", =>
      @updateFace("smile")
      @newGame()

  onShowSquare: (square)->
    {position} = square
    list = [square]
    if @isNewGame
      @isNewGame = no
      @createData(position)
    if square.isBomb
      @gameOver(yes)
    else if square.bombs is 0
      list = list.concat(@reveal(position))

    console.log "the list", list

    for square in list
      square.show()

  newGame: (lost=no)->
    @gameOver(lost)
    @isNewGame = yes
    @createBoard()

  gameOver: (lost=no)->
    @updateFace("dead") if lost
    for square in _.flatten(@board)
      square.destroy()
      if lost
        if square.isBomb
          square.show("game_over")

  updateFace: (klass)->
    $(".face").removeClass(@previousKlass).addClass(klass)
    @previousKlass = klass

  createData: (initial)->
    # List of positions that can be bombs
    bombable = @createEmpties(initial)

    l = bombable.length
    # disperse the bombs
    while (bombable.length > l - @bombs)
      n = _.random(bombable.length - 1)
      {x,y} = bombable[n]
      @board[x][y].isBomb = yes
      bombable.splice(n, 1)
    # positions that are not bombed
    unbombed = @createEmpties(initial, yes)

    # set the numbers. A delicate treatment of scope.
    for {x,y} in unbombed
      # grid of the 8 surrounding positions 
      grid = @createGrid(x,y)
      # calculate the number of adjacent bombs
      @board[x][y].bombs = (1 for [x,y] in grid when @board[x]?[y]?.isBomb).length

  # create list of unbombed positions with or without inital and neighboring positions
  createEmpties: ({x,y}, all=no)->
    grid = @createGrid(x,y, yes)

    matrix = @createMatrix()
    for x in [0..@rows-1]
      for y in [0..@columns-1] when not @board[x][y].isBomb # seems hacky =/
        matrix[x][y] = { x:x,y:y }

    if not all
      # Remove inital and adjacent positions
      for [x,y] in grid
        delete matrix[x]?[y]
    _.compact(_.flatten(matrix))

  createMatrix: ->
    _.map([1..@rows], -> [])

  createGrid: (x,y, includeSelf=no)->
    grid = [
      [x-1,y-1],[x-1,y],[x-1,y+1],
      [x,y-1],          [x,y+1],
      [x+1,y-1],[x+1,y],[x+1,y+1]]
    if includeSelf then grid.concat([[x,y]]) else grid

  reveal: ({x,y}, list=@createMatrix())->
    # if is bomb then reveal all squares and end game
    grid = @createGrid(x,y)
    # If square is an actual square and has not been added to list of squares to be revealed
    for [x,y] in grid when (square = @board[x]?[y]) and not list[x]?[y]
      # console.log "square is", square
      if not square.isBomb
        # add position to the list
        list[x][y] = square
      if square.bombs is 0
        # this is an empty square so check its neighboring squares
        @reveal(square.position, list)
    return _.compact(_.flatten(list))

  createBoard: ->
    @board = @createMatrix()
    window.board = @board
    squares = $("<tbody></tbody>")
    for x in [0..@rows-1]
      squares.append("<tr></tr>")
      for y in [0..@columns-1]
        square = new Square(position: {x:x,y:y})
        $tr = squares.find("tr").last()
        $tr.append square.$el
        # squares.after(square.$el)
        @listenToOnce square, "show:square", @onShowSquare
        @board[x][y] = square
    $(".squares").html(squares) 
    $(".board").css("display", "inline-block")

  destroy: ->
    @off()

module.exports = Minesweeper