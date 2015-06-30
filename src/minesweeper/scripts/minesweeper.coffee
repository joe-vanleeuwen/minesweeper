Events = require("/utils/events")
Square = require("./square")

class Minesweeper extends Events

  constructor: (options={})->
    super()
    {@rows, @columns, @bombs} = options
    @newGame()
    window.minesweeper = @
    @setClickFace()

  setClickFace: ->
    $(".face").on "mousedown", => @updateFace("pressed")
    $(".face").on "mouseup", =>
      @updateFace("smile")
      @newGame()

  onShowSquare: (square)->
    {position} = square
    list = [square]
    if @isNewGame
      @isNewGame = no
      @createData(position)
      @startTimer()
    if square.isBomb
      @gameOver(square)
    else if square.bombs is 0
      list = list.concat(@reveal(position))

    for square in list
      square.show()

    @flagSurroundedBombs()

  # Automatically flag bombs if completely surrounded by revealed/bomb squares
  # (if those type of bombs are the ony bombs left)
  flagSurroundedBombs: ->
    bombsLeft = []
    for square in _.flatten(@board)
      if square.isBomb and not square.isFlagged
        {x,y} = square.position
        grid = @createGrid(x,y)
        n = (1 for [x,y] in grid when @board[x][y].isRevealed or @board[x][y].isBomb).length
        if n is grid.length
          bombsLeft.push(square)
        else return
    bombsFlagged = @numFlaggedBombs()
    if bombsFlagged + bombsLeft.length is @bombs
      for square in bombsLeft
        square.trigger("flag:square", yes)

  onFlagSquare: (isFlagged)->
    @flagCount += if isFlagged then -1 else 1
    @updateMineCounter(@flagCount)
    @checkWin()

  numFlaggedBombs: ->
    squares = _.flatten(@board)
    count = (s for s in squares when s.isBomb and s.isFlagged).length

  checkWin: ->
    count = @numFlaggedBombs()
    if count is @bombs
      @updateFace("win")
      @off()

  startTimer: ->
    @start = new Date().getTime()
    @interval = setInterval =>
      count = Math.round((new Date().getTime() - @start)/1000)
      @updateTimeCounter(count)
    , 1000

  resetTimer: ->
    clearInterval(@interval)
    @updateTimeCounter()

  updateTimeCounter: (count)-> @updateCounter(".time-count", count)
  updateMineCounter: (count)-> @updateCounter(".mines-count", count)
  updateCounter: (set, count=0)->
    count = ("00"+count)[-3..]
    for i in [0,1,2]
      $digit = $("#{set} > div:nth-child(#{i+1})")
      $digit.attr("class", "time#{count[i]}")

  newGame: ()->
    @destroy()
    @isNewGame = yes
    @resetTimer()
    @flagCount = @bombs
    @updateMineCounter(@flagCount)
    @createBoard()

  gameOver: (_square)->
    @updateFace("dead")
    for square in _.flatten(@board)
      square.gameOver(_square)
      square.destroy()
    clearInterval(@interval)
    @off()

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
      @board[x][y].bombs = (1 for [x,y] in grid when @board[x][y].isBomb).length

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
        delete matrix[x][y]
    _.compact(_.flatten(matrix))

  createMatrix: ->
    _.map([1..@rows], -> [])

  createGrid: (x,y, includeSelf=no)->
    grid = [
      [x-1,y-1],[x-1,y],[x-1,y+1],
      [x,y-1],  [x,y],  [x,y+1],
      [x+1,y-1],[x+1,y],[x+1,y+1]]
    grid.splice(4,1) if not includeSelf
    grid = ([x,y] for [x,y] in grid when x >= 0 and x < @rows and y >= 0 and y < @columns)

  # TODO: refactor to correctly reveal if given a non-empty square (numbered)
  reveal: ({x,y}, list=@createMatrix())->
    # if is bomb then reveal all squares and end game
    grid = @createGrid(x,y)
    # If square is an actual square and has not been added to list of squares to be revealed
    for [x,y] in grid when (square = @board[x][y]) and not list[x][y]
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
        @listenToOnce square, "show", @onShowSquare
        @listenTo square, "flag:square", @onFlagSquare
        @board[x][y] = square
    $(".squares").html(squares) 
    $(".board").css("display", "inline-block")

  destroy: ->
    for square in _.flatten(@board)
      square.destroy()
    @off()

module.exports = Minesweeper