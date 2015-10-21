Meteor.users.allow
    update: (userId, doc)-> doc._id is Meteor.userId()
    remove: (userId, doc)-> doc._id is Meteor.userId()

Accounts.onCreateUser (options, user)->
    user =
        points: 100
        unreadcount: 0
    user



Meteor.publish 'allpeople', ->
    Meteor.users.find {},
        fields:
            username: 1,
            profile: 1,
            unreadcount: 1
            points: 1


Meteor.publish 'people', (selectedwants, selectedoffers, selectedplaces) ->
    match= {}
    if selectedwants.length > 0 then match["profile.wants"] = $all: selectedwants
    if selectedoffers.length > 0 then match["profile.offers"] = $all: selectedoffers
    if selectedplaces.length > 0 then match["profile.places"] = $all: selectedplaces

    Meteor.users.find match,
        fields:
            username: 1
            profile: 1
            points: 1

Meteor.publish 'wants', (selectedwants, selectedoffers, selectedplaces)->
    self = @
    match= {}
    if selectedwants.length > 0 then match["profile.wants"] = $all: selectedwants
    if selectedoffers.length > 0 then match["profile.offers"] = $all: selectedoffers
    if selectedplaces.length > 0 then match["profile.places"] = $all: selectedplaces
    match._id= $ne: @userId

    cloud = Meteor.users.aggregate [
        { $match: match }
        { $project: "profile.wants": 1 }
        { $unwind: '$profile.wants' }
        { $group: _id: '$profile.wants', count: $sum: 1 }
        { $match: _id: $nin: selectedwants }
        { $sort: count: -1, _id: 1 }
        { $limit: 100 }
        { $project: _id: 0, name: '$_id', count: 1 } ]
    cloud.forEach (want) -> self.added 'wants', Random.id(), name: want.name, count: want.count
    self.ready()

Meteor.publish 'offers', (selectedwants, selectedoffers, selectedplaces)->
    self = @
    match= {}
    if selectedwants.length > 0 then match["profile.wants"] = $all: selectedwants
    if selectedoffers.length > 0 then match["profile.offers"] = $all: selectedoffers
    if selectedplaces.length > 0 then match["profile.places"] = $all: selectedplaces
    match._id= $ne: @userId


    cloud = Meteor.users.aggregate [
        { $match: match }
        { $project: "profile.offers": 1 }
        { $unwind: '$profile.offers' }
        { $group: _id: '$profile.offers', count: $sum: 1 }
        { $match: _id: $nin: selectedoffers }
        { $sort: count: -1, _id: 1 }
        { $limit: 100 }
        { $project: _id: 0, name: '$_id', count: 1 } ]
    cloud.forEach (offer) -> self.added 'offers', Random.id(), name: offer.name, count: offer.count
    self.ready()

Meteor.publish 'places', (selectedwants, selectedoffers, selectedplaces)->
    self = @
    match= {}
    if selectedwants.length > 0 then match["profile.wants"] = $all: selectedwants
    if selectedoffers.length > 0 then match["profile.offers"] = $all: selectedoffers
    if selectedplaces.length > 0 then match["profile.places"] = $all: selectedplaces
    match._id= $ne: @userId

    cloud = Meteor.users.aggregate [
        { $match: match }
        { $project: "profile.places": 1 }
        { $unwind: '$profile.places' }
        { $group: _id: '$profile.places', count: $sum: 1 }
        { $match: _id: $nin: selectedplaces }
        { $sort: count: -1, _id: 1 }
        { $limit: 100 }
        { $project: _id: 0, name: '$_id', count: 1 } ]
    cloud.forEach (place) -> self.added 'places', Random.id(), name: place.name, count: place.count
    self.ready()

