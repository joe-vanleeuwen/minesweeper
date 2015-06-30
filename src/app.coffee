Minesweeper = require("minesweeper/scripts/minesweeper")

$(document).ready ->

  new Minesweeper
    rows: 16
    columns: 30
    bombs: 99



