Meteor.methods
    add_offer: ->
        oid = Offers.insert
            aid: Meteor.userId()
            time: Date.now()
            tags: []
            points: 0
            upvoters: []
            downvoters: []
        oid