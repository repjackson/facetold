Docs.allow
    insert: (userId, doc)-> doc.authorId is Meteor.userId()
    update: (userId, doc)-> doc.authorId is Meteor.userId()
    remove: (userId, doc)-> doc.authorId is Meteor.userId()

Importers.allow
    insert: (userId, doc)-> doc.authorId is Meteor.userId()
    update: (userId, doc)-> doc.authorId is Meteor.userId()
    remove: (userId, doc)-> doc.authorId is Meteor.userId()

Docs.before.insert (userId, doc)->
    doc.tags = []
    doc.timestamp = Date.now()
    doc.authorId = Meteor.userId()
    doc.points = 0
    doc.down_voters = []
    doc.up_voters = []
    doc.username = Meteor.user().username



Meteor.methods
    create: ->
        id = Docs.insert
        return id

    createImporter: ->
        id = Importers.insert
            tags: []
            timestamp: Date.now()
            authorId: Meteor.userId()
            username: Meteor.user().username
        return id

    saveImporter: (id, url, method)->
        Importers.update id,
            $set:
                url: url
                method: method

    runImporter: (id)->
        importer = Importers.findOne id
        HTTP.call importer.method, importer.url, {}, (err, result)->
            if err then console.error err
            else
                parsedContent = JSON.parse result.content

                features = parsedContent.features
                # console.log features[0].properties
                newDocs = (feature.properties for feature in features)
                for doc in newDocs
                    id = Docs.insert
                        body: doc.CASE_DESCR
                        authorId: Meteor.userId()
                        timestamp: Date.now()
                        tags: ['boulder permits', doc.STAFF_EMAI?.toLowerCase(), doc.STAFF_PHON?.toLowerCase(), doc.STAFF_CONT?.toLowerCase(), doc.CASE_NUMBE?.toLowerCase(), doc.CASE_TYPE?.toLowerCase(), doc.APPLICANT_?.toLowerCase(), doc.CASE_ADDRE?.toLowerCase()]
                    Meteor.call 'analyze', id, true

    cleanNonStringTags: ->
        uId = Meteor.userId()

        result = Docs.update({authorId: uId},
            {$pull: tags: $in: [ null ]},
            {multi: true})
        console.log result
        return result

    analyze: (id, auto)->
        doc = Docs.findOne id
        encoded = encodeURIComponent(doc.body)

        # result = HTTP.call 'POST', 'http://gateway-a.watsonplatform.net/calls/text/TextGetCombinedData', { params:
        HTTP.call 'POST', 'http://access.alchemyapi.com/calls/html/HTMLGetCombinedData', { params:
            apikey: '6656fe7c66295e0a67d85c211066cf31b0a3d0c8'
            html: doc.body
            outputMode: 'json'
            extract: 'keyword' }
            , (err, result)->
                if err then console.log err
                else
                    keyword_array = _.pluck(result.data.keywords, 'text')
                    # concept_array = _.pluck(result.data.concepts, 'text')
                    loweredKeywords = _.map(keyword_array, (keyword)->
                        keyword.toLowerCase()
                        )

                    Docs.update id,
                        $addToSet:
                            keyword_array: $each: loweredKeywords
                            tags: $each: loweredKeywords


    makeSuggestionsTagsIndividual: (id)->
        doc = Docs.findOne id
        Docs.update id,
            $addToSet:
                tags: doc.keyword_array

    makeSuggestionsTagsBulk: ->
        uId = Meteor.userId()

        result = Docs.update({authorId: uId},
            {$pull: tags: $in: [ null ]},
            {multi: true})
        console.log result
        return result





Meteor.publish 'doc', (id)-> Docs.find id

Meteor.publish 'importers', -> Importers.find {}

Meteor.publish 'importer', (id)-> Importers.find id

Meteor.publish 'people', ->
    Meteor.users.find {},
        fields: 'username': 1

Meteor.publish 'docs', (selected_tags, viewMode)->
    Counts.publish(this, 'doc_counter', Docs.find(), { noReady: true })

    match = {}
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
