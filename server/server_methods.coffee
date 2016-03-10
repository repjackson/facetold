Meteor.methods
    parseUpload: (data) ->
        # for item in data
            # console.log item

    createDoc: ->
        uid = Meteor.userId()
        Docs.insert
            authorId: uid
            username: Meteor.user().profile.name

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
        testDoc = {}
        testDoc.tags = []
        for field in importer.fieldsObject
            if field.tag is true
                testDoc.tags.push field.firstValue
        Importers.update iId,
            $set: testDoc: testDoc
        console.log importer

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

    get_tweets: (screen_name)->
        if not screen_name
            console.error 'No screen name provided'
            return false
        existingDoc = Docs.findOne username: screen_name
        if existingDoc
              throw new Meteor.Error('already-imported','Tweets from author already exist')

        twitterConf = ServiceConfiguration.configurations.findOne(service: 'twitter')
        twitter = Meteor.user().services.twitter


        Twit = new TwitMaker(
            consumer_key: twitterConf.consumerKey
            consumer_secret: twitterConf.secret
            access_token: twitter.accessToken
            access_token_secret: twitter.accessTokenSecret
            app_only_auth:true)

        Twit.get 'statuses/user_timeline', {
            screen_name: screen_name
            count: 200
            include_rts: false
        }, Meteor.bindEnvironment(((err, data, response) ->
            for tweet in data
                id = Docs.insert
                    body: tweet.text
                    username: screen_name
                Docs.update id,
                    $addToSet: tags: 'tweet'
                Meteor.call 'analyze', id, tweet.text
            ))

        if screen_name is Meteor.user().profile.name
            Meteor.users.update Meteor.userId,
                $set: 'profile.hasReceivedTweets': true
        importCount = Docs.find( username: screen_name ).count()
        return importCount


    delete_tweets: ->
        result = Docs.remove
            $and: [
                { username: Meteor.user().profile.name }
                { tags: $in: ['tweet'] }
            ]

        Meteor.users.update Meteor.userId(),
            $set: 'profile.hasReceivedTweets': false

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

    findDocsWithTag: (tagSelector)->
        match = {}
        match.authorId = Meteor.userId()
        match.tags = $in: [tagSelector]

        result = {}
        result.count = Docs.find(match).count()
        result.firstDoc = Docs.findOne(match)

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

        result.cloud = cloud
        return result

    deleteQueryDocs: (query)->
        Docs.remove
            tags: $in: [query]

    generatePersonalCloud: (uid)->
        cloud = Docs.aggregate [
            { $match: authorId: uid }
            { $project: tags: 1 }
            { $unwind: '$tags' }
            { $group: _id: '$tags', count: $sum: 1 }
            { $sort: count: -1, _id: 1 }
            { $limit: 50 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]

        Meteor.users.update uid,
            $set:
                cloud: cloud


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