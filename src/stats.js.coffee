class Stats
  constructor: (@vines) ->

  all: (callback) ->
    callback ||= ->
    result = new $.Deferred

    done = (obj) ->
      callback obj.rows
      result.resolve obj.rows

    fail = (error) ->
      callback null, error
      result.reject error

    get(this.url()).then done, fail
    result.promise()

  url: (resource) ->
    @vines.resources.stats + (resource || '')
