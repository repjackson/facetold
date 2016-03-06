Template.profile.helpers
    viewMyTweetsClass: -> if Meteor.user().profile.name in selected_screen_names.array() then 'active' else ''
    hasReceivedTweets: -> Meteor.user().hasReceivedTweets

Template.profile.events
    'click .get_tweets': ->
        Meteor.call 'get_tweets', Meteor.user().profile.name, ->
