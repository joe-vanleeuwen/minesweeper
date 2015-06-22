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
        console.log "handler.context is @", handler.context is @
        if handler.once
          if handler.context is @
            @off(e, handler.func)
          else
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

  # once: 

  listenTo: (obj, e, handler, once=no)->
    @_listenTos = _.union(@_listenTos, [obj])
    obj.on(e, handler, context=@, once)
    return @

  listenToOnce: (obj, e, handler)->
    @listenTo(obj, e, handler, once=yes)

  stopListening: (obj, e, handlerToRemove)->
    if obj
      events = []
      events = _.flatten (v for k,v of obj._eventHandlers)
      console.log "events", events
      instances = _.union (h for h in events when h.context is @)
      if instances.length is 1
        @_listenTos = (o for o in @_listenTos when o isnt obj)
      console.log "instances", instances
      console.log "@_listenTos", @_listenTos

      obj.off(e, handlerToRemove, context=@)
      handlers = @_eventHandlers[e]
      # TODO: remove obj from @listenTos if there is no event with this object ast the context
      # @_listenTos = (obj for obj in @_listenTos when obj isnt)
      # test = []

    else
      for obj in @_listenTos
        obj.off(e, handlerToRemove, context=@)
      @_listenTos = []
    return @

  off: (e, handlerToRemove, context)->
    console.log "e, handlerToRemove, context", e, handlerToRemove, context
    if not _.compact(arguments).length
      @_reset()
    else if e and not handlerToRemove and not context
      delete @_eventHandlers[e]
    else
      for k,v of @_eventHandlers when not e or (e and e is k)
        events = (h for h in v when h.context isnt context and h.func isnt handlerToRemove)
        @_eventHandlers[k] = events
        console.log "events.length", events.length
        delete @_eventHandlers[k] if not events.length
    return @

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