Meteor.publish 'requests', ->
    Requests.find toId: @userId

Meteor.publishComposite 'request', (requestid)->
    {
        find: -> Requests.find requestid
        children: [
            { find: (request)-> Offersfind request.offerId }
            { find: (request)-> Meteor.users.find request.toId }
            { find: (request)-> Meteor.users.find request.fromId }
        ]
    }

Requests.allow
    insert: (userId, offer)-> userId
    update: (userId, offer)-> true
    remove: (userId, offer)-> true

