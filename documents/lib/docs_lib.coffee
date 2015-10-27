@Docs = new Meteor.Collection 'docs'
@Tags = new Meteor.Collection 'tags'


Meteor.methods
    sendpoint: (recipientId)->
        Meteor.users.update Meteor.userId(), $inc: points: -1
        Meteor.users.update recipientId, $inc: points: 1

    addDoc: ->
        newDocId = Docs.insert
            authorId: Meteor.userId()
            timestamp: Date.now()

        Meteor.users.update Meteor.userId(), $inc: points: -1

        return newDocId

    cloneDoc: (docId)->
        doc = Docs.findOne docId

        newDocId = Docs.insert
            authorId: Meteor.userId()
            body: doc.body
            tags: doc.tags
            timestamp: Date.now()
        Meteor.users.update Meteor.userId(), $inc: points: -1
        return newDocId

    deleteDoc: (docId)->
        Docs.remove docId
        Meteor.users.update Meteor.userId(), $inc: points: 1

    addpart: (docId, part)->
        parts = {}
        parts[part] = {}

        Docs.update docId,
            $addToSet:
                partlist: part
                tags: part
            $set: parts: parts


    removepart: (docId, part)->
        Docs.update docId,
            $pull:
                partlist: part
                tags: part
            $unset: parts: part

