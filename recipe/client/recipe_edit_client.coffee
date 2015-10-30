Template.recipe_edit.helpers
    recipeobject: ->
        currentDoc = Docs.findOne(Session.get 'editing')
        currentDoc.parts?.recipe?

    pthclass: (val)-> if @preptime is val.toString() and @prepunits is 'hours' then 'blue' else 'basic'
    ptmclass: (val)-> if @preptime is val.toString() and @prepunits is 'mins' then 'blue' else 'basic'

    cthclass: (val)-> if @cooktime is val.toString() and @cookunits is 'hours' then 'blue' else 'basic'
    ctmclass: (val)-> if @cooktime is val.toString() and @cookunits is 'mins' then 'blue' else 'basic'

    totaltimedisplay: ->
        if not @totaltime? then ''
        else if @totaltime < 60 then @totaltime+' mins'
        else
            hours = Math.floor(@totaltime / 60)
            mins = @totaltime % 60
            "#{hours} hours #{mins} mins"

Template.recipe_view.helpers
    totaltimedisplay: ->
        if not @totaltime? then ''
        else if @totaltime < 60 then @totaltime+' mins'
        else
            hours = Math.floor(@totaltime / 60)
            mins = @totaltime % 60
            "#{hours} hours #{mins} mins"

Template.recipe_edit.events
    'keyup #recipename': (e,t)->
        e.preventDefault()
        if e.which is 13
            name = $('#recipename').val()
            docid = Session.get 'editing'

            Docs.update docid, $set: 'parts.recipe.recipename': name

            $('#recipename').val('')

    'keyup #amount, keyup #unit, keyup #ingredient, keyup #descriptor': (e,t)->
        e.preventDefault()
        if e.which is 13
            amount = $('#amount').val()
            unit = $('#unit').val()
            ingredient = $('#ingredient').val()
            descriptor = $('#descriptor').val()

            docid = Session.get 'editing'
            Docs.update docid,
                $addToSet:
                    'parts.recipe.ingredients':
                        amount: amount
                        unit: unit
                        ingredient: ingredient
                        descriptor: descriptor
                    tags: ingredient

            $('#amount').val('')
            $('#unit').val('')
            $('#ingredient').val('')
            $('#descriptor').val('')

    'click .removeingredient': (e,t)->
        docid = Session.get 'editing'
        ingredient = @ingredient
        Docs.update docid,
            $pull:
                'parts.recipe.ingredients': @
                tags: ingredient

    'keyup #addstep': (e,t)->
        e.preventDefault()
        if e.which is 13
            docid = Session.get 'editing'
            step = $('#addstep').val()
            Docs.update docid, $addToSet: 'parts.recipe.steps': step
            $('#addstep').val('')

    'click .removestep': (e,t)->
        docid = Session.get 'editing'
        Docs.update docid, $pull: 'parts.recipe.steps': @valueOf()


    'click .cth': (e,t)->
        cookhours =  e.currentTarget.innerHTML
        docid = Session.get 'editing'
        Docs.update docid,
            $set:
                'parts.recipe.cooktime': cookhours
                'parts.recipe.cookunits': 'hours'
        Meteor.call 'calctime', Session.get 'editing'

    'click .ctm': (e,t)->
        cookmins =  e.currentTarget.innerHTML
        docid = Session.get 'editing'

        Docs.update docid,
            $set:
                'parts.recipe.cooktime': cookmins
                'parts.recipe.cookunits': 'mins'
        Meteor.call 'calctime', Session.get 'editing'


    'click .pth': (e,t)->
        prephours =  e.currentTarget.innerHTML
        docid = Session.get 'editing'
        Docs.update docid,
            $set:
                'parts.recipe.preptime': prephours
                'parts.recipe.prepunits': 'hours'
        Meteor.call 'calctime', Session.get 'editing'

    'click .ptm': (e,t)->
        prephours=  e.currentTarget.innerHTML
        docid = Session.get 'editing'
        Docs.update docid,
            $set:
                'parts.recipe.preptime': prephours
                'parts.recipe.prepunits': 'mins'
        Meteor.call 'calctime', Session.get 'editing'
