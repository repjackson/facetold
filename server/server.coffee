Meteor.methods
    suggest_tags: (id, body)->
        doc = Docs.findOne id
        suggested_tags = Yaki(body).extract()
        cleaned_suggested_tags = Yaki(suggested_tags).clean()
        uniqued = _.uniq(cleaned_suggested_tags)
        lowered = uniqued.map (tag)-> tag.toLowerCase()

        #lowered = tag.toLowerCase() for tag in uniqued

        Docs.update id,
            $set: suggested_tags: lowered

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


Meteor.publish 'docs', (selectedtags, editing)->
    Counts.publish(this, 'doc_counter', Docs.find(), { noReady: true })
    if editing? then return Docs.find editing
    else
        match = {}
        if selectedtags.length > 0 then match.tags = $all: selectedtags
        Docs.find match,
            limit: 3
            sort:
                tag_count: 1
                points: -1

Meteor.publish 'doc', (id)-> Docs.find id

Meteor.publish 'people', ->
    Meteor.users.find {},
        fields:
            username: 1

Meteor.publish 'person', (id)->
    Meteor.users.find id,
        fields:
            username: 1


Meteor.publish 'tags', (selectedtags)->
    self = @

    match = {}
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