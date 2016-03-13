@Docs = new Meteor.Collection 'docs'
@Tags = new Meteor.Collection 'tags'
@Importers = new Meteor.Collection 'importers'

Docs.before.insert (userId, doc)->
    # doc.tags = []
    # doc.tags = _.map(doc.tags, (tag)-> tag.toString().toLowerCase())
    doc.timestamp = Date.now()
    doc.authorId = Meteor.userId()
    doc.points = 0
    doc.down_voters = []
    doc.up_voters = []
    doc.personal = false
    doc.username = Meteor.user().username
    return