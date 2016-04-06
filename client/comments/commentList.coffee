Template.commentList.onCreated ->
    self = @
    self.autorun ->
        docId = FlowRouter.getParam('docId')
        self.subscribe 'comments', docId

Template.commentList.helpers
    comments: -> Comments.find()


Template.commentList.events
    'keyup #addComment': (e)->
        e.preventDefault
        comment = $('#addComment').val().toLowerCase()
        if e.which is 13
            if message.length > 0
                Comments.insert
                    docId: FlowRouter.getParam 'docId'
                    text: message
                    timestamp: Date.now()
                    authorId: Meteor.userId()
                    username: Meteor.user().username
                $('#addComment').val('')