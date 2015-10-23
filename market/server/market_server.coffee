Marketitems.allow
    insert: (userId, doc)-> userId
    update: (userId, doc)-> doc.authorId is Meteor.userId()
    remove: (userId, doc)-> doc.authorId is Meteor.userId()


Meteor.publish 'marketItems', (selectedItemTags)->
    match = {}
    if selectedItemTags.length > 0 then match.itemTags = $all: selectedItemTags
    return Marketitems.find match,
        limit: 10
        sort:
            timestamp: -1

Meteor.publish 'item', (itemId) ->
    Marketitems.find(itemId)

Meteor.publish 'itemTags', (selectedItemTags)->
    self = @
    match = {}

    if selectedItemTags.length > 0 then match.itemTags = $all: selectedItemTags

    cloud = Marketitems.aggregate [
        { $match: match }
        { $project: itemTags: 1 }
        { $unwind: '$itemTags' }
        { $group: _id: '$itemTags', count: $sum: 1 }
        { $match: _id: $nin: selectedItemTags }
        { $sort: count: -1, _id: 1 }
        { $limit: 50 }
        { $project: _id: 0, name: '$_id', count: 1 }
        ]

    cloud.forEach (tag) ->
        self.added 'itemTags', Random.id(),
            name: tag.name
            count: tag.count

    self.ready()


Meteor.methods
    generateItemTags: (itemId, text)->
        result = Yaki(text).extract()
        cleaned = Yaki(result).clean()
        lowered = cleaned.map (tag)-> tag.toLowerCase()

        Marketitems.update itemId,
            $set:
                itemBody: text
                itemTags: lowered

    addItem: ->
        newItemId = Marketitems.insert
            authorId: Meteor.userId()
            itemBody: ''
            itemTags: []
            timestamp: Date.now()
            bought: false
            buyer: ''
            price: 0

        Meteor.users.update Meteor.userId(), $inc: points: -1
        return newItemId

    saveItem: (docId, text, price)->
        Marketitems.update docId,
            $set:
                itemBody: text
                price: price

        marketCloud = Marketitems.aggregate [
            { $match: authorId: Meteor.userId() }
            { $project: itemTags: 1 }
            { $unwind: '$itemTags' }
            { $group: _id: '$itemTags', count: $sum: 1 }
            { $sort: count: -1, _id: 1 }
            { $limit: 50 }
            { $project: _id: 0, name: '$_id', count: 1 } ]

        Meteor.users.update Meteor.userId(),
            $set: marketCloud: marketCloud

    deleteItem: (itemId)->
        Marketitems.remove itemId
        Meteor.users.update Meteor.userId(), $inc: points: 1


    buyItem: (itemId)->
        item = Marketitems.findOne itemId

        Meteor.users.update Meteor.userId(), $inc: point: -item.price
        Meteor.users.update item.authorId, $inc: point: item.price
        return
