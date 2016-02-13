@Docs = new Meteor.Collection 'docs'
@Tags = new Meteor.Collection 'tags'

Meteor.methods
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


FlowRouter.route '/',
    action: (params) ->
        BlazeLayout.render 'layout',
            # top: 'nav'
            main: 'home'

FlowRouter.route '/edit/:docId',
    action: (params) ->
        BlazeLayout.render 'layout',
            # top: 'nav'
            main: 'edit'
