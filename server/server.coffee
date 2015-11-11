#Accounts.onCreateUser (options, user)->
    #user


Meteor.methods
    calcusercloud: ->
        cloud = Docs.aggregate [
            { $match: authorId: Meteor.userId() }
            { $project: tags: 1 }
            { $unwind: '$tags' }
            { $group: _id: '$tags', count: $sum: 1 }
            { $sort: count: -1, _id: 1 }
            #{ $limit: 50 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]

        list = (tag.name for tag in cloud)

        Meteor.users.update Meteor.userId(),
            $set:
                cloud: cloud
                tags: list

    suggest_tags: (id, body)->
        doc = Docs.findOne id
        suggested_tags = Yaki(body).extract()
        Docs.update id,
            $set: suggested_tags: suggested_tags

    save: (id, body)->
        doc = Docs.findOne id
        #tags = Yaki(body).extract()
        Docs.update id,
            $set:
                body: body
                #tags: tags


Docs.allow
    insert: (userId, doc)-> userId
    update: (userId, doc)-> doc.authorId is Meteor.userId()
    remove: (userId, doc)-> doc.authorId is Meteor.userId()




Meteor.publish 'docs', (selectedtags, editing, selected_user, user_upvotes, user_downvotes)->
    Counts.publish(this, 'doc_counter', Docs.find(), { noReady: true })
    if editing? then return Docs.find editing
    else
        match = {}
        if user_upvotes then match.up_voters = $in: [user_upvotes]
        if user_downvotes then match.down_voters = $in: [user_downvotes]
        if selected_user then match.authorId = selected_user
        if selectedtags.length > 0 then match.tags = $all: selectedtags
        Docs.find match,
            limit: 5
            sort: time: -1

Meteor.publish 'doc', (id)-> Docs.find id

Meteor.publish 'people', ->
    return Meteor.users.find {},
        fields:
            username: 1



Meteor.publish 'tags', (selectedtags, selected_user, user_upvotes, user_downvotes)->
    self = @

    match = {}
    if user_upvotes then match.up_voters = $in: [user_upvotes]
    if user_downvotes then match.down_voters = $in: [user_downvotes]
    if selected_user then match.authorId = selected_user
    if selectedtags.length > 0 then match.tags = $all: selectedtags

    cloud = Docs.aggregate [
        { $match: match }
        { $project: tags: 1 }
        { $unwind: '$tags' }
        { $group: _id: '$tags', count: $sum: 1 }
        { $match: _id: $nin: selectedtags }
        { $sort: count: -1, _id: 1 }
        { $limit: 100 }
        { $project: _id: 0, name: '$_id', count: 1 }
        ]

    cloud.forEach (tag) ->
        self.added 'tags', Random.id(),
            name: tag.name
            count: tag.count

    self.ready()
