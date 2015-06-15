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
      position = 
        row: $square.data("row")
        column: $square.data("column")
      if @fresh
        @createData(position)
      # trigger check
      @fresh = no
    @newGame()

  newGame: ->
    @createBoard()

  createData: (position)->
    {rows, columns, bombs} = @options
    # empties = _.flatten(_.map([0..rows-1], (r)-> _.map([0..columns-1], (c)-> { r:r,c:c })))

    empties = []
    for r in [0..rows-1]
      for c in [0..columns-1] when not (r is position.row and c is position.column)
        empties.push({ r:r,c:c })

    data = _.map([1..rows], -> [])
    data[position.row][position.column] = {type: "empty", state: "cleared"} # new Square(state: "cleared")
    l = empties.length

    while (empties.length > l - bombs)
      n = _.random(empties.length - 1)
      position = empties[n]
      data[position.r][position.c] = {type: "bomb", state: "hidden"}
      empties.splice(n, 1)
    console.log "data", data

    # TODO: add in rest of squares!


    # INEFFICIENT
    # data = _.map([1..rows], (n)-> [])
    # data[position.row][position.column] = {type: "empty", state: "cleared"} # new Square(state: "cleared")
    # i = 0
    # while (i < bombs)
    #   row = _.random(rows - 1)
    #   column = _.random(columns - 1)
    #   if not data[row][column]
    #     data[row][column] = {type: "bomb", state: "hidden"}
    #     i++
    # console.log "data", data

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
        position = {row: row, column: column}
        $tr = $(".board").find("tr").last()
        $tr.append("<td data-row='"+row+"' data-column='"+column+"'></td>")
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
    rows: 2
    columns: 2
    bombs: 3
  
