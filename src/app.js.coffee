class App
  constructor: (obj, @vines) ->
    @id = obj.id
    @name = obj.name
    @nick = obj.nick
    @pubsub = obj.pubsub

  classes: (callback) ->
    this.load '/classes', callback, (row) =>
      new Storage row.name, this

  channels: (callback) ->
    this.load '/channels', callback, (row) =>
      new Channel row.name, this

  load: (url, callback, builder) ->
    callback ||= ->
    result = new $.Deferred

    done = (obj) ->
      results = (builder row for row in obj.rows)
      callback results
      result.resolve results

    fail = (error) ->
      callback null, error
      result.reject error

    get(this.url url).then done, fail
    result.promise()

  url: (resource) ->
    @vines.url "/apps/#{@nick}#{resource || ''}"

  channel: (name) ->
    if arguments.length == 1
      new Channel arguments[0], this
    else
      new Channel name, this for name in arguments

  storage: ->
    if arguments.length == 1
      new Storage arguments[0], this
    else
      new Storage type, this for type in arguments
