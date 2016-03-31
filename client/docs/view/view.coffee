Template.view.onCreated ->
    Meteor.subscribe 'person', @authorId

Template.view.helpers
    isAuthor: -> @authorId is Meteor.userId()
    voteUpButtonClass: -> if Meteor.userId() in @upVoters then 'active' else ''
    voteDownButtonClass: -> if Meteor.userId() in @downVoters then 'active' else ''
    when: -> moment(@timestamp).fromNow()
    docTagClass: -> if @valueOf() in selectedTags.array() then 'btn-default active' else 'btn-default'
    author: -> Meteor.users.findOne(@authorId)

Template.view.events
    'click .editDoc': -> FlowRouter.go "/edit/#{@_id}"

    'click .docTag': -> if @valueOf() in selectedTags.array() then selectedTags.remove @valueOf() else selectedTags.push @valueOf()

    'click .voteDown': -> Meteor.call 'voteDown', @_id
    'click .voteUp': -> Meteor.call 'voteUp', @_id