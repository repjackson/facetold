Meteor.publish 'messages', ->
    Messages.find
        toId: @userId

Meteor.methods
    sendmessage: (recipientId, text)->
        Messages.insert
            toId: recipientId
            fromId: Meteor.userId()
            text: text
            read: false

        Meteor.users.update recipientId, $inc: unreadcount: 1
        Meteor.users.update Meteor.userId(),
            $inc: points: -1

    deletemessage: (messageId)->
        message = Messages.findOne messageId
        if message.read is false
            Meteor.users.update Meteor.userId(), $inc: unreadcount: -1

        Messages.remove messageId

    markread: (messageId)->
        Messages.update messageId, $set: read: true
        Meteor.users.update Meteor.userId(), $inc: unreadcount: -1

    markunread: (messageId)->
        Messages.update messageId, $set: read: false
        Meteor.users.update Meteor.userId(), $inc: unreadcount: 1