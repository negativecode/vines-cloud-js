class Apps extends Resource
  constructor: (@vines) ->

  build: (obj) -> new App obj, @vines

  url: (resource) ->
    @vines.resources.apps + (resource || '')
