Template.profile.onCreated ->
    @autorun -> Meteor.subscribe 'me'
    @autorun -> Meteor.subscribe 'people'


Template.profile.helpers
    user: -> Meteor.user()

    people: -> Meteor.users.find()

    matchedUsersList:->
        users = Meteor.users.find({_id: $ne: Meteor.userId()}).fetch()
        userMatchClouds = []
        for user in users
            # console.log user.upvotedCloud
            # console.log user.upvotedList
            upvotedIntersection = _.intersection(user.upvotedList, Meteor.user().upvotedList)
            userMatchClouds.push
                matchedUser: user.username
                cloudIntersection: upvotedIntersection
                length: upvotedIntersection.length
        sortedList = _.sortBy(userMatchClouds, 'length').reverse()
        return sortedList

Template.profile.events
    # 'click #generatePersonalCloud': ->
    #     Meteor.call 'generatePersonalCloud', Meteor.userId(), ->

    # 'click .matchTwoUsersAuthoredCloud': ->
    #     Meteor.call 'matchTwoUsersAuthoredCloud', @_id, ->

    'click .matchTwoUsersUpvotedCloud': ->
        Meteor.call 'matchTwoUsersUpvotedCloud', @_id, ->
