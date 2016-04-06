Template.messageList.onCreated ->
    self = @
    self.autorun ->
        self.subscribe 'messages'

Template.messageList.helpers
    messages: -> Messages.find()


Template.messageList.events
    'keyup #addMessage': (e)->
        e.preventDefault
        message = $('#addMessage').val().toLowerCase()
        recipient = $('#recipient').val()
        if e.which is 13
            if message.length > 0
                Messages.insert
                    text: message
                    timestamp: Date.now()
                    authorId: Meteor.userId()
                    username: Meteor.user().username
                    toId: ''