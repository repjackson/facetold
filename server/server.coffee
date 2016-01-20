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

        console.log result.data

        keyword_array = _.pluck(result.data.keywords, 'text')
        console.log keyword_array

        Docs.update id,
            $set:
                language: result.data.language
                doc_sentiment: result.data.docSentiment.type
                doc_sentiment_score: result.data.docSentiment.score
                keywords: result.data.keywords
                keyword_array: keyword_array

    save: (id, body)->
        doc = Docs.findOne id
        keyword_count = doc.keyword_array.length
        Docs.update id,
            $set:
                body: body
                keyword_count: keyword_count

Docs.allow
    insert: (userId, doc)-> userId
    update: (userId, doc)-> doc.authorId is Meteor.userId()
    remove: (userId, doc)-> doc.authorId is Meteor.userId()


Meteor.publish 'docs', (selected_keywords, editing)->
    Counts.publish(this, 'doc_counter', Docs.find(), { noReady: true })
    if editing? then return Docs.find editing
    else
        match = {}
        if selected_keywords.length > 0 then match.keyword_array = $all: selected_keywords
        Docs.find match

Meteor.publish 'doc', (id)-> Docs.find id

Meteor.publish 'people', -> Meteor.users.find {}, fields: username: 1

Meteor.publish 'person', (id)-> Meteor.users.find id, fields: username: 1

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
