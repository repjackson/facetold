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

    'click .delete_tweets': ->
        Meteor.call 'delete_tweets', (err, res)->
            if err then console.log err
            console.log res