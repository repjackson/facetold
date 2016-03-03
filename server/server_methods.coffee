Meteor.methods
    parseUpload: (data) ->
        # for item in data
            # console.log item

    createDoc: ->
        uid = Meteor.userId()
        Docs.insert
            authorId: uid

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
