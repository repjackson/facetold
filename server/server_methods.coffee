Meteor.methods
    parseUpload: (data) ->
        # for item in data
            # console.log item

    createDoc: ->
        newId = Docs.insert {}
        newId

    deleteDoc: (id)->
        Docs.remove id

    createImporter: ->
        id = Importers.insert
            tags: []
            timestamp: Date.now()
            authorId: Meteor.userId()
            username: Meteor.user().username
        return id

    saveImporter: (id, importerName, importerTag)->
        Importers.update id,
            $set:
                name: importerName
                importerTag: importerTag

    testImporter: (iId)->
        importer = Importers.findOne iId
        pluckedNames = []
        testDoc = {}
        testDoc.tags = []
        testDoc.tags.push importer.importerTag
        for field in importer.fieldsObject
            if field.tag is true
                testDoc.tags.push field.firstValue
                pluckedNames.push field.name
        Importers.update iId,
            $set:
                testDoc: testDoc
                pluckedNames: pluckedNames

    runImporter: (id, amount=1000)->
        # importer = Importers.findOne id
        # HTTP.call importer.method, importer.url, {}, (err, result)->
        #     if err then console.error err
        #     else
        #         parsedContent = JSON.parse result.content

        #         features = parsedContent.features
        #         # console.log features[0].properties
        #         newDocs = (feature.properties for feature in features)
        #         for doc in newDocs
        #             id = Docs.insert
        #                 body: doc.CASE_DESCR
        #                 authorId: Meteor.userId()
        #                 timestamp: Date.now()
        #                 tags: ['boulder permits', doc.STAFF_EMAI?.toLowerCase(), doc.STAFF_PHON?.toLowerCase(), doc.STAFF_CONT?.toLowerCase(), doc.CASE_NUMBE?.toLowerCase(), doc.CASE_TYPE?.toLowerCase(), doc.APPLICANT_?.toLowerCase(), doc.CASE_ADDRE?.toLowerCase()]
        #             Meteor.call 'analyze', id, true

        importer = Importers.findOne id
        HTTP.get importer.downloadUrl, (err, result)->
            if err then console.error err
            else
                csvToParse = result.content
                # console.log csvToParse
                secondIteration = false
                Papa.parse csvToParse,
                    header: true
                    complete: (results, file) ->
                        if secondIteration then return
                        else
                            # slicedResults = results.data[0..amount]
                            slicedResults = results.data[0..2]
                            fieldNames = _.compact results.meta.fields
                            resultData = results.data
                            # console.log resultData.length
                            for row in resultData
                                tagsToInsert = []
                                tagsToInsert.push importer.importerTag
                                for field, value of row
                                    tagsToInsert.push "#{field}: #{value}"
                                Docs.insert
                                    tags: tagsToInsert
                            # for row in resultData
                            #     for name in fieldNames
                            #         fieldTagsToInsert = []
                            #         fieldTagsToInsert.push importer.importerTag
                            #         fieldTagsToInsert.push row['']
                            #         fieldTagsToInsert.push name
                            #         fieldTagsToInsert.push row[name]
                            #         console.log fieldTagsToInsert
                            #         Docs.insert
                            #             tags: fieldTagsToInsert
                            #     rowTagsToInsert = []
                            #     rowTagsToInsert.push importer.importerTag
                            #     rowTagsToInsert.push row['']
                            #     for name in fieldNames
                            #         # rowTagsToInsert.push name
                            #         rowTagsToInsert.push row[name]
                            #     console.log rowTagsToInsert
                            #     Docs.insert
                            #         tags: rowTagsToInsert



                            #     for name in importer.pluckedNames
                            #         tagsToInsert.push row[name]
                            secondIteration = true

                        # console.log results.data[0]
                        # fieldNames = results.meta.fields
                        # firstValues = _.values(results.data[0])
                        # fields = _.zip(fieldNames, firstValues)
                        # fieldsObject = _.map(fields, (field)->
                        #     name: field[0]
                        #     firstValue: field[1]
                        #     )
                        # Importers.update id,
                        #     $set:
                        #         fileName: name
                        #         fieldsObject: fieldsObject
                        # Meteor.call 'parseUpload', results.data, (err, res) ->
                        #     if err then console.log error.reason
                        #     else
                        #         template.uploading.set false
                        #         Bert.alert 'Upload complete', 'success', 'growl-top-right'

    cleanNonStringTags: ->
        uId = Meteor.userId()

        result = Docs.update({authorId: uId},
            {$pull: tags: $in: [ null ]},
            {multi: true})
        console.log result
        return result

    get_tweets: (screen_name)->
        if not screen_name
            console.error 'No screen name provided'
            return false
        existingDoc = Docs.findOne tags: $all: ['tweet', screen_name]
        if existingDoc
              throw new Meteor.Error('already-imported',"Tweets from #{screen_name} already exist")

        Twit = new TwitMaker(
            consumer_key: Meteor.settings.twitterConsumerKey
            consumer_secret: Meteor.settings.twitterSecret
            access_token: Meteor.settings.twitterAccessToken
            access_token_secret: Meteor.settings.twitterAccessTokenSecret
            app_only_auth:true)

        Twit.get 'statuses/user_timeline', {
            screen_name: screen_name
            count: 200
            include_rts: false
        }, Meteor.bindEnvironment(((err, data, response) ->
            for tweet in data
                id = Docs.insert
                    body: tweet.text
                Docs.update id,
                    $addToSet: tags: $each: ['tweet', screen_name]
                Meteor.call 'analyze', id, tweet.text
            ))



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


    fetchUrlTags: (docId, url)->
        doc = Docs.findOne docId
        HTTP.call 'POST', 'http://gateway-a.watsonplatform.net/calls/url/URLGetRankedKeywords', { params:
            apikey: '6656fe7c66295e0a67d85c211066cf31b0a3d0c8'
            url: url
            keywordExtractMode: 'normal'
            outputMode: 'json'
            showSourceText: 1
            sourceText: 'cleaned_or_raw'
            knowledgeGraph: 0
            extract: 'keyword' }
            , (err, result)->
                if err then console.log err
                else
                    keyword_array = _.pluck(result.data.keywords, 'text')
                    # concept_array = _.pluck(result.data.concepts, 'text')
                    loweredKeywords = _.map(keyword_array, (keyword)->
                        keyword.toLowerCase()
                        )

                    Docs.update docId,
                        $set:
                            body: result.data.text
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

    findDocsWithTag: (tagSelector)->
        match = {}
        # match.authorId = Meteor.userId()
        match.tags = $in: [tagSelector]

        result = {}
        result.count = Docs.find(match).count()
        result.firstDoc = Docs.findOne(match)

        cloud = Docs.aggregate [
            { $match: match }
            { $project: tags: 1 }
            { $unwind: '$tags' }
            { $group: _id: '$tags', count: $sum: 1 }
            { $sort: count: -1, _id: 1 }
            { $limit: 50 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]

        result.cloud = cloud
        return result

    deleteQueryDocs: (query)->
        Docs.remove
            tags: $in: [query]

    generatePersonalCloud: (uid)->
        authored_cloud = Docs.aggregate [
            { $match: authorId: uid }
            { $project: tags: 1 }
            { $unwind: '$tags' }
            { $group: _id: '$tags', count: $sum: 1 }
            { $sort: count: -1, _id: 1 }
            { $limit: 50 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        authored_list = (tag.name for tag in authored_cloud)
        Meteor.users.update Meteor.userId(),
            $set:
                authored_cloud: authored_cloud
                authored_list: authored_list


        upvoted_cloud = Docs.aggregate [
            { $match: up_voters: $in: [Meteor.userId()] }
            { $project: tags: 1 }
            { $unwind: '$tags' }
            { $group: _id: '$tags', count: $sum: 1 }
            { $sort: count: -1, _id: 1 }
            { $limit: 50 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        upvoted_list = (tag.name for tag in upvoted_cloud)
        Meteor.users.update Meteor.userId(),
            $set:
                upvoted_cloud: upvoted_cloud
                upvoted_list: upvoted_list


        downvoted_cloud = Docs.aggregate [
            { $match: down_voters: $in: [Meteor.userId()] }
            { $project: tags: 1 }
            { $unwind: '$tags' }
            { $group: _id: '$tags', count: $sum: 1 }
            { $sort: count: -1, _id: 1 }
            { $limit: 50 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        downvoted_list = (tag.name for tag in downvoted_cloud)
        Meteor.users.update Meteor.userId(),
            $set:
                downvoted_cloud: downvoted_cloud
                downvoted_list: downvoted_list

    calculateUserMatch: (username)->
        myCloud = Meteor.user().cloud
        otherGuy = Meteor.users.findOne "profile.name": username
        console.log username
        console.log otherGuy
        Meteor.call 'generatePersonalCloud', otherGuy._id
        otherCloud = otherGuy.cloud

        myLinearCloud = _.pluck(myCloud, 'name')
        otherLinearCloud = _.pluck(otherCloud, 'name')
        intersection = _.intersection(myLinearCloud, otherLinearCloud)
        console.log intersection


    matchTwoDocs: (firstId, secondId)->
        firstDoc = Docs.findOne firstId
        secondDoc = Docs.findOne secondId

        firstTags = firstDoc.tags
        secondTags = secondDoc.tags

        intersection = _.intersection firstTags, secondTags
        intersectionCount = intersection.length

    findTopDocMatches: (docId)->
        thisDoc = Docs.findOne docId
        tags = thisDoc.tags
        matchObject = {}
        for tag in tags
            idArrayWithTag = []
            Docs.find({ tags: $in: [tag] }, { tags: 1 }).forEach (doc)->
                if doc._id isnt docId
                    idArrayWithTag.push doc._id
            matchObject[tag] = idArrayWithTag
        arrays = _.values matchObject
        flattenedArrays = _.flatten arrays
        countObject = {}
        for id in flattenedArrays
            if countObject[id]? then countObject[id]++ else countObject[id]=1
        # console.log countObject
        result = []
        for id, count of countObject
            comparedDoc = Docs.findOne(id)
            returnedObject = {}
            returnedObject.docId = id
            returnedObject.tags = comparedDoc.tags
            returnedObject.username = comparedDoc.username
            returnedObject.intersectionTags = _.intersection tags, comparedDoc.tags
            returnedObject.intersectionTagsCount = returnedObject.intersectionTags.length
            result.push returnedObject

        result = _.sortBy(result, 'intersectionTagsCount').reverse()
        result = result[0..5]
        Docs.update docId,
            $set: topDocMatches: result

        # console.log result
        return result