#Meteor.startup ->
    #BrowserPolicy.content.allowOriginForAll("https://c9.io")
    #BrowserPolicy.content.allowOriginForAll("https://facet-repjackson-1-7.c9.io")
    #BrowserPolicy.content.allowInlineStyles();
    #BrowserPolicy.content.allowFontDataUrl();


Docs.allow
    insert: (userId, doc)-> userId
    update: (userId, doc)-> doc.authorId is Meteor.userId()
    remove: (userId, doc)-> doc.authorId is Meteor.userId()


Meteor.publish 'docs', (selectedtags, editing)->
    if editing then return Docs.find editing
    match = {}
    if selectedtags.length > 0 then match.tags = $all: selectedtags
    return Docs.find match,
        limit: 10
        sort:
            timestamp: -1


Meteor.publish 'doc', (docId) ->
    Docs.find(docId)

Meteor.publish 'tags', (selectedtags)->
    self = @
    match = {}

    if selectedtags.length > 0 then match.tags = $all: selectedtags

    cloud = Docs.aggregate [
        { $match: match }
        { $project: tags: 1 }
        { $unwind: '$tags' }
        { $group: _id: '$tags', count: $sum: 1 }
        { $match: _id: $nin: selectedtags }
        { $sort: count: -1, _id: 1 }
        { $limit: 50 }
        { $project: _id: 0, name: '$_id', count: 1 }
        ]

    cloud.forEach (tag) ->
        self.added 'tags', Random.id(),
            name: tag.name
            count: tag.count

    self.ready()