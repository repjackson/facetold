@Docs = new Meteor.Collection 'docs'
@Tags = new Meteor.Collection 'tags'

Docs.helpers
    author: -> Meteor.users.findOne @authorId

Meteor.methods
    add: ->
        id = Docs.insert
            authorId: Meteor.userId()
            timestamp: Date.now()
            tags: []
            body: ''
        id