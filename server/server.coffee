Accounts.onCreateUser (options, user)->
    user.number = 10
    user.requests = 0
    user


Meteor.methods
    calcusercloud: ->
        cloud = Offersaggregate [
            { $match: aid: Meteor.userId() }
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


Offers.allow
    insert: (userId, offer)-> userId
    update: (userId, offer)-> offer.aid is Meteor.userId()
    remove: (userId, offer)-> offer.aid is Meteor.userId()


Meteor.publishComposite 'offers', (selectedtags)->
    {
        find: ->
            match = {}
            if selectedtags.length > 0 then match.tags = $all: selectedtags
            return Offers.find match, sort: time: -1
        children: [
            {
                find: (offer)-> Requests.find oid:offer._id
                children: [
                    { find: (request)-> Meteor.users.find request.toId }
                    { find: (request)-> Meteor.users.find request.fromId }
                ]
            }
        ]
    }


Meteor.publishComposite 'offer', (oid)->
    {
        find: -> Offers.find oid
        children: [
            { find: (offer)-> Requests.find oid: offer._id }
        ]
    }

Meteor.publish 'people', ->
    return Meteor.users.find {},
        fields:
            username: 1
            cloud: 1
            tags: 1
            number: 1
            requests: 1



Meteor.publish 'tags', (selectedtags)->
    self = @

    match = {}
    if selectedtags.length > 0 then match.tags = $all: selectedtags

    cloud = Offers.aggregate [
        { $match: match }
        { $project: tags: 1 }
        { $unwind: '$tags' }
        { $group: _id: '$tags', count: $sum: 1 }
        { $match: _id: $nin: selectedtags }
        { $sort: count: -1, _id: 1 }
        { $limit: 50 }
        { $project: _id: 0, name: '$_id', count: 1 }
        ]

    cloud.forEach (tag) ->
        self.added 'tags', Random.id(),
            name: tag.name
            count: tag.count

    self.ready()
