


Meteor.methods
    analyze: (id, body)->
        doc = Docs.findOne id
        encoded = encodeURIComponent(body)

        # result = HTTP.call 'POST', 'http://gateway-a.watsonplatform.net/calls/text/TextGetCombinedData', { params:
        result = HTTP.call 'POST', 'http://access.alchemyapi.com/calls/html/HTMLGetCombinedData', { params:
            apikey: 'f2381fc1b71a51bb92fd7e15e836851fc02b14f1'
            # text: encoded
            html: body
            outputMode: 'json'
            extract: 'page-image,image-kw,feed,entity,keyword,title,author,taxonomy,concept,relation,pub-date,doc-sentiment' }

        # console.log result.data

        keyword_array = _.pluck(result.data.keywords, 'text')
        concept_array = _.pluck(result.data.concepts, 'text')

        debugger

        Docs.update id,
            $set:
                language: result.data.language
                doc_sentiment: result.data.docSentiment.type
                doc_sentiment_score: result.data.docSentiment.score
                keywords: result.data.keywords
                keyword_array: keyword_array
                concept_array: concept_array
                relations: result.data.relations

    save: (id, body)->
        doc = Docs.findOne id
        keyword_count = doc.keyword_array.length
        Docs.update id,
            $set:
                body: body
                keyword_count: keyword_count

    get_gmail_messages: ->
        googleConf = ServiceConfiguration.configurations.findOne(service: 'google')
        google = Meteor.user().services.google

        # console.log Meteor.user().services
        client = new (GMail.Client)(
            clientId: googleConf.clientId
            clientSecret: googleConf.secret
            accessToken: google.accessToken
            expirationDate: google.expiresAt
            refreshToken: google.refreshToken)

        message_list = client.list({ labelIds: 'INBOX' })
        last_message = message_list.pop()

        # console.log message_list

        # console.log message.payload.body for message in message_list


        rawMessage = client.get last_message.id
        parsedMessage = new GMail.Message rawMessage
        # console.log parsedMessage.html

        body = parsedMessage.text

        id = Docs.insert
            body: parsedMessage.text
            authorId: Meteor.userId()


        Meteor.call 'analyze', id, body

        # for message in message_list
        #     rawMessage = client.get message.id
        #     parsedMessage = new GMail.Message rawMessage
        #     # console.log parsedMessage.html

        #     body = parsedMessage.text

        #     id = Docs.insert
        #         body: parsedMessage.text

        #     Meteor.call 'analyze', id, body
        # console.log parsedMessage



Docs.allow
    insert: (userId, doc)-> userId
    update: (userId, doc)-> doc.authorId is Meteor.userId()
    remove: (userId, doc)-> doc.authorId is Meteor.userId()


Meteor.publish 'docs', (selected_keywords)->
    Counts.publish(this, 'doc_counter', Docs.find(), { noReady: true })
    match = {}
    if selected_keywords.length > 0 then match.keyword_array = $all: selected_keywords
    Docs.find match,
        limit: 10

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
        { $limit: 30 }
        { $project: _id: 0, text: '$_id', count: 1 }
        ]

    cloud.forEach (keyword) ->
        self.added 'keywords', Random.id(),
            text: keyword.text
            count: keyword.count

    self.ready()
