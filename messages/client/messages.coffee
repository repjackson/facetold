
Template.messages.onCreated ->
    @autorun -> Meteor.subscribe 'messages'
Template.messages.helpers
    messages: -> Messages.find()

Template.message.helpers
    humansent: -> moment(@sent).fromNow()
Template.message.events
    'click .markread': -> Meteor.call 'markread', @_id, ->
    'click .markunread': -> Meteor.call 'markunread', @_id, ->
    'click .deletemessage': -> Meteor.call 'deletemessage', @_id, ->

