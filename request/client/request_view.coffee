Template.request_view.helpers
    isRequestAuthor: -> Meteor.userId() is @aid

    requester: -> Meteor.users.findOne @aid

    is_editing: -> Session.set 'editing', @_id

    can_see_message: ->
        offer = Offers.findOne @oid
        Meteor.userId() is offer.aid or Meteor.userId() is @aid

    isRequestedDocAuthor: ->
        offer = Offers.findOne @oid
        Meteor.userId() is offer.aid

    canmessage: ->
        offer = Offers.findOne @oid
        Meteor.userId() is @fromId or Meteor.userId() is offer.aid

    thumbsupclass: ->
        offer = Offers.findOne @oid
        if Meteor.userId() in offer.upvoters then '' else 'outline'

    thumbsdownclass: ->
        offer = Offers.findOne @oid
        if Meteor.userId() in offer.downvoters then '' else 'outline'



Template.request_view.events
    'click .accept_request': (e,t)-> Meteor.call 'accept_request', @_id

    'click .delete_request': (e,t)-> Meteor.call 'delete_request', @_id

    'click .unaccept': (e,t)-> Meteor.call 'unaccept', @_id

    'click .editrequest': (e,t)-> Session.set 'editing', @_id

    'click .voteup': (e,t)-> Meteor.call 'upvote', @_id, ->

    'click .votedown': (e,t)-> Meteor.call 'downvote', @_id, ->