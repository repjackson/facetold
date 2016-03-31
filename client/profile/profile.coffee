Template.profile.onCreated ->
    @autorun -> Meteor.subscribe 'me'


Template.profile.helpers

    user: -> Meteor.user()

Template.profile.events
    'click #generatePersonalCloud': ->
        Meteor.call 'generatePersonalCloud', Meteor.userId(), ->

    'click .calculateUserMatch': ->
        console.log @
        Meteor.call 'calculateUserMatch', @text, ->
