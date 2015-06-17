events = require("/utils/events")

board = _.extend events,
  init: (options={})->
    @options = options
    {@rows, @columns, @bombs} = @options
    @fresh = yes
    @registerEventHandler "show:square", @onShowSquare
    @newGame()

  onShowSquare: ($square)->
    initial = 
      x: $square.data("x")
      y: $square.data("y")
    if @fresh
      @fresh = no
      @createData(initial)
    list = @reveal(initial)
    console.log "the list", list
    # trigger check

  newGame: ->
    @createBoard()

  createData: (initial)->
    empties = @createEmpties(initial)
    @squares = @createSquares()

    window.squares = @squares

    l = empties.length
    # disperse the bombs
    while (empties.length > l - @bombs)
      n = _.random(empties.length - 1)
      {x,y} = empties[n]
      @squares[x][y] = {type: "bomb"} # state: "hidden"
      empties.splice(n, 1)
    # add the initial selected square into empties
    empties.push(initial)

    # set the numbers. A delicate treatment of scope.
    for {x,y} in empties
      # grid of the 8 surrounding positions 
      grid = @createGrid(x,y)
      # calculate the number of adjacent bombs
      @squares[x][y] =
        bombs: (1 for [x,y] in grid when @squares[x]?[y]?.type is "bomb").length

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


  # TODO: add initial square to the list!! -> list[x][y] = { x:x,y:y }
  reveal: ({x,y}, list=@createSquares())->
    # if is bomb then reveal all squares and end game
    # maybe try some recursion for finding all squares that need to be revealed?
    grid = @createGrid(x,y)
    # If square is an actualy square and has not been added to list of squares to be revealed
    for [x,y] in grid when (square = @squares[x]?[y]) and not list[x]?[y]
      if square.type isnt "bomb"
        # add position to the list
        list[x][y] = { x:x,y:y }
      if square.bombs is 0
        # this is an empty square so check its neighboring squares
        @reveal({ x:x,y:y }, list)
    return _.flatten(list)

  createBoard: ->
    $("#app").append("""
      <table class='board'>
        <tbody></tbody>
      </table>
      """)
    for row in [0..@rows-1]
      $(".board").append("<tr></tr>")
      for column in [0..@columns-1]
        $tr = $(".board").find("tr").last()
        $tr.append("<td data-x='"+row+"' data-y='"+column+"'></td>")
        $tr.find("td").last().on "click", (e)=>
          $t = $(e.currentTarget)
          if e.which is 1
            @fireEvent "show:square", $t
          else if e.which is 3
            @fireEvent "flag:square", $t

module.exports = board