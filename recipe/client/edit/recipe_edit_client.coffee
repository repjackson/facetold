Template.recipe_edit.helpers
    recipeobject: ->
        currentDoc = Docs.findOne(FlowRouter.getParam('docId'))
        currentDoc.parts?.recipe

    pthclass: (val)-> if @preptime is val.toString() and @prepunits is 'hours' then 'active' else 'basic'
    ptmclass: (val)-> if @preptime is val.toString() and @prepunits is 'mins' then 'active' else 'basic'

    cthclass: (val)-> if @cooktime is val.toString() and @cookunits is 'hours' then 'active' else 'basic'
    ctmclass: (val)-> if @cooktime is val.toString() and @cookunits is 'mins' then 'active' else 'basic'


Template.recipe_edit.events
    'keyup #recipename': (e,t)->
        e.preventDefault()
        if e.which is 13
            name = $('#recipename').val()
            docid = FlowRouter.getParam('docId')

            Docs.update docid, $set: 'parts.recipe.recipename': name

            $('#recipename').val('')

    'keyup #ingredientamount': (e,t)->
        e.preventDefault()
        if e.which is 13
            amount = $('#ingredientamount').val()
            name = $('#ingredientname').val()

            Docs.update docid, $set: 'parts.recipe.recipename': name
            Meteor.call 'addingredient', FlowRouter.getParam('docId'), amount, name

            $('#ingredientname').val('')
            $('#ingredientamount').val('')

    'keyup #ingredientname': (e,t)->
        e.preventDefault()
        if e.which is 13
            amount = $('#ingredientamount').val()
            name = $('#ingredientname').val()

            Meteor.call 'addingredient', FlowRouter.getParam('docId'), amount, name

            $('#ingredientamount').val('')
            $('#ingredientname').val('')

    'click .removeingredient': (e,t)->
            Meteor.call 'removeingredient', FlowRouter.getParam('docId'), @

    'keyup #addstep': (e,t)->
        e.preventDefault()
        if e.which is 13
            step = $('#addstep').val()

            Meteor.call 'addstep', FlowRouter.getParam('docId'), step

            $('#addstep').val('')

    'click .removestep': (e,t)->
            Meteor.call 'removestep', FlowRouter.getParam('docId'), @valueOf()

    'click .cth': (e,t)->
        cookhours =  e.currentTarget.innerHTML
        docid = FlowRouter.getParam('docId')
        Docs.update docid,
            $set:
                'parts.recipe.cooktime': cookhours
                'parts.recipe.cookunits': 'hours'

    'click .ctm': (e,t)->
        cookmins=  e.currentTarget.innerHTML
        docid = FlowRouter.getParam('docId')
        Docs.update docid,
            $set:
                'parts.recipe.cooktime': cookmins
                'parts.recipe.cookunits': 'mins'

    'click .pth': (e,t)->
        prephours =  e.currentTarget.innerHTML
        docid = FlowRouter.getParam('docId')
        Docs.update docid,
            $set:
                'parts.recipe.preptime': prephours
                'parts.recipe.prepunits': 'hours'

    'click .ptm': (e,t)->
        prephours=  e.currentTarget.innerHTML
        docid = FlowRouter.getParam('docId')
        Docs.update docid,
            $set:
                'parts.recipe.preptime': prephours
                'parts.recipe.prepunits': 'mins'
