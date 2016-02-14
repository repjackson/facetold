@Docs = new Meteor.Collection 'docs'
@Tags = new Meteor.Collection 'tags'


Meteor.methods
    create: ->
        id = Docs.insert
            tags: []
            timestamp: Date.now()
            authorId: Meteor.userId()
            username: Meteor.user().username
        return id
