Template.viewSmall.onCreated ->
    Meteor.subscribe 'person', @authorId

Template.viewSmall.helpers
    isAuthor: -> @authorId is Meteor.userId()

    viewSmallSegmentClass: ->
        if Meteor.userId() in @upVoters then 'green'
        else if Meteor.userId() in @downVoters then 'red'
        else ''

    voteUpButtonClass: ->
        if not Meteor.userId() then 'disabled'
        else if Meteor.userId() in @upVoters then 'green'
        else 'basic'

    voteDownButtonClass: ->
        if not Meteor.userId() then 'disabled'
        else if Meteor.userId() in @downVoters then 'red'
        else 'basic'

    when: -> moment(@timestamp).fromNow()

    docTagClass: ->
        result = ''
        if @valueOf() in selectedTags.array() then result += ' primary' else result += ' basic'
        if Meteor.userId() in Template.parentData(1).upVoters then result += ' green'
        else if Meteor.userId() in Template.parentData(1).downVoters then result += ' red'
        return result

    upVotedMatchList: ->
        myUpVotedList = Meteor.user().upvotedList
        otherUser = Meteor.users.findOne @authorId
        otherUpVotedList = otherUser.upvotedList
        intersection = _.intersection(myUpVotedList, otherUpVotedList)
        return intersection

    upVotedMatchCloud: ->
        myUpVotedCloud = Meteor.user().upvotedCloud
        myUpVotedList = Meteor.user().upvotedList
        # console.log 'myUpVotedCloud', myUpVotedCloud
        otherUser = Meteor.users.findOne @authorId
        otherUpVotedCloud = otherUser.upvotedCloud
        otherUpVotedList = otherUser.upvotedList
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
        result = {}
        result.cloud = sortedCloud
        result.totalCount = totalCount
        return result


    author: -> Meteor.users.findOne(@authorId)

Template.viewSmall.events
    'click .editDoc': -> FlowRouter.go "/edit/#{@_id}"
    'click .viewFull': -> FlowRouter.go "/view/#{@_id}"

    'click .docTag': -> if @valueOf() in selectedTags.array() then selectedTags.remove @valueOf() else selectedTags.push @valueOf()

    'click .voteDown': ->
        if Meteor.userId()
            # if @points is 0 or (@points is 1 and Meteor.userId() in @upVoters)
            #     if confirm 'Confirm downvote? This will delete the doc.'
            #         Meteor.call 'voteDown', @_id
            # else
            Meteor.call 'voteDown', @_id

    'click .voteUp': -> if Meteor.userId() then Meteor.call 'voteUp', @_id

    'click .deleteDoc': ->
        if confirm 'Delete?'
            Meteor.call 'deleteDoc', @_id

    # 'click .togglePersonal': ->
    #     newValue = !@personal
    #     Docs.update @_id,
    #         $set:
    #             personal: newValue

    'click .matchTwoUsersUpvotedCloud': ->
        Meteor.call 'matchTwoUsersUpvotedCloud', @_id, ->

