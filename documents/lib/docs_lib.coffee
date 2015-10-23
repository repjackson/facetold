Meteor.methods
    sendpoint: (recipientId)->
        Meteor.users.update Meteor.userId(), $inc: points: -1
        Meteor.users.update recipientId, $inc: points: 1

    addDoc: ->
        newDocId = Docs.insert
            authorId: Meteor.userId()
            body: ''
            docTags: []
            timestamp: Date.now()
        Meteor.users.update Meteor.userId(), $inc: points: -1
        return newDocId

    cloneDoc: (docId)->
        doc = Docs.findOne docId

        newDocId = Docs.insert
            authorId: Meteor.userId()
            body: doc.body
            docTags: doc.docTags
            timestamp: Date.now()
        Meteor.users.update Meteor.userId(), $inc: points: -1
        return newDocId

    deleteDoc: (docId)->
        Docs.remove docId
        Meteor.users.update Meteor.userId(), $inc: points: 1

