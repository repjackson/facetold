@Docs = new Meteor.Collection 'docs'
@Tags = new Meteor.Collection 'tags'

Docs.helpers
    author: -> Meteor.users.findOne @authorId


Meteor.methods
    add: ->
        id = Docs.insert
            authorId: Meteor.userId()
            time: Date.now()
            tags: []
            suggested_tags: []
            body: ''
        id