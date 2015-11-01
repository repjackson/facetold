Meteor.methods
    calcusercloud: ->
        cloud = Docs.aggregate [
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


Docs.allow
    insert: (userId, doc)-> userId
    update: (userId, doc)-> doc.authorId is Meteor.userId()
    remove: (userId, doc)-> doc.authorId is Meteor.userId()


Meteor.publish 'docs', (selectedtags, editing)->
    if editing then return Docs.find editing
    match = {}
    if selectedtags.length > 0 then match.tags = $all: selectedtags
    return Docs.find match,
        sort:
            time: -1

Meteor.publish 'people', (selectedtags)->
    match = {}
    if selectedtags.length > 0 then match.tags = $all: selectedtags
    return Meteor.users.find match,
        fields:
            username: 1
            cloud: 1
            tags: 1



Meteor.publish 'tags', (selectedtags, mode)->
    self = @

    if mode is 'mydocs'
        match = {}
        if selectedtags.length > 0 then match.tags = $all: selectedtags
        cloud = Docs.aggregate [
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

    else if mode is 'people'
        match = {}
        if selectedtags.length > 0 then match.tags = $all: selectedtags
        cloud = Meteor.users.aggregate [
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