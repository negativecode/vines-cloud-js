class App
  constructor: (obj, @vines) ->
    @id = obj.id
    @name = obj.name
    @nick = obj.nick
    @pubsub = obj.pubsub

  classes: (callback) ->
    callback ||= ->
    result = new $.Deferred

    done = (obj) ->
      storage = (new Storage row.name, this for row in obj.rows)
      callback storage
      result.resolve storage

    fail = (error) ->
      callback null, error
      result.reject error

    get(this.url '/classes').then done, fail
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
