@Docs = new Meteor.Collection 'docs'
@Tags = new Meteor.Collection 'tags'
#@AuthoredIntersectionTags = new Meteor.Collection 'authored_intersection_tags'
#@UpvotedIntersectionTags = new Meteor.Collection 'upvoted_intersection_tags'
#@DownvotedIntersectionTags = new Meteor.Collection 'downvoted_intersection_tags'

Docs.helpers
    author: -> Meteor.users.findOne @authorId

Meteor.methods
    add: ->
        id = Docs.insert
            authorId: Meteor.userId()
            time: Date.now()
            tags: []
            up_voters: [Meteor.userId()]
            down_voters: []
            points: 1
            suggested_tags: []
            body: ''
        Meteor.call 'calc_user_cloud', ->
        id

    vote_up: (id)->
        doc = Docs.findOne id
        if Meteor.userId() in doc.up_voters #undo upvote
            Docs.update id,
                $pull: up_voters: Meteor.userId()
                $inc: points: -1
        else if Meteor.userId() in doc.down_voters #switch downvote to upvote
            Docs.update id,
                $pull: down_voters: Meteor.userId()
                $addToSet: up_voters: Meteor.userId()
                $inc: points: 2
        else #clean upvote
            Docs.update id,
                $addToSet: up_voters: Meteor.userId()
                $inc: points: 1
        Meteor.call 'calc_user_cloud', ->
        return


    vote_down: (id)->
        doc = Docs.findOne id
        if Meteor.userId() in doc.down_voters #undo downvote
            Docs.update id,
                $pull: down_voters: Meteor.userId()
                $inc: points: 1
        else if Meteor.userId() in doc.up_voters #switch upvote to downvote
            Docs.update id,
                $pull: up_voters: Meteor.userId()
                $addToSet: down_voters: Meteor.userId()
                $inc: points: -2
        else #clean downvote
            Docs.update id,
                $addToSet: down_voters: Meteor.userId()
                $inc: points: -1
        Meteor.call 'calc_user_cloud', ->
        return

