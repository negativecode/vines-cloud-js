class PubSub
  constructor: (@xmpp, @domain, @name) ->

  create: ->
    node = this.xml """
      <iq type='set' to='#{@domain}'>
        <pubsub xmlns='http://jabber.org/protocol/pubsub'>
          <create node=''/>
        </pubsub>
      </iq>
    """
    $('create', node).attr 'node', @name
    this.sendIQ node, (result) =>

  remove: ->
    node = this.xml """
      <iq type='set' to='#{@domain}'>
        <pubsub xmlns='http://jabber.org/protocol/pubsub'>
          <delete node=''/>
        </pubsub>
      </iq>
    """
    $('delete', node).attr 'node', @name
    this.sendIQ node, (result) ->

  publish: (obj) ->
    node = this.xml """
      <iq type='set' to='#{@domain}'>
        <pubsub xmlns='http://jabber.org/protocol/pubsub'>
          <publish node=''>
            <item>
              <payload xmlns='http://getvines.com/cloud'></payload>
            </item>
          </publish>
        </pubsub>
      </iq>
    """
    $('publish', node).attr 'node', @name
    $('payload', node).text JSON.stringify(obj)
    this.sendIQ node, (result) ->

  subscribe: ->
    node = this.xml """
      <iq type='set' to='#{@domain}'>
        <pubsub xmlns='http://jabber.org/protocol/pubsub'>
          <subscribe node='' jid='#{@xmpp.jid}'/>
        </pubsub>
      </iq>
    """
    $('subscribe', node).attr 'node', @name
    this.sendIQ node, (result) ->

  unsubscribe: ->
    node = this.xml """
      <iq type='set' to='#{@domain}'>
        <pubsub xmlns='http://jabber.org/protocol/pubsub'>
          <unsubscribe node='' jid='#{@xmpp.jid}'/>
        </pubsub>
      </iq>
    """
    $('unsubscribe', node).attr 'node', @name
    this.sendIQ node, (result) ->

  xml: (xml) -> $.parseXML(xml).documentElement

  sendIQ: (node, callback) ->
    @xmpp.sendIQ node, callback, callback, 5000
