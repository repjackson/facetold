Docs.allow
    insert: (userId, doc)-> userId
    update: (userId, doc)-> doc.authorId is Meteor.userId()
    remove: (userId, doc)-> doc.authorId is Meteor.userId()


Meteor.publish 'docs', (selectedDocTags)->
    match = {}
    if selectedDocTags.length > 0 then match.doctags = $all: selectedDocTags
    return Docs.find match,
        limit: 10
        sort:
            timestamp: -1


Meteor.publish 'doctags', (selecteddoctags)->
    self = @
    match = {}

    if selecteddoctags.length > 0 then match.doctags = $all: selecteddoctags

    cloud = Docs.aggregate [
        { $match: match }
        { $project: doctags: 1 }
        { $unwind: '$doctags' }
        { $group: _id: '$doctags', count: $sum: 1 }
        { $match: _id: $nin: selecteddoctags }
        { $sort: count: -1, _id: 1 }
        { $limit: 100 }
        { $project: _id: 0, name: '$_id', count: 1 }
        ]

    cloud.forEach (tag) ->
        self.added 'doctags', Random.id(),
            name: tag.name
            count: tag.count

    self.ready()




Meteor.methods
    generateTags: (postId, text)->
        result = Yaki(text).extract()
        cleaned = Yaki(result).clean()
        lowered = cleaned.map (tag)-> tag.toLowerCase()

        Docs.update postId,
            $set:
                body: text
                doctags: lowered


    sendpoint: (recipient)->
        Meteor.users.update Meteor.userId(), $inc: points: -1
        Meteor.users.update recipient, $inc: points: 1

    savedoc: (docId, text)->
        Docs.update docId,
            $set: body: text

        cloud = Meteor.users.aggregate [
            { $match: _id: Meteor.userId() }
            { $project: docTags: 1 }
            { $unwind: '$docTags' }
            { $group: _id: '$docTags', count: $sum: 1 }
            { $sort: count: -1, _id: 1 }
            { $limit: 100 }
            { $project: _id: 0, name: '$_id', count: 1 } ]

        Meteor.users.update Meteor.userId(),
            $set: cloud: cloud


    addDoc: ->
        newDocId = Docs.insert
            authorId: Meteor.userId()
            body: ''
            doctags: []
            timestamp: Date.now()
        Meteor.users.update Meteor.userId(), $inc: points: -1
        return newDocId

    deletedoc: (docId)->
        Docs.remove docId
        Meteor.users.update Meteor.userId(), $inc: points: 1

