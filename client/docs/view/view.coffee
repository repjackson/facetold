Template.view.onCreated ->
    Meteor.subscribe 'person', @authorId

Template.view.helpers
    isAuthor: -> @authorId is Meteor.userId()

    voteUpButtonClass: ->
        if not Meteor.userId() then 'disabled'
        else if Meteor.userId() in @upVoters then 'active btn-success'
        else ''

    voteDownButtonClass: ->
        if not Meteor.userId() then 'disabled'
        else if Meteor.userId() in @downVoters then 'active btn-danger'
        else ''

    when: -> moment(@timestamp).fromNow()

    docTagClass: -> if @valueOf() in selectedTags.array() then 'btn-default active' else 'btn-default'

    author: -> Meteor.users.findOne(@authorId)

Template.view.events
    'click .editDoc': -> FlowRouter.go "/edit/#{@_id}"

    'click .docTag': -> if @valueOf() in selectedTags.array() then selectedTags.remove @valueOf() else selectedTags.push @valueOf()

    'click .voteDown': ->
        if Meteor.userId()
            if @points is 0 or (@points is 1 and Meteor.userId() in @upVoters)
                if confirm 'Confirm downvote? This will delete the doc.'
                    Meteor.call 'voteDown', @_id
            else
                Meteor.call 'voteDown', @_id

    'click .voteUp': -> if Meteor.userId() then Meteor.call 'voteUp', @_id

    'click .deleteDoc': ->
        if confirm 'Delete?'
            Meteor.call 'deleteDoc', @_id