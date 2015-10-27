Meteor.methods
    addreview: (docId, recipename)->
        Docs.update { _id: docId, "bodyparts.name": "recipe" },
            $set: "bodyparts.$.recipename": recipename
