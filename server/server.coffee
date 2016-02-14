Docs.allow
    insert: (userId, doc)-> userId
    update: (userId, doc)-> doc.authorId is Meteor.userId()
    remove: (userId, doc)-> doc.authorId is Meteor.userId()

Meteor.methods
    save: (docId, body)->
        Docs.update docId,
            $set: body: body

        doc = Docs.findOne docId


        encoded = encodeURIComponent(doc.body)

        # result = HTTP.call 'POST', 'http://gateway-a.watsonplatform.net/calls/text/TextGetCombinedData', { params:
        returnedDoc = HTTP.call 'POST', 'http://access.alchemyapi.com/calls/html/HTMLGetCombinedData', { params:
            apikey: '6656fe7c66295e0a67d85c211066cf31b0a3d0c8'
            html: doc.body
            outputMode: 'json'
            extract: 'keyword' }
            , (err, result)->
                if err then console.log err
                else
                    keyword_array = _.pluck(result.data.keywords, 'text')

                    lowered_keywords = keyword_array.map (keyword)-> keyword.toLowerCase()

                    Docs.update docId,
                        $set:
                            tags: lowered_keywords

Meteor.publish 'docs', (selected_tags, editing)->
    if editing then Docs.find editing
    else
        match = {}
        if selected_tags.length > 0 then match.tags = $all: selected_tags
        # match.authorId = @userId
        Docs.find match,
            limit: 3
            sort: timestamp: -1


Meteor.publish 'doc', (id)-> Docs.find id

Meteor.publish 'tags', (selected_tags, selected_user)->
    self = @

    match = {}
    if selected_user then match.authorId = selected_user
    if selected_tags.length > 0 then match.tags = $all: selected_tags
    # match.authorId = @userId

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
