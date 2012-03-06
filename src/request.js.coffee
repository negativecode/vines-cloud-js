class Request
  @error: (request) ->
    obj =
      try
        JSON.parse(request.responseText).error
      catch e
        null
    obj || {id: 'unknown-error', status: request.status}

  constructor: (@method, @url) ->

  run: (params) ->
    type =
      switch @method
        when 'POST', 'PUT' then 'application/json'
        else ''

    result = new $.Deferred()
    done = -> result.resolve arguments...
    fail = (request) -> result.reject Request.error(request)
    $.ajax(
      url: @url
      type: @method
      dataType: 'json'
      data: params || ''
      contentType: type
      xhrFields: {withCredentials: true}
    ).then done, fail
    result.promise()
