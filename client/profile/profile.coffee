Template.profile.onCreated ->
    @autorun -> Meteor.subscribe 'me'
    @autorun -> Meteor.subscribe 'people'


Template.profile.helpers

    user: -> Meteor.user()

    people: -> Meteor.users.find()

Template.profile.events
    'click #generatePersonalCloud': ->
        Meteor.call 'generatePersonalCloud', Meteor.userId(), ->

    'click .matchTwoUsersAuthoredCloud': ->
        Meteor.call 'matchTwoUsersAuthoredCloud', @_id, ->
