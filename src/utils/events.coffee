# event handling
events =
  _eventHandlers: {}

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
    obj.registerEventHandler(e, handler)

module.exports = events