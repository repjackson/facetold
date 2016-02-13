Template.view.onCreated ->
    Meteor.subscribe 'person', @authorId

Template.view.helpers
    isAuthor: -> @authorId is Meteor.userId()
    vote_up_button_class: -> if Meteor.userId() is @authorId or not Meteor.userId() then 'disabled' else ''
    vote_up_icon_class: -> if Meteor.userId() and @up_voters and Meteor.userId() in @up_voters then '' else 'outline'
    vote_down_button_class: -> if Meteor.userId() is @authorId or not Meteor.userId() then 'disabled' else ''
    vote_down_icon_class: -> if Meteor.userId() and @down_voters and Meteor.userId() in @down_voters then '' else 'outline'
    when: -> moment(@timestamp).fromNow()
    doc_tag_class: -> if @valueOf() in selected_tags.array() then 'grey' else ''

Template.view.events
    'click .deletePost': -> if confirm 'Delete Post?' then Docs.remove @_id
    'click .cloneDoc': ->
        if confirm 'Clone Post?'
            id = Docs.insert
                tags: @tags
                timestamp: Date.now()
                authorId: Meteor.userId()
                username: Meteor.user().username
                points: 0
                down_voters: []
                up_voters: []
            FlowRouter.go "/edit/#{id}"
    'click .vote_up': -> Meteor.call 'vote_up', @_id
    'click .vote_down': -> Meteor.call 'vote_down', @_id
    'click .doc_tag': -> if @valueOf() in selected_tags.array() then selected_tags.remove @valueOf() else selected_tags.push @valueOf()
    'click .editDoc': -> FlowRouter.go "/edit/#{@_id}"
