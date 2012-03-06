class Users extends Resource
  constructor: (@vines) ->

  url: (resource) ->
    @vines.resources.users + (resource || '')
