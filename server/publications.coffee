Meteor.publish 'doc', (id)-> Docs.find id

Meteor.publish 'importers', -> Importers.find { authorId: @userId}

Meteor.publish 'importer', (id)-> Importers.find id

Meteor.publish 'people', -> Meteor.users.find {}

Meteor.publish 'person', (id)-> Meteor.users.find id

Meteor.publish 'tweetDocs', ->
    Docs.find
        $and: [
            { authorId: @userId }
            { tags: $in: ['tweet'] }
        ]

Meteor.publish 'docs', (selected_tags, viewMode)->
    Counts.publish(this, 'doc_counter', Docs.find(), { noReady: true })

    match = {}
    if not @userId? then match.personal = false
    if selected_tags.length > 0 then match.tags = $all: selected_tags
    if viewMode is 'mine' then match.authorId = @userId

    Docs.find match,
        limit: 10
        sort: timestamp: -1

Meteor.publish 'tags', (selected_tags, viewMode)->
    self = @

    match = {}
    if selected_tags.length > 0 then match.tags = $all: selected_tags
    if viewMode is 'mine' then match.authorId = @userId
    match.personal = false

    cloud = Docs.aggregate [
        { $match: match }
        { $project: tags: 1 }
        { $unwind: '$tags' }
        { $group: _id: '$tags', count: $sum: 1 }
        { $match: _id: $nin: selected_tags }
        { $sort: count: -1, _id: 1 }
        { $limit: 50 }
        { $project: _id: 0, name: '$_id', count: 1 }
        ]

    cloud.forEach (tag) ->
        self.added 'tags', Random.id(),
            name: tag.name
            count: tag.count

    self.ready()
