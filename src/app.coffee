# $(document).ready(function () {
#   console.log("Hey")
# })

board =
  init: (dimensions)->
    $("#app").append("<div class='board'></div>")


    for row in [1..dimensions[0]]
      for column in [1..dimensions[1]]
        $(".board").append("<div class='square'>" + row + " " + column + "</div>")
        console.log "x, y", row, column

$(document).ready ->
  console.log "Init!", board.init([2, 4])
  
