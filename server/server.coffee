Docs.allow
    insert: (userId, doc)-> doc.authorId is Meteor.userId()
    update: (userId, doc)-> doc.authorId is Meteor.userId()
    remove: (userId, doc)-> doc.authorId is Meteor.userId()

Importers.allow
    insert: (userId, doc)-> doc.authorId is Meteor.userId()
    update: (userId, doc)-> doc.authorId is Meteor.userId()
    remove: (userId, doc)-> doc.authorId is Meteor.userId()






