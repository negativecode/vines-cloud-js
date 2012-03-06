class Resource
  constructor: ->

  build: (obj) -> obj

  count: (callback) ->
    callback ||= ->
    result = new $.Deferred

    done = (obj) ->
      callback obj.total
      result.resolve obj.total

    fail = (error) ->
      callback null, error
      result.reject error

    get(this.url(), limit: 1).then done, fail
    result.promise()

  find: (options, callback) ->
    callback ||= ->
    result = new $.Deferred

    done = (obj) =>
      obj = this.build obj
      callback obj
      result.resolve obj

    fail = (error) ->
      callback null, error
      result.reject error

    get(this.url "/#{options.id}").then done, fail
    result.promise()

  all: (options, callback) ->
    params = {}
    params.limit = options.limit if options.limit
    params.skip = options.skip if options.skip

    callback ||= ->
    result = new $.Deferred

    done = (obj) =>
      rows = (this.build row for row in obj.rows)
      callback rows
      result.resolve rows

    fail = (error) ->
      callback null, error
      result.reject error

    get(this.url(), params).then done, fail
    result.promise()

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

  remove: (options, callback) ->
    callback ||= ->
    result = new $.Deferred

    done = (obj) ->
      callback options
      result.resolve options

    fail = (error) ->
      callback null, error
      result.reject error

    remove(this.url "/#{options.id}").then done, fail
    result.promise()
