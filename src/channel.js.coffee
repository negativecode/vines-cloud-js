class Channel
  constructor: (@name, @app) ->
    @pubsub = new PubSub @app.vines.xmpp, @app.pubsub, @name
    @subscribers = []
    @subscription = null

  subscribe: (fn) ->
    @subscribers.push fn
    @subscription ||= @app.vines.xmpp.addHandler(
      ((node) => this.notify node), null, 'message', null, null, @app.pubsub)
    @pubsub.create()
    @pubsub.subscribe()

  publish: (obj) ->
    @pubsub.publish obj

  unsubscribe: ->
    @subscribers = []
    @app.vines.xmpp.deleteHandler @subscription
    @subscription = null
    @pubsub.unsubscribe()

  notify: (node) ->
    node    = $ node
    items   = node.find('event > items').first()
    channel = items.attr 'node'
    item    = items.find('item').first()
    from    = item.attr 'publisher'
    payload = item.find('payload').first()
    if channel == @name
      obj =
        publisher: from
        payload: JSON.parse payload.text()
        node: node
      sub obj for sub in @subscribers
    true # keep handler alive
