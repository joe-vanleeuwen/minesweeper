Minesweeper = require("minesweeper/scripts/minesweeper")
# TODO: create square class?
# TODO: reveal all empty squares and there neighboring squares that have bomb counts
$(document).ready ->
  console.log "Init!"
  new Minesweeper
    rows: 10
    columns: 10
    bombs: 10



