class Resource
  constructor: ->

  build: (obj) -> obj

  callback: ->
    (arg for arg in arguments when type(arg) == 'function')[0]

  where: ->
    new Query(this).where arguments...

  count: ->
    callback = this.callback arguments...
    this.where(arguments...).count callback

  all: ->
    callback = this.callback arguments...
    this.where(arguments...).all callback

  first: ->
    callback = this.callback arguments...
    this.where(arguments...).first callback

  find: ->
    callback = this.callback arguments...
    ids = if type(arguments[0]) == 'array'
      arguments[0]
    else if type(arguments[0]) == 'string'
      arguments
    else
      throw 'id required'

    ids = (id for id in ids when type(id) == 'string')
    throw 'id required' unless ids.length > 0

    # hex object ids
    list = if ids[0].match /^[0-9a-z]{24}$/i
      ids.join(',')
    # usernames
    else
      "'" + ids.join("','") + "'"

    query = "id in [#{list}]"
    if ids.length == 1
      this.first query, callback
    else
      this.all query, callback

  save: (options, callback) ->
    callback ||= ->
    result = new $.Deferred

    done = (obj, text, request) =>
      if location = request.getResponseHeader 'Location'
        id = location.split('/')
        options.id = id[id.length - 1]
      callback options
      result.resolve options

    fail = (error) ->
      callback null, error
      result.reject error

    json = JSON.stringify options
    if options.id
      put(this.url("/#{options.id}"), json).then done, fail
    else
      post(this.url(), json).then done, fail
    result.promise()

  remove: (id, callback) ->
    callback ||= ->
    result = new $.Deferred

    done = (obj) ->
      callback id
      result.resolve id

    fail = (error) ->
      callback null, error
      result.reject error

    remove(this.url "/#{id}").then done, fail
    result.promise()
