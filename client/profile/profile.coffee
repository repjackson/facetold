Template.profile.onCreated ->
    @autorun -> Meteor.subscribe 'me'


Template.profile.helpers
    viewMyTweetsClass: -> if Meteor.user().profile.name in selected_screen_names.array() then 'active' else ''
    hasReceivedTweets: -> Meteor.user().profile.hasReceivedTweets
    userCloud: -> if Meteor.user().cloud then Meteor.user().cloud


Template.profile.events
    'click .get_tweets': ->
        Meteor.call 'get_tweets', Meteor.user().profile.name, ->

    'click #generatePersonalCloud': ->
        Meteor.call 'generatePersonalCloud', Meteor.userId(), ->

    'click .calculateUserMatch': ->
        console.log @
        Meteor.call 'calculateUserMatch', @text, ->

    'click .delete_tweets': ->
        Meteor.call 'delete_tweets', (err, res)->
            if err then console.log err
            console.log res