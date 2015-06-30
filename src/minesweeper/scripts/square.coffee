Events = require("/utils/events")

class Square extends Events

  defaults:
    bombs: null # if bombs is null then square is a bomb
    isBomb: no
    isRevealed: no
    isClicked: no
    isFlagged: no

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
    @setProps(options)
    @createEl()
    @setClickEvent()

  setProps: (options)->
    for k, v of _.extend @defaults, options
      @[k] = v

  createEl: ->
    {x,y} = @position
    @el = "<td></td>"
    @$el = $(@el)

  render: -> @$el

  show: ->
    @isRevealed = yes
    @$el.addClass(@classes[@bombs])
    @$el.off()
    @off()

  gameOver: ->
    if @isBomb
      klass = if @isClicked then "bomb-death" else "bomb"
    else if @isFlagged
      klass = "bomb-misflagged"
    @$el.addClass(klass)

  onFlagSquare: ->
    @isFlagged = not @isFlagged
    @$el.toggleClass("bomb-flagged")

  setClickEvent: ->
    @$el.on "mouseup", (e)=>
      e.preventDefault()
      if e.which is 1
        @isClicked = yes
        @trigger("show", @) if not @isFlagged
      return false

    @$el.on "contextmenu", (e)=>
      @trigger "flag:square", not @isFlagged
      return false

  destroy: ->
    @$el.off()
    @off()

module.exports = Square