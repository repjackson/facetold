

Meteor.methods
    get_tweets: ->
        twitterConf = ServiceConfiguration.configurations.findOne(service: 'twitter')
        twitter = Meteor.user().services.twitter


        Twit = new TwitMaker(
            consumer_key: twitterConf.consumerKey
            consumer_secret: twitterConf.secret
            access_token: twitter.accessToken
            access_token_secret: twitter.accessTokenSecret
            app_only_auth:true)

        Twit.get 'statuses/user_timeline', {
            screen_name: twitter.screenName
            count: 200
        }, Meteor.bindEnvironment(((err, data, response) ->
            for tweet in data
                id = Docs.insert
                    body: tweet.text
                    authorId: Meteor.userId()
                    screen_name: Meteor.user().profile.name
                Meteor.call 'analyze', id, tweet.text
            ))

        Meteor.users.update Meteor.userId(),
            $set: hasReceivedTweets: true

        return true


    analyze: (id, body)->
        doc = Docs.findOne id
        encoded = encodeURIComponent(body)

        # result = HTTP.call 'POST', 'http://gateway-a.watsonplatform.net/calls/text/TextGetCombinedData', { params:
        HTTP.call 'POST', 'http://access.alchemyapi.com/calls/html/HTMLGetCombinedData', { params:
            apikey: '6656fe7c66295e0a67d85c211066cf31b0a3d0c8'
            # text: encoded
            html: body
            outputMode: 'json'
            # extract: 'entity,keyword,title,author,taxonomy,concept,relation,pub-date,doc-sentiment' }
            extract: 'keyword,taxonomy,concept,doc-sentiment' }
            , (err, result)->
                if err then console.log err
                else
                    keyword_array = _.pluck(result.data.keywords, 'text')
                    concept_array = _.pluck(result.data.concepts, 'text')

                    Docs.update id,
                        $set:
                            docSentiment: result.data.docSentiment
                            language: result.data.language
                            keywords: result.data.keywords
                            concepts: result.data.concepts
                            entities: result.data.entities
                            taxonomy: result.data.taxonomy
                            keyword_array: keyword_array
                            concept_array: concept_array

        # console.log result.data

    # average_sentiment: ->
    #     sentiments = []
    #     arrayAverage = (arr) ->
    #     _.reduce(arr, ((memo, num) ->
    #     memo + num
    #     ), 0) / (if arr.length == 0 then 1 else arr.length)


    clear_my_docs: ->
        Docs.remove({authorId: Meteor.userId()})

        Meteor.users.update Meteor.userId(),
            $set: hasReceivedTweets: false

        return true


    # calc_sent_avg: ->
    #     sentiments = []
    #     Docs.find().map((doc)->
    #         sentiments.push(doc.docSentiment.score)
    #         )
    #     avgSentiments = _.reduce(sentiments, ((memo, num) ->
    #         memo + num
    #         ), 0) / (if sentiments.length == 0 then 1 else sentiments.length)

    #     console.log avgSentiments


Docs.allow
    insert: (userId, doc)-> userId
    update: (userId, doc)-> doc.authorId is Meteor.userId()
    remove: (userId, doc)-> doc.authorId is Meteor.userId()


Meteor.publish 'docs', (selected_keywords, selected_concepts, author_filter)->
    Counts.publish(this, 'doc_counter', Docs.find(), { noReady: true })
    match = {}
    if selected_keywords.length > 0 then match.keyword_array = $all: selected_keywords
    if selected_concepts.length > 0 then match.concept_array = $all: selected_concepts
    if author_filter then match.authorId = author_filter
    Docs.find match,
        limit: 20

Meteor.publish 'doc', (id)-> Docs.find id

Meteor.publish 'people', -> Meteor.users.find {}

Meteor.publish 'person', (id)-> Meteor.users.find id

Meteor.publish 'keywords', (selected_keywords, selected_concepts, author_filter)->
    self = @

    match = {}
    if selected_keywords.length > 0 then match.keyword_array = $all: selected_keywords
    if selected_concepts.length > 0 then match.concept_array = $all: selected_concepts
    if author_filter then match.authorId = author_filter

    cloud = Docs.aggregate [
        { $match: match }
        { $project: keywords: 1 }
        { $unwind: '$keywords' }
        { $group: _id: '$keywords.text', count: $sum: 1 }
        { $match: _id: $nin: selected_keywords }
        { $sort: count: -1, _id: 1 }
        { $limit: 50 }
        { $project: _id: 0, text: '$_id', count: 1 }
        ]

    cloud.forEach (keyword) ->
        self.added 'keywords', Random.id(),
            text: keyword.text
            count: keyword.count

    self.ready()

Meteor.publish 'concepts', (selected_concepts, selected_keywords, author_filter)->
    self = @

    match = {}
    if selected_keywords.length > 0 then match.keyword_array = $all: selected_keywords
    if selected_concepts.length > 0 then match.concept_array = $all: selected_concepts
    if author_filter then match.authorId = author_filter

    cloud = Docs.aggregate [
        { $match: match }
        { $project: concepts: 1 }
        { $unwind: '$concepts' }
        { $group: _id: '$concepts.text', count: $sum: 1 }
        { $match: _id: $nin: selected_concepts }
        { $sort: count: -1, _id: 1 }
        { $limit: 50 }
        { $project: _id: 0, text: '$_id', count: 1 }
        ]

    cloud.forEach (concept) ->
        self.added 'concepts', Random.id(),
            text: concept.text
            count: concept.count

    self.ready()
