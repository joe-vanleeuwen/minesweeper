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
    empties = @createEmpties(initial)

    l = empties.length
    # disperse the bombs
    while (empties.length > l - @bombs)
      n = _.random(empties.length - 1)
      {x,y} = empties[n]
      @board[x][y].isBomb = yes
      empties.splice(n, 1)
    # add the initial selected square into empties
    empties.push(initial)

    # # set the numbers. A delicate treatment of scope.
    # for {x,y} in empties
    #   # grid of the 8 surrounding positions 
    #   grid = @createGrid(x,y)
    #   # calculate the number of adjacent bombs
    #   @board[x][y].bombs = (1 for [x,y] in grid when @board[x]?[y]?.isBomb).length

    for square in _.flatten(@board) when not square.isBomb
      # grid of the 8 surrounding positions 
      grid = @createGrid(square.position.x,square.position.y)
      # calculate the number of adjacent bombs
      square.bombs = (1 for [x,y] in grid when @board[x]?[y]?.isBomb).length



  createEmpties: (initial)->
    empties = []
    for x in [0..@rows-1]
      for y in [0..@columns-1] when not (x is initial.x and y is initial.y)
        empties.push({ x:x,y:y })
    empties

  createSquares: ->
    _.map([1..@rows], -> [])

  createGrid: (x,y)->
    [[x-1,y-1],[x-1,y],[x-1,y+1],[x,y-1],[x,y+1],[x+1,y-1],[x+1,y],[x+1,y+1]]

  reveal: ({x,y}, list=@createSquares())->
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
        @reveal({ x:x,y:y }, list)
    return _.compact(_.flatten(list))

  createBoard: ->
    @board = @createSquares()
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