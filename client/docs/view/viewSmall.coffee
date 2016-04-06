Template.viewSmall.onCreated ->
    Meteor.subscribe 'person', @authorId

Template.viewSmall.helpers
    isAuthor: -> @authorId is Meteor.userId()

    voteUpButtonClass: ->
        if not Meteor.userId() then 'disabled'
        else if Meteor.userId() in @upVoters then 'green'
        else 'basic'

    voteDownButtonClass: ->
        if not Meteor.userId() then 'disabled'
        else if Meteor.userId() in @downVoters then 'red'
        else 'basic'

    when: -> moment(@timestamp).fromNow()

    docTagClass: -> if @valueOf() in selectedTags.array() then 'blue' else ''

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

