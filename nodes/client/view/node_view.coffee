Template.node_view.helpers
    children: -> Nodes.find parentId: @_id

    is_editing: -> Session.equals 'editing',@_id

    isAuthor: -> Meteor.userId() is @authorId

    when:-> moment(@time).fromNow()


Template.node_view.events
    'click .edit': -> Session.set 'editing', @_id

    'click .add_child_node': (e,t) -> Meteor.call 'add_child_node', @_id

    'click .view_descendents': (e,t) -> selected_descendents.push @_id
