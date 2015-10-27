Meteor.methods
    addingredient: (docId, amount, name)->
        Docs.update { _id: docId, "bodyparts.name": "recipe" },
            $push:
                "bodyparts.$.ingredients":
                    amount: amount
                    name: name
            $addToSet:
                tags: name

    removeingredient: (docId, ingredient)->
        Docs.update { _id: docId, "bodyparts.name": "recipe" },
            $pull:
                "bodyparts.$.ingredients": ingredient
                tags: ingredient.name

    addstep: (docId, step)->
        Docs.update { _id: docId, "bodyparts.name": "recipe" },
            $push:
                "bodyparts.$.steps": step
            $addToSet:
                tags: step

    removestep: (docId, step)->
        Docs.update { _id: docId, "bodyparts.name": "recipe" },
            $pull:
                "bodyparts.$.steps": step
                tags: step

