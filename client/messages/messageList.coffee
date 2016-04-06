Template.messageList.onCreated ->
    self = @
    self.autorun ->
        docId = FlowRouter.getParam('docId')
        self.subscribe 'messages', docId

Template.messageList.helpers
    messages: -> Messages.find()


Template.messageList.events
    'keyup #addMessage': (e)->
        e.preventDefault
        message = $('#addMessage').val().toLowerCase()
        if e.which is 13
            if message.length > 0
                Messages.insert
                    docId: FlowRouter.getParam 'docId'
                    text: message
                    timestamp: Date.now()
                    authorId: Meteor.userId()
                    username: Meteor.user().username
                $('#addMessage').val('')