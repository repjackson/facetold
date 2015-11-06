@Requests = new Meteor.Collection 'requests'

Requests.helpers
    requestedoffer: -> Offers.findOne @oid
    requester: -> Meteor.users.findOne @aid

Meteor.methods
    request: (oid)->
        offer = Offers.findOne oid
        newrid = Requests.insert
            aid: Meteor.userId()
            oid: oid
            datetime: ''
            message: ''
            accepted: false
        Meteor.users.update offer.aid, $inc: requests: 1
        Meteor.users.update Meteor.userId(), $inc: number: -1
        return newrid

    accept_request: (rid)->
        request = Requests.findOne rid
        Requests.update rid, $set: accepted: true
        Meteor.users.update Meteor.userId(), $inc: number: 1

    unaccept: (rid)->
        Requests.update rid, $set: accepted: false
        Meteor.users.update Meteor.userId(), $inc: number: -1

    delete_request: (rid)->
        request = Requests.findOne rid
        offer = Offers.findOne request.oid

        Requests.remove rid

        Offers.update offer._id, $pull: current_requesters: Meteor.userId()
        Meteor.users.update Meteor.userId(), $inc: number: 1

    upvote: (rid)->
        request = Requests.findOne rid
        offer = Offers.findOne request.oid

        if Meteor.userId() in offer.downvoters
            Offers.update request.oid,
                $pull: downvoters: Meteor.userId()
                $inc: points: 1

        if Meteor.userId() in offer.upvoters
            Offers.update request.oid,
                $pull: upvoters: Meteor.userId()
                $inc: points: -1
        else
            Offers.update request.oid,
                $addToSet: upvoters: Meteor.userId()
                $inc: points: 1

    downvote: (rid)->
        request = Requests.findOne rid
        offer = Offers.findOne request.oid

        if Meteor.userId() in offer.upvoters
            Offers.update request.oid,
                $pull: upvoters: Meteor.userId()
                $inc: points: -1

        if Meteor.userId() in offer.downvoters
            Offers.update request.oid,
                $pull: downvoters: Meteor.userId()
                $inc: points: 1
        else
            Offers.update request.oid,
                $addToSet: downvoters: Meteor.userId()
                $inc: points: -1
