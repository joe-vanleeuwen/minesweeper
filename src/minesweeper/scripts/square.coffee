Events = require("/utils/events")

class Square extends Events

  defaults:
    bombs: null # if bombs is null then square is a bomb
    isBomb: no
    isRevealed: no

  classes:
    0: "zero"
    1: "one"
    2: "two"
    3: "three"
    4: "four"
    5: "five"
    6: "six"
    7: "seven"
    8: "eight"

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

  show: (state)->
    if @isBomb
      if state is "game_over"
        @$el.addClass("revealed bomb")
      else
        @$el.addClass("revealed bomb-death")
    else
      @$el.addClass("revealed #{@classes[@bombs]}")
    @off()
    # else if @bombs is 0

  onShowSquare: ->
    # @off()
    console.log "on Show Square !!!", @
    # @show()


  setClickEvent: ->
    @$el.on "click", (e)=>
      e.preventDefault()
      if e.which is 1
        console.log "left click"
        @trigger "show:square", @
      # TODO: RIGHT CLICK NOT WORKING
      else if e.which is 3
        console.log "right click"
        @trigger "flag:square", @position
      return false

  destroy: ->
    @$el.off()
    @off()


module.exports = Square