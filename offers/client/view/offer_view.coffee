Template.offer_view.helpers
    requests: -> Requests.find oid: @_id

    requester: -> Meteor.users.findOne @aid

    can_edit: ->
        request = Requests.findOne oid: @_id
        if request then false else true

    is_editing: -> Session.equals 'editing',@_id

    isAuthor: -> Meteor.userId() is @aid

    can_request: ->
        request = Requests.findOne
            oid: @_id
            aid: Meteor.userId()


        if request? or Meteor.user().number < 1 then false else true

    when:-> moment(@time).fromNow()


Template.offer_view.events
    'click .edit': -> Session.set 'editing', @_id

    'click .request': (e,t) ->
        Meteor.call 'request', @_id, (err,rid)->
            Session.set 'editing', rid