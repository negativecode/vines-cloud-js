# private functions
get    = (url, params) -> new Request('GET', url).run params
post   = (url, params) -> new Request('POST', url).run params
put    = (url, params) -> new Request('PUT', url).run params
remove = (url, params) -> new Request('DELETE', url).run params

class @Vines
  constructor: (@domain) ->
    @resources = {}
    @apps = new Apps this
    @users = new Users this
    @xmpp = new Strophe.Connection this.url '/xmpp'

  url: (resource) -> "https://#{@domain}#{resource || ''}"

  authenticate: (username, password, callback) ->
    callback ||= ->
    result = new $.Deferred

    error = (request) ->
      fail Request.error(request)

    fail = (error) =>
      @xmpp.disconnect()
      callback null, error
      result.reject error

    xmpp = (user) =>
      # username may have been email, so use user.id for xmpp
      @xmpp.connect user.id, password, (status) =>
        switch status
          when Strophe.Status.CONNFAIL
            fail id: 'xmpp-conn-failed'
          when Strophe.Status.AUTHFAIL
            fail id: 'xmpp-auth-failed'
          when Strophe.Status.CONNECTED
            @xmpp.send $pres()
            callback user
            result.resolve user

    login = (obj) =>
      @resources = obj.resources
      $.ajax(
        url: @resources.login
        type: 'POST'
        dataType: 'json'
        data:
          username: username
          password: password
        xhrFields:
          withCredentials: true
      ).then xmpp, error

    get(this.url()).then login, fail
    result.promise()
