@Nodes = new Meteor.Collection 'nodes'
@Tags = new Meteor.Collection 'tags'

Nodes.helpers
    author: -> Meteor.users.findOne @authorId
    parent: -> Nodes.findOne @parentId

Meteor.methods
    'add_child_node': (parentId)->
        parent = Nodes.findOne parentId
        newancestory = parent.ancestory.concat parentId

        Nodes.insert
            ancestory: newancestory
            parentId: parentId
            tags: []
            authorId: Meteor.userId()
            time: Date.now()