Meteor.methods
    add_node: ->
        nodeId = Nodes.insert
            parentId: ''
            ancestory: []
            authorId: Meteor.userId()
            time: Date.now()
            tags: []
            points: 0
        nodeId