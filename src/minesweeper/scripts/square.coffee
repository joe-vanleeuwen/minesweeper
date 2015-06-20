Events = require("/utils/events")

class Square extends Events

  defaults:
    bombs: null # if bombs is null then square is a bomb
    isBomb: no
    isRevealed: no

  constructor: (options) ->
    super()
    for k, v of _.extend @defaults, options
      @[k] = v
    @createEl()
    @setClickEvent()

  createEl: ->
    {x,y} = @position
    @el = "<td></td>"
    @$el = $(@el)

  render: -> @$el

  classes:
    1: "one"
    2: "two"
    3: "three"
    4: "four"
    5: "five"
    6: "six"
    7: "seven"
    8: "eight"

  show: ->
    console.log "showing", @position
    if @isBomb
      @$el.text("B").addClass("revealed")
    else
      @$el.text(@bombs or "").addClass("revealed " + (@classes[@bombs] or ""))
    # else if @bombs is 0



  onShowSquare: ->
    console.log "on Show Square !!!"


  setClickEvent: ->
    @$el.on "click", (e)=>
      if e.which is 1
        console.log "not triggering!"
        @fireEvent "show:square", @
      else if e.which is 3
        @fireEvent "flag:square", @position


module.exports = Square