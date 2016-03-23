@Docs = new Meteor.Collection 'docs'
@Tags = new Meteor.Collection 'tags'
@Importers = new Meteor.Collection 'importers'
@Messages = new Meteor.Collection 'messages'

Docs.before.insert (userId, doc)->
    # doc.tags = []
    # doc.tags = _.map(doc.tags, (tag)-> tag.toString().toLowerCase())
    doc.timestamp = Date.now()
    doc.authorId = Meteor.userId()
    doc.username = Meteor.user().username
    doc.points = 0
    doc.price = 0
    doc.personal = false
    return

Docs.helpers
    author: (doc)-> Meteor.users.findOne @authorId

Messages.helpers
    from: (doc)-> Meteor.users.findOne @fromId
    to: (doc)-> Meteor.users.findOne @toId
