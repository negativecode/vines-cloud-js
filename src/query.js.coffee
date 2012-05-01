class Query
  constructor: (@resource) ->
    @params = {limit: 0, skip: 0}
    @query = ''
    @criteria = {}

  merge: (a, b) ->
    a[key] = value for own key, value of b

  limit: (limit) ->
    @params.limit = limit
    this

  skip: (skip) ->
    @params.skip = skip
    this

  where: ->
    if type(arguments[0]) == 'string'
      @query = arguments[0]
      if type(arguments[1]) == 'object'
        this.merge @criteria, arguments[1]
    else if type(arguments[0]) == 'object'
      this.merge @criteria, arguments[0]
    this

  first: (callback) ->
    callback ||= ->
    result = new $.Deferred

    done = (rows) ->
      obj = rows[0]
      callback obj
      result.resolve obj

    fail = (error) ->
      callback null, error
      result.reject error

    this.limit 1
    this.skip 0
    this.all().then done, fail
    result.promise()

  count: (callback) ->
    callback ||= ->
    result = new $.Deferred
    params =
      query: @query
      criteria: JSON.stringify @criteria
      limit: 1

    done = (obj) ->
      callback obj.total
      result.resolve obj.total

    fail = (error) ->
      callback null, error
      result.reject error

    get(@resource.url(), params).then done, fail
    result.promise()

  all: (callback) ->
    callback ||= ->
    result = new $.Deferred
    params =
      query: @query
      criteria: JSON.stringify @criteria
      limit: @params.limit
      skip: @params.skip

    done = (obj) =>
      rows = (@resource.build row for row in obj.rows)
      callback rows
      result.resolve rows

    fail = (error) ->
      callback null, error
      result.reject error

    get(@resource.url(), params).then done, fail
    result.promise()
