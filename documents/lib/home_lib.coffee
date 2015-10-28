@Docs = new Meteor.Collection 'docs'
@Tags = new Meteor.Collection 'tags'


Meteor.methods
    sendpoint: (recipientId)->
        Meteor.users.update Meteor.userId(), $inc: points: -1
        Meteor.users.update recipientId, $inc: points: 1

    addDoc: ->
        newdocid = Docs.insert
            authorId: Meteor.userId()
            timestamp: Date.now()

        Meteor.users.update Meteor.userId(), $inc: points: -1

        return newdocid

    cloneDoc: (docid)->
        doc = Docs.findOne docid

        newdocid = Docs.insert
            authorId: Meteor.userId()
            body: doc.body
            tags: doc.tags
            timestamp: Date.now()
        Meteor.users.update Meteor.userId(), $inc: points: -1
        return newdocid

    deleteDoc: (docid)->
        Docs.remove docid
        Meteor.users.update Meteor.userId(), $inc: points: 1

    addpart: (docid, part)->
        parts = {}
        parts[part] = {}

        Docs.update docid,
            $addToSet:
                partlist: part
                tags: part
            $set: parts: parts


    removepart: (docid, part)->
        Docs.update docid,
            $pull:
                partlist: part
                tags: part
            $unset: parts: part

