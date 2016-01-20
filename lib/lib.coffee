@Docs = new Meteor.Collection 'docs'
<<<<<<< HEAD
@Keywords = new Meteor.Collection 'keywords'
=======
@Tags = new Meteor.Collection 'tags'
>>>>>>> master

Docs.helpers
    author: -> Meteor.users.findOne @authorId

Meteor.methods
    add: ->
        id = Docs.insert
            authorId: Meteor.userId()
<<<<<<< HEAD
            time: Date.now()
            body: ''
        id
=======
            timestamp: Date.now()
            tags: []
            body: ''
        id
>>>>>>> master
