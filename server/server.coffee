Docs.allow
    insert: (userId, doc)-> doc.authorId is Meteor.userId()
    update: (userId, doc)-> doc.authorId is Meteor.userId()
    remove: (userId, doc)-> doc.authorId is Meteor.userId()



Meteor.publish 'doc', (id)-> Docs.find id


Meteor.publish 'people', ->
    Meteor.users.find {},
        fields:
            upvotedCloud: 1
            points: 1
            username: 1
            upVotedCloudMatches: 1
            upvotedList: 1

Meteor.publish 'person', (id)->
    Meteor.users.find id,
        fields:
            username: 1
            upvotedCloud: 1
            points: 1
            upVotedCloudMatches: 1
            upvotedList: 1

Meteor.publish 'me', ->
    Meteor.users.find @userId,
        fields:
            username: 1
            upvotedCloud: 1
            points: 1
            upVotedCloudMatches: 1
            upvotedList: 1

Meteor.publish 'docs', (selectedTags, selectedUsernames, viewMode)->
    match = {}
    if selectedTags.length > 0 then match.tags = $all: selectedTags
    if selectedUsernames.length > 0 then match.username = $in: selectedUsernames
    match.tagCount = $gt: 0
    switch viewMode
        when 'mine' then match.authorId = @userId
        when 'unvoted'
            match.upVoters = $nin: [@userId]
            match.downVoters = $nin: [@userId]

    Docs.find match,
        limit: 5
        sort:
            tagCount: 1
            points: -1
            timestamp: -1

Meteor.publish 'usernames', (selectedTags, selectedUsernames, viewMode)->
    self = @

    match = {}
    if selectedTags.length > 0 then match.tags = $all: selectedTags
    if selectedUsernames.length > 0 then match.username = $in: selectedUsernames

    cloud = Docs.aggregate [
        { $match: match }
        { $project: username: 1 }
        { $group: _id: '$username', count: $sum: 1 }
        { $match: _id: $nin: selectedUsernames }
        { $sort: count: -1, _id: 1 }
        { $limit: 50 }
        { $project: _id: 0, text: '$_id', count: 1 }
        ]

    cloud.forEach (username) ->
        self.added 'usernames', Random.id(),
            text: username.text
            count: username.count
    self.ready()





# count combining attempt
# Meteor.publish 'tags', (selectedTags, viewMode)->
#     self = @

#     match = {}
#     if selectedTags.length > 0 then match.tags = $all: selectedTags
#     switch viewMode
#         when 'mine' then match.authorId = @userId
#         when 'unvoted'
#             match.upVoters = $nin: [@userId]
#             match.downVoters = $nin: [@userId]

#     cloud = Docs.aggregate [
#         { $match: match }
#         { $project: tags: 1, points: 1 }
#         { $unwind: '$tags' }
#         {
#             $group:
#                 _id:'$tags'
#                 count: $sum:1
#                 tagPoints: $sum:'$points'
#         }
#         { $match: _id: $nin: selectedTags }
#         # { $sort: count: -1, _id: 1 }
#         { $limit: 50 }
#         { $project: _id:0, name:'$_id', count:1 , countPlusPoints: '$add':['$count', '$tagPoints'] }
#         { $sort: countPlusPoints: -1 }
#         ]

#     cloud.forEach (tag, i) ->
#         self.added 'tags', Random.id(),
#             name: tag.name
#             count: tag.count
#             countPlusPoints: tag.countPlusPoints
#             index: i

#     self.ready()




Meteor.publish 'tags', (selectedTags, selectedUsernames, viewMode)->
    self = @

    match = {}
    if selectedTags.length > 0 then match.tags = $all: selectedTags
    if selectedUsernames.length > 0 then match.username = $in: selectedUsernames
    switch viewMode
        when 'mine' then match.authorId = @userId
        when 'unvoted'
            match.upVoters = $nin: [@userId]
            match.downVoters = $nin: [@userId]

    cloud = Docs.aggregate [
        { $match: match }
        { $project: tags: 1 }
        { $unwind: '$tags' }
        { $group: _id: '$tags', count: $sum: 1 }
        { $match: _id: $nin: selectedTags }
        { $sort: count: -1, _id: 1 }
        { $limit: 50 }
        { $project: _id: 0, name: '$_id', count: 1 }
        ]

    cloud.forEach (tag, i) ->
        self.added 'tags', Random.id(),
            name: tag.name
            count: tag.count
            index: i


    self.ready()



Meteor.methods
    createDoc: (tags=[])->
        Docs.insert
            tags: tags

    deleteDoc: (id)->
        Docs.remove id


    generatePersonalCloud: (uid)->
        # authoredCloud = Docs.aggregate [
        #     { $match: authorId: uid }
        #     { $project: tags: 1 }
        #     { $unwind: '$tags' }
        #     { $group: _id: '$tags', count: $sum: 1 }
        #     { $sort: count: -1, _id: 1 }
        #     { $limit: 50 }
        #     { $project: _id: 0, name: '$_id', count: 1 }
        #     ]
        # authoredList = (tag.name for tag in authoredCloud)
        # Meteor.users.update Meteor.userId(),
        #     $set:
        #         authoredCloud: authoredCloud
        #         authoredList: authoredList


        upvotedCloud = Docs.aggregate [
            { $match: upVoters: $in: [Meteor.userId()] }
            { $project: tags: 1 }
            { $unwind: '$tags' }
            { $group: _id: '$tags', count: $sum: 1 }
            { $sort: count: -1, _id: 1 }
            { $limit: 100 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        upvotedList = (tag.name for tag in upvotedCloud)
        Meteor.users.update Meteor.userId(),
            $set:
                upvotedCloud: upvotedCloud
                upvotedList: upvotedList


        # downvotedCloud = Docs.aggregate [
        #     { $match: downVoters: $in: [Meteor.userId()] }
        #     { $project: tags: 1 }
        #     { $unwind: '$tags' }
        #     { $group: _id: '$tags', count: $sum: 1 }
        #     { $sort: count: -1, _id: 1 }
        #     { $limit: 50 }
        #     { $project: _id: 0, name: '$_id', count: 1 }
        #     ]
        # downvotedList = (tag.name for tag in downvotedCloud)
        # Meteor.users.update Meteor.userId(),
        #     $set:
        #         downvotedCloud: downvotedCloud
        #         downvotedList: downvotedList

    # calculateUserMatchOld: (username)->
    #     myCloud = Meteor.user().cloud
    #     otherGuy = Meteor.users.findOne "profile.name": username
    #     console.log username
    #     console.log otherGuy
    #     Meteor.call 'generatePersonalCloud', otherGuy._id
    #     otherCloud = otherGuy.cloud

    #     myLinearCloud = _.pluck(myCloud, 'name')
    #     otherLinearCloud = _.pluck(otherCloud, 'name')
    #     intersection = _.intersection(myLinearCloud, otherLinearCloud)
    #     console.log intersection


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

    matchTwoUsersAuthoredCloud: (uId)->
        username = Meteor.users.findOne(uId).username
        match = {}
        match.authorId = $in: [Meteor.userId(), uId]

        userMatchAuthoredCloud = Docs.aggregate [
            { $match: match }
            { $project: tags: 1 }
            { $unwind: '$tags' }
            { $group: _id: '$tags', count: $sum: 1 }
            { $sort: count: -1, _id: 1 }
            { $limit: 50 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        # authoredList = (tag.name for tag in userMatchAuthoredCloud)
        Meteor.users.update Meteor.userId(),
            $addToSet:
                authoredCloudMatches:
                    uId: uId
                    username: username
                    userMatchAuthoredCloud: userMatchAuthoredCloud

    matchTwoUsersUpvotedCloud: (uId)->
        username = Meteor.users.findOne(uId).username
        match = {}
        match.upVoters = $in: [Meteor.userId(), uId]

        userMatchUpvotedCloud = Docs.aggregate [
            { $match: match }
            { $project: tags: 1 }
            { $unwind: '$tags' }
            { $group: _id: '$tags', count: $sum: 1 }
            { $sort: count: -1, _id: 1 }
            { $limit: 50 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        Meteor.users.update Meteor.userId(),
            $addToSet:
                upVotedCloudMatches:
                    uId: uId
                    username: username
                    userMatchUpvotedCloud: userMatchUpvotedCloud

