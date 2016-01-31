

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

        Twit.get 'search/tweets', {
            q: 'banana since:2011-11-11'
            count: 100
        }, Meteor.bindEnvironment(((err, data, response) ->
            tweets = []
            _.map(data, (tweet)->
                tweets.push(_.pluck(tweet, 'text'))
            )
            extracted_tweets = tweets[0]

            for tweet in extracted_tweets
                id = Docs.insert
                    body: tweet
                Meteor.call 'analyze', id, tweet
            ), ->
              console.log 'Failed to bind environment'
            )


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
            extract: 'entity,keyword,taxonomy,concept,doc-sentiment' }
            , (err, result)->
                if err then console.log err
                else
                    keyword_array = _.pluck(result.data.keywords, 'text')
                    concept_array = _.pluck(result.data.concepts, 'text')

                    debugger

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

    # get_messages: ->
    #     googleConf = ServiceConfiguration.configurations.findOne(service: 'google')
    #     google = Meteor.user().services.google

    #     client = new (GMail.Client)(
    #         clientId: googleConf.clientId
    #         clientSecret: googleConf.secret
    #         accessToken: google.accessToken
    #         expirationDate: google.expiresAt
    #         refreshToken: google.refreshToken)

    #     # console.log client.list('is:sent  after:2015/12/26 before:2016/3/27').map((m) ->
    #     #     m.snippet
    #     #     )

    #     message_list = client.list('is:sent  after:2015/12/26 before:2016/3/27')

    #     # last_message = message_list.pop()
    #     # rawMessage = client.get last_message.id
    #     # parsedMessage = new GMail.Message rawMessage
    #     # # console.log parsedMessage.html
    #     # body = parsedMessage.text
    #     # id = Docs.insert
    #     #     body: parsedMessage.text
    #     #     authorId: Meteor.userId()
    #     # Meteor.call 'analyze', id, body

    #     for message in message_list
    #         rawMessage = client.get message.id
    #         parsedMessage = new GMail.Message rawMessage
    #         body = parsedMessage.text
    #         id = Docs.insert
    #             body: parsedMessage.text
    #             authorId: Meteor.userId()
    #         Meteor.call 'analyze', id, body


    clear_docs: -> Docs.remove({})

    calc_sent_avg: ->
        sentiments = []
        Docs.find().map((doc)->
            sentiments.push(doc.docSentiment.score)
            )
        avgSentiments = _.reduce(sentiments, ((memo, num) ->
            memo + num
            ), 0) / (if sentiments.length == 0 then 1 else sentiments.length)

        console.log avgSentiments
        debugger

Docs.allow
    insert: (userId, doc)-> userId
    update: (userId, doc)-> doc.authorId is Meteor.userId()
    remove: (userId, doc)-> doc.authorId is Meteor.userId()


Meteor.publish 'docs', (selected_keywords, selected_concepts)->
    Counts.publish(this, 'doc_counter', Docs.find(), { noReady: true })
    match = {}
    if selected_keywords.length > 0 then match.keyword_array = $all: selected_keywords
    if selected_concepts.length > 0 then match.concept_array = $all: selected_concepts
    Docs.find match,
        limit: 20

Meteor.publish 'doc', (id)-> Docs.find id

Meteor.publish 'people', -> Meteor.users.find {}

Meteor.publish 'person', (id)-> Meteor.users.find id

Meteor.publish 'keywords', (selected_keywords)->
    self = @

    match = {}
    if selected_keywords.length > 0 then match.keywords = $all: selected_keywords

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

Meteor.publish 'concepts', (selected_concepts)->
    self = @

    match = {}
    if selected_concepts.length > 0 then match.concepts = $all: selected_concepts

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
