board = require("board/scripts/board")
# TODO: create square class?
# TODO: reveal all empty squares and there neighboring squares that have bomb counts
$(document).ready ->
  console.log "Init!"
  board.init
    rows: 3
    columns: 3
    bombs: 0



