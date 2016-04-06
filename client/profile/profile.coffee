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

    upVotedMatchCloud: ->
        users = Meteor.users.find({_id: $ne: Meteor.userId()}).fetch()
        userMatchClouds = []
        for user in users
            myUpVotedCloud = Meteor.user().upvotedCloud
            myUpVotedList = Meteor.user().upvotedList
            # console.log 'myUpVotedCloud', myUpVotedCloud
            otherUpVotedCloud = user.upvotedCloud
            otherUpVotedList = user.upvotedList
            # console.log 'otherCloud', otherUpVotedCloud
            intersection = _.intersection(myUpVotedList, otherUpVotedList)
            intersectionCloud = []
            totalCount = 0
            for tag in intersection
                myTagObject = _.findWhere myUpVotedCloud, name: tag
                hisTagObject = _.findWhere otherUpVotedCloud, name: tag
                # console.log hisTagObject.count
                min = Math.min(myTagObject.count, hisTagObject.count)
                totalCount += min
                intersectionCloud.push
                    tag: tag
                    min: min
            sortedCloud = _.sortBy(intersectionCloud, 'min').reverse()
            userMatchClouds.push
                matchedUser: user.username
                cloudIntersection: sortedCloud
                totalCount: totalCount


        sortedCloud = _.sortBy(userMatchClouds, 'totalCount').reverse()
        return sortedCloud


Template.profile.events
    # 'click #generatePersonalCloud': ->
    #     Meteor.call 'generatePersonalCloud', Meteor.userId(), ->

    # 'click .matchTwoUsersAuthoredCloud': ->
    #     Meteor.call 'matchTwoUsersAuthoredCloud', @_id, ->

    'click .matchTwoUsersUpvotedCloud': ->
        Meteor.call 'matchTwoUsersUpvotedCloud', @_id, ->
