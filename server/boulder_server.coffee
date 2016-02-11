Docs.allow
    insert: (userId, doc)-> userId
    update: (userId, doc)-> true
    remove: (userId, doc)-> true

Meteor.methods
    'loadBoulderData': ->
        HTTP.get("https://raw.githubusercontent.com/CodeForBoulder/c3po/Meteor/DevelopmentReview.GeoJSON", {}, (err,response)->
            # console.log _.keys response.data
            console.log typeof response.content
            )



Meteor.publish 'permits', (selected_tags)->
    Counts.publish(this, 'doc_counter', Permits.find(), { noReady: true })

    match = {}
    if selected_tags.length > 0 then match.tags = $all: selected_tags
    match.authorId = @userId
    Permits.find match,
        limit: 20
        sort: timestamp: -1

Meteor.publish 'permittags', (selected_tags, selected_user)->
    self = @

    match = {}
    if selected_user then match.authorId = selected_user
    if selected_tags.length > 0 then match.tags = $all: selected_tags
    match.authorId = @userId

    cloud = Permits.aggregate [
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
        self.added 'permittags', Random.id(),
            name: tag.name
            count: tag.count

    self.ready()
