Meteor.publish 'marketitems', (selecteditemtags)->
    match = {}
    if selecteditemtags.length > 0 then match.doctags = $all: selecteditemtags
    return Marketitems.find match,
        limit: 10
        sort:
            timestamp: -1

Meteor.publish 'item', (itemId) ->
    Marketitems.find(itemId)



Meteor.methods
    generateItemTags: (itemId, text)->
        result = Yaki(text).extract()
        cleaned = Yaki(result).clean()
        lowered = cleaned.map (tag)-> tag.toLowerCase()

        Docs.update postId,
            $set:
                body: text
                doctags: lowered
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
