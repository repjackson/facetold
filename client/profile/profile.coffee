Template.profile.onCreated ->
    @autorun -> Meteor.subscribe('tweetDocs')


Template.profile.helpers
    viewMyTweetsClass: -> if Meteor.user().profile.name in selected_screen_names.array() then 'active' else ''
    hasReceivedTweets: -> Meteor.user().profile.hasReceivedTweets
    tweetDocCount: -> Docs.find().count()


Template.profile.events
    'click .get_tweets': ->
        Meteor.call 'get_tweets', Meteor.user().profile.name, ->

    'click .delete_tweets': ->
        Meteor.call 'delete_tweets', (err, res)->
            if err then console.log err
            console.log res