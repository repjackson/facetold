#Accounts.onCreateUser (options, user)->
    #user


Meteor.methods
    suggest_tags: (id, body)->
        doc = Docs.findOne id
        encoded = encodeURIComponent(body)

        # result = HTTP.call 'POST', 'http://gateway-a.watsonplatform.net/calls/text/TextGetCombinedData', { params:
        result = HTTP.call 'POST', 'http://access.alchemyapi.com/calls/html/HTMLGetCombinedData', { params:
            apikey: 'f2381fc1b71a51bb92fd7e15e836851fc02b14f1'
            # text: encoded
            html: body
            outputMode: 'json'
            extract: 'page-image,image-kw,feed,entity,keyword,title,author,taxonomy,concept,relation,pub-date,doc-sentiment' }

        console.log result.data.language
        suggested_tags = Yaki(body).extract()
        cleaned_suggested_tags = Yaki(suggested_tags).clean()
        uniqued = _.uniq(cleaned_suggested_tags)
        lowered = uniqued.map (tag)-> tag.toLowerCase()

        #lowered = tag.toLowerCase() for tag in uniqued

        Docs.update id,
            $set:
                suggested_tags: lowered
                language: result.data.language
                docSentiment: result.data.docSentiment.type
                docSentimentScore: result.data.docSentiment.score
                keywords: result.data.keywords

    save: (id, body)->
        doc = Docs.findOne id
        tagcount = doc.tags.length
        Docs.update id,
            $set:
                body: body
                tag_count: tagcount

Docs.allow
    insert: (userId, doc)-> userId
    update: (userId, doc)-> doc.authorId is Meteor.userId()
    remove: (userId, doc)-> doc.authorId is Meteor.userId()


Meteor.publish 'docs', (selectedtags, editing, selected_user, user_upvotes, user_downvotes)->
    Counts.publish(this, 'doc_counter', Docs.find(), { noReady: true })
    if editing? then return Docs.find editing
    else
        match = {}
        if selected_user then match.authorId = selected_user
        if selectedtags.length > 0 then match.tags = $all: selectedtags
        Docs.find match,
            limit: 3
            sort:
                tag_count: 1

Meteor.publish 'doc', (id)-> Docs.find id

Meteor.publish 'people', ->
    Meteor.users.find {},
        fields:
            username: 1

Meteor.publish 'person', (id)->
    Meteor.users.find id,
        fields:
            username: 1


Meteor.publish 'tags', (selectedtags, selected_user)->
    self = @

    match = {}
    if selected_user then match.authorId = selected_user
    if selectedtags.length > 0 then match.tags = $all: selectedtags

    cloud = Docs.aggregate [
        { $match: match }
        { $project: tags: 1 }
        { $unwind: '$tags' }
        { $group: _id: '$tags', count: $sum: 1 }
        { $match: _id: $nin: selectedtags }
        { $sort: count: -1, _id: 1 }
        { $limit: 30 }
        { $project: _id: 0, name: '$_id', count: 1 }
        ]

    cloud.forEach (tag) ->
        self.added 'tags', Random.id(),
            name: tag.name
            count: tag.count

    self.ready()
