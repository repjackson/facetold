Template.viewFull.onCreated ->
    self = @
    self.autorun ->
        docId = FlowRouter.getParam('docId')
        self.subscribe 'doc', docId



Template.viewFull.helpers
    doc: ->
        docId = FlowRouter.getParam('docId')
        Docs.findOne docId

    isAuthor: -> @authorId is Meteor.userId()
    vote_up_button_class: -> if Meteor.userId() in @up_voters then 'active' else ''
    vote_down_button_class: -> if Meteor.userId() in @down_voters then 'active' else ''
    when: -> moment(@timestamp).fromNow()
    doc_tag_class: -> if @valueOf() in selected_tags.array() then 'btn-default active' else 'btn-default'
    author: -> Meteor.users.findOne(@authorId)

Template.viewFull.events
    'click .vote_up': -> Meteor.call 'vote_up', @_id
    'click .vote_down': -> Meteor.call 'vote_down', @_id
