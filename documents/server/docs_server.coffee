Docs.allow
    insert: (userId, doc)-> userId
    update: (userId, doc)-> doc.authorId is Meteor.userId()
    remove: (userId, doc)-> doc.authorId is Meteor.userId()


Meteor.publish 'docs', (selectedDocTags)->
    match = {}
    if selectedDocTags.length > 0 then match.docTags = $all: selectedDocTags
    return Docs.find match,
        limit: 10
        sort:
            timestamp: -1


Meteor.publish 'doc', (docId) ->
    Docs.find(docId)

Meteor.publish 'docTags', (selecteddocTags)->
    self = @
    match = {}

    if selecteddocTags.length > 0 then match.docTags = $all: selecteddocTags

    cloud = Docs.aggregate [
        { $match: match }
        { $project: docTags: 1 }
        { $unwind: '$docTags' }
        { $group: _id: '$docTags', count: $sum: 1 }
        { $match: _id: $nin: selecteddocTags }
        { $sort: count: -1, _id: 1 }
        { $limit: 50 }
        { $project: _id: 0, name: '$_id', count: 1 }
        ]

    cloud.forEach (tag) ->
        self.added 'docTags', Random.id(),
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
                docBody: text
                docTags: lowered


    saveDoc: (docId, text)->
        Docs.update docId,
            $set: body: text

        docCloud = Docs.aggregate [
            { $match: authorId: Meteor.userId() }
            { $project: docTags: 1 }
            { $unwind: '$docTags' }
            { $group: _id: '$docTags', count: $sum: 1 }
            { $sort: count: -1, _id: 1 }
            { $limit: 50 }
            { $project: _id: 0, name: '$_id', count: 1 } ]

        Meteor.users.update Meteor.userId(),
            $set: docCloud: docCloud


    voteUp: (docId)->
        my = Meteor.user()
        #undo upvote
        if Meteor.user().upVotes and docId in Meteor.user().upVotes
            Docs.update docId,
                $inc: points: -1
                $pull: upVoters: Meteor.userId()
            Meteor.users.update Meteor.userId(),
                $pull: upVotes: docId
            return
        else
            Docs.update docId,
                $inc: points: 1
                $addToSet: upVoters: Meteor.userId()
            Meteor.users.update Meteor.userId(),
                $addToSet: upVotes: docId
            return