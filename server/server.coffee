#Accounts.onCreateUser (options, user)->
    #user


Meteor.methods
    calc_user_cloud: ->
        authored_cloud = Docs.aggregate [
            { $match: authorId: Meteor.userId() }
            { $project: tags: 1 }
            { $unwind: '$tags' }
            { $group: _id: '$tags', count: $sum: 1 }
            { $sort: count: -1, _id: 1 }
            { $limit: 10 }
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
            { $limit: 10 }
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
            { $limit: 10 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        downvoted_list = (tag.name for tag in downvoted_cloud)
        Meteor.users.update Meteor.userId(),
            $set:
                downvoted_cloud: downvoted_cloud
                downvoted_list: downvoted_list


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
        Docs.update id,
            $set:
                body: body


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
            limit: 3
            sort: time: -1

Meteor.publish 'doc', (id)-> Docs.find id

Meteor.publish 'people', ->
    Meteor.users.find {},
        fields:
            username: 1
            downvoted_cloud: 1
            downvoted_list: 1
            upvoted_cloud: 1
            upvoted_list: 1
            authored_cloud: 1
            authored_list: 1

Meteor.publish 'person', (id)->
    Meteor.users.find id,
        fields:
            username: 1
            downvoted_cloud: 1
            downvoted_list: 1
            upvoted_cloud: 1
            upvoted_list: 1
            authored_cloud: 1
            authored_list: 1


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
        { $limit: 20 }
        { $project: _id: 0, name: '$_id', count: 1 }
        ]

    cloud.forEach (tag) ->
        self.added 'tags', Random.id(),
            name: tag.name
            count: tag.count

    self.ready()


#Meteor.publish 'authored_intersection_tags', (authorId)->
    #author_list = Meteor.users.findOne(authorId).authored_list
    #author_tags = Meteor.users.findOne(authorId).authored_cloud
#
    #your_list = Meteor.user().authored_list
    #your_tags = Meteor.user().authored_cloud
#
    #list_intersection = _.intersection(author_list, your_list)
#
    #intersection_tags = []
    #for tag in list_intersection
        #author_count = author_tags.tag.count
        #your_count = your_tags.tag.count
        #lower_value = Meth.min(author_count, your_count)
        #cloud_object = name: tag, count: lower_value
        #intersection_tags.push cloud_object
#
    #console.log intersection_tags
#
    #intersection_tags.forEach (tag) ->
        #self.added 'authored_intersection_tags', Random.id(),
            #name: tag.name
            #count: tag.count
#
    #self.ready()
