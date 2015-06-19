Events = require("/utils/events")

class Square extends Events

  defaults:
    bombs: null # if bombs is null then square is a bomb

  constructor: (@options) ->
    super()
    @options = _.extend @defaults, @options
    {@position, @bombs} = @options
    @createEl()
    @setClickEvent()

  createEl: ->
    {x,y} = @position
    @el = "<td></td>"
    @$el = $(@el)

  render: -> @$el

  setClickEvent: ->
    @$el.on "click", (e)=>
      if e.which is 1
        @fireEvent "show:square", @position
      else if e.which is 3
        @fireEvent "flag:square", @position


module.exports = Square