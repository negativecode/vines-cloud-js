class Storage extends Resource
  constructor: (@name, @app) ->

  url: (resource) ->
    @app.url "/classes/#{@name}#{resource || ''}"
