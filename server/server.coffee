#Accounts.onCreateUser (options, user)->
    #user


Meteor.methods
    calcusercloud: ->
        cloud = Nodes.aggregate [
            { $match: authorId: Meteor.userId() }
            { $project: tags: 1 }
            { $unwind: '$tags' }
            { $group: _id: '$tags', count: $sum: 1 }
            { $sort: count: -1, _id: 1 }
            #{ $limit: 50 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]

        list = (tag.name for tag in cloud)

        Meteor.users.update Meteor.userId(),
            $set:
                cloud: cloud
                tags: list


Nodes.allow
    insert: (userId, node)-> userId
    update: (userId, node)-> node.authorId is Meteor.userId()
    remove: (userId, node)-> node.authorId is Meteor.userId()


Meteor.publishComposite 'nodes', (selectedtags, selected_descendents)->
    {
        find: ->
            match = {}
            if selected_descendents? then match.ancestory= $in: selected_descendents
            if selectedtags.length > 0 then match.tags = $all: selectedtags
            return Nodes.find match, sort: time: -1
        children: [
            {
                find: (node)-> Nodes.find parentId:node._id
            }
        ]
    }


Meteor.publishComposite 'node', (nodeId)->
    {
        find: -> Nodes.find nodeId
        children: [
            { find: (node)-> Nodes.find parentId: node._id }
        ]
    }

Meteor.publish 'people', ->
    return Meteor.users.find {},
        fields:
            username: 1
            cloud: 1
            tags: 1



Meteor.publish 'tags', (selectedtags)->
    self = @

    match = {}
    if selectedtags.length > 0 then match.tags = $all: selectedtags

    cloud = Nodes.aggregate [
        { $match: match }
        { $project: tags: 1 }
        { $unwind: '$tags' }
        { $group: _id: '$tags', count: $sum: 1 }
        { $match: _id: $nin: selectedtags }
        { $sort: count: -1, _id: 1 }
        { $limit: 50 }
        { $project: _id: 0, name: '$_id', count: 1 }
        ]

    cloud.forEach (tag) ->
        self.added 'tags', Random.id(),
            name: tag.name
            count: tag.count

    self.ready()
