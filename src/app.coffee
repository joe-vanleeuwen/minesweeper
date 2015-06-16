# $(document).ready(function () {
#   console.log("Hey")
# })

events =
  _eventHandlers: {}

  registerEventHandler: (e, handler)->
    if !@_eventHandlers[e]
      @_eventHandlers[e] = []
    @_eventHandlers[e].push(handler)

  fireEvent: (e, args...)->
    handlers = @_eventHandlers[e]
    if (handlers? && handlers.length)
      for handler in handlers
        handler.apply(@, args)

  listenTo: (obj, e, handler)->
    obj.registerEventHandler(e, handler)

board = _.extend events,
  init: (options={})->
    @options = options
    @fresh = yes
    @registerEventHandler "show:square", ($square)->
      initial = 
        x: $square.data("x")
        y: $square.data("y")
      if @fresh
        @createData(initial)
      # trigger check
      @fresh = no
    @newGame()

  newGame: ->
    @createBoard()

  createData: (initial)->
    {rows, columns, bombs} = @options
    # empties = _.flatten(_.map([0..rows-1], (r)-> _.map([0..columns-1], (c)-> { r:r,c:c })))

    empties = []
    for x in [0..rows-1]
      for y in [0..columns-1] when not (x is initial.x and y is initial.y)
        empties.push({ x:x,y:y })

    squares = _.map([1..rows], -> [])

    l = empties.length
    # disperse the bombs
    while (empties.length > l - bombs)
      n = _.random(empties.length - 1)
      {x,y} = empties[n]
      squares[x][y] = {type: "bomb"} # state: "hidden"
      empties.splice(n, 1)

    empties.push(initial)

    # set the numbers. A delicate treatment of scope.
    for {x,y} in empties
      # grid of the 8 surrounding positions 
      grid = [[x-1,y-1],[x-1,y],[x-1,y+1],[x,y-1],[x,y+1],[x+1,y-1],[x+1,y],[x+1,y+1]]
      # calculate the number of adjacent bombs
      squares[x][y] =
        bombs: (1 for [x,y] in grid when squares[x]?[y]?.type is "bomb").length

    # TODO: create square class?
    # TODO: reveal all empty squares and there neighboring squares that have bomb counts

  createBoard: ->
    {rows, columns} = @options
    $("#app").append("""
      <table class='board'>
        <tbody></tbody>
      </table>
      """)
    for row in [0..rows-1]
      $(".board").append("<tr></tr>")
      for column in [0..columns-1]
        $tr = $(".board").find("tr").last()
        $tr.append("<td data-x='"+row+"' data-y='"+column+"'></td>")
        $tr.find("td").last().on "click", (e)=>
          $t = $(e.currentTarget)
          if e.which is 1
            @fireEvent "show:square", $t
          else if e.which is 3
            @fireEvent "flag:square", $t
        # square = createSquare()

        # console.log "x, y", row, column

  # createSquare: (position)->
  #   return {
  #     $el: $("<td></td>")
  #     row: position.row
  #     column: position.column
  #   }

$(document).ready ->
  console.log "Init!"
  board.init
    rows: 3
    columns: 3
    bombs: 8
  
