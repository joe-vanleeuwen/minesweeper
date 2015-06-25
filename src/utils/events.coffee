# event handling
class Events
  constructor: ->
    @_reset()
    @_setListenters()

  trigger: (e, args...)->
    handlers = @_eventHandlers[e]
    if (handlers? && handlers.length)
      for handler in handlers
        handler.func.apply(handler.context, args)
        if handler.once
          # This was set using once
          if handler.context is @
            @off(e, handler.func)
          else
          # This was set using listenToOnce
            handler.context.stopListening(@, e, handler.func)
    return @

  on: (e, handler, context=@, once=no)->
    if !@_eventHandlers[e]
      @_eventHandlers[e] = []
    @_eventHandlers[e].push
      func: handler
      context: context
      once: once
    return @

  once: (e, handler, context=@)->
    @on(e, handler, context, once=yes)

  listenTo: (obj, e, handler, once=no)->
    @_listenTos = _.union(@_listenTos, [obj])
    obj.on(e, handler, context=@, once)
    return @

  listenToOnce: (obj, e, handler)->
    @listenTo(obj, e, handler, once=yes)

  stopListening: (obj, e, handlerToRemove)->
    if obj
      obj.off(e, handlerToRemove, context=@)
    else
      for obj in @_listenTos
        obj.off(e, handlerToRemove, context=@)
      @_listenTos = []
    return @

  off: (e, handlerToRemove, context)->
    if not _.compact(arguments).length
      @_removeListeners(@_eventHandlers)
      @_reset()
    else if e and not handlerToRemove and not context
      @_removeListeners(@_eventHandlers[e])
      delete @_eventHandlers[e]
    else
      for k,v of @_eventHandlers when not e or (e and e is k)
        # events = (h for h in v when h.context isnt context and h.func isnt handlerToRemove)
        events = []
        eventsToRemove = []
        for h in v
          if h.context isnt context and h.func isnt handlerToRemove
            events.push(h)
          else
            eventsToRemove.push(h)
        @_removeListeners(eventsToRemove)

        @_eventHandlers[k] = events
        delete @_eventHandlers[k] if not events.length
    return @

  # Not sure if this is really necessary
  _removeListenTo: (obj)->
    events = _.flatten (v for k,v of obj._eventHandlers)
    instances = (h for h in events when h.context is @)
    if instances.length is 1
      i = @_listenTos.indexOf(obj)
      @_listenTos.splice(i,1)

  # Needs a better name
  _removeListeners: (handlers)->
    removeListeners = (handlers)=>
      # Get the number of times each context is used ?
      for handler in handlers when handler.context isnt @
        handler.context._removeListenTo(@)

    if _.isArray handlers
      removeListeners(handlers)
    else
      for e, handlers of handlers
        removeListeners(handlers)

  _setListenters: ->
    for k, v of @
      if k[..1] is "on" and /[A-Z]/.test(k[2]) and _.isFunction v
        # TODO: refactor this
        e = k.substr(2).replace(/([A-Z])/g, ':$1').replace(/([A-Z])/g, (str)-> str.toLowerCase()).substr(1)
        @on(e, v)

  _reset: ->
    @_listenTos = []
    @_eventHandlers = {}
    

module.exports = Events