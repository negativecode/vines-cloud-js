class Storage extends Resource
  constructor: (@name, @app) ->
    @size = 0

  url: (resource) ->
    @app.url "/classes/#{@name}#{resource || ''}"
