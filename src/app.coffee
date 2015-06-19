Minesweeper = require("minesweeper/scripts/minesweeper")
# TODO: create square class?
# TODO: reveal all empty squares and there neighboring squares that have bomb counts
$(document).ready ->
  console.log "Init!"
  new Minesweeper
    rows: 3
    columns: 3
    bombs: 0



