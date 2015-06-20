# event handling
class Events
  constructor: ->
    @_eventHandlers = {}
    @_setListenters()

  registerEventHandler: (e, handler)->
    if !@_eventHandlers[e]
      @_eventHandlers[e] = []
    @_eventHandlers[e].push(handler)

  fireEvent: (e, args...)->
    handlers = @_eventHandlers[e]
    if (handlers? && handlers.length)
      for handler in handlers
        handler.apply(@, args)

  listenTo: (obj, e, handler)->
    boundHandler = _.bind(handler, @)
    obj.registerEventHandler(e, boundHandler)

  _setListenters: ->
    for k, v of @
      if k[..1] is "on" and /[A-Z]/.test(k[2]) and _.isFunction v
        # TODO: refactor this
        e = k.substr(2).replace(/([A-Z])/g, ':$1').replace(/([A-Z])/g, (str)-> str.toLowerCase()).substr(1)
        @registerEventHandler(e, v)
    

module.exports = Events