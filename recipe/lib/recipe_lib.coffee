Meteor.methods
    calctime: (docid)->
        doc = Docs.findOne docid
        if doc.parts.recipe.cookunits is 'hours' then cooktimemins = doc.parts.recipe.cooktime * 60
        else cooktimemins = doc.parts.recipe.cooktime

        if doc.parts.recipe.prepunits is 'hours' then preptimemins = doc.parts.recipe.preptime * 60
        else preptimemins = doc.parts.recipe.preptime

        totaltime = parseInt(preptimemins) + parseInt(cooktimemins)

        Docs.update docid, $set: 'parts.recipe.totaltime': totaltime