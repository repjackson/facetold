Docs.allow
    insert: (userId, doc)-> doc.authorId is Meteor.userId()
    update: (userId, doc)-> doc.authorId is Meteor.userId()
    remove: (userId, doc)-> doc.authorId is Meteor.userId()


Meteor.publish 'doc', (id)-> Docs.find id

Meteor.publish 'people', ->
    Meteor.users.find {},
        fields:
            authored_cloud: 1
            upvoted_cloud: 1
            downvoted_cloud: 1
            points: 1
            username: 1

Meteor.publish 'person', (id)->
    Meteor.users.find id,
        fields:
            username: 1
            authored_cloud: 1
            upvoted_cloud: 1
            downvoted_cloud: 1
            points: 1

Meteor.publish 'me', ->
    Meteor.users.find @userId,
        fields:
            username: 1
            authored_cloud: 1
            upvoted_cloud: 1
            downvoted_cloud: 1
            points: 1

Meteor.publish 'docs', (selectedTags, viewMode)->
    match = {}
    if selectedTags.length > 0 then match.tags = $all: selectedTags
    switch viewMode
        when 'mine' then match.authorId = @userId

    Docs.find match,
        limit: 10
        sort: timestamp: -1

Meteor.publish 'tags', (selectedTags, viewMode)->
    self = @

    match = {}
    if selectedTags.length > 0 then match.tags = $all: selectedTags
    switch viewMode
        when 'mine' then match.authorId = @userId

    cloud = Docs.aggregate [
        { $match: match }
        { $project: tags: 1 }
        { $unwind: '$tags' }
        { $group: _id: '$tags', count: $sum: 1 }
        { $match: _id: $nin: selectedTags }
        { $sort: count: -1, _id: 1 }
        { $limit: 25 }
        { $project: _id: 0, name: '$_id', count: 1 }
        ]

    cloud.forEach (tag, i) ->
        self.added 'tags', Random.id(),
            name: tag.name
            count: tag.count
            index: i

    self.ready()


Meteor.methods
    createDoc: ->
        newId = Docs.insert {}
        newId

    deleteDoc: (id)->
        Docs.remove id


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
