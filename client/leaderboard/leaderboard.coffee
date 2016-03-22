Template.leaderboard.onCreated ->
    self = @
    self.autorun ->
        self.subscribe 'leaderboard'

Template.leaderboard.helpers
    users: -> Meteor.users.find {}, sort: points: -1
