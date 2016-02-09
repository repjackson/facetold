Docs.allow
    insert: (userId, doc)-> userId
    update: (userId, doc)-> doc.authorId is Meteor.userId()
    remove: (userId, doc)-> doc.authorId is Meteor.userId()

Meteor.methods
    save: (tags)->
        id = Docs.insert
            tags: tags
            authorId: Meteor.userId()
            username: Meteor.user().username

        # Meteor.call 'analyze', id

    # analyze: (id)->
    #     doc = Docs.findOne id
    #     encoded = encodeURIComponent(doc.tags)

    #     console.log 'should be looking up ', doc.tags
    #     HTTP.call 'POST', 'http://gateway-a.watsonplatform.net/calls/text/TextGetCombinedData', { params:
    #         apikey: '6656fe7c66295e0a67d85c211066cf31b0a3d0c8'
    #         text: doc.tags.toString()
    #         outputMode: 'json'
    #         # extract: 'entity,keyword,title,author,taxonomy,concept,relation,pub-date,doc-sentiment' }
    #         extract: 'keyword,taxonomy,concept,doc-sentiment' }
    #         , (err, result)->
    #             if err then console.log err
    #             else
    #                 keyword_array = _.pluck(result.data.keywords, 'text')
    #                 concept_array = _.pluck(result.data.concepts, 'text')

    #                 Docs.update id,
    #                     $set:
    #                         docSentiment: result.data.docSentiment
    #                         language: result.data.language
    #                         keywords: result.data.keywords
    #                         concepts: result.data.concepts
    #                         entities: result.data.entities
    #                         taxonomy: result.data.taxonomy
    #                         keyword_array: keyword_array
    #                         concept_array: concept_array


Meteor.publish 'docs', (selected_tags)->
    Counts.publish(this, 'doc_counter', Docs.find(), { noReady: true })

    match = {}
    if selected_tags.length > 0 then match.tags = $all: selected_tags

    Docs.find match, limit: 20

Meteor.publish 'doc', (id)-> Docs.find id

Meteor.publish 'people', -> Meteor.users.find {}

Meteor.publish 'person', (id)-> Meteor.users.find id

Meteor.publish 'tags', (selected_tags, selected_user)->
    self = @

    match = {}
    if selected_user then match.authorId = selected_user
    if selected_tags.length > 0 then match.tags = $all: selected_tags

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
