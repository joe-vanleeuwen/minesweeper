Minesweeper = require("minesweeper/scripts/minesweeper")
# TODO: create square class?
# TODO: reveal all empty squares and there neighboring squares that have bomb counts
$(document).ready ->
  console.log "Init!"
  new Minesweeper
    rows: 16
    columns: 30
    bombs: 99



