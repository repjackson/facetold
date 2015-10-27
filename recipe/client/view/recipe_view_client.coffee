Template.recipe_view.helpers
    recipeobject: ->
        console.log @
        #currentDoc = Docs.findOne(FlowRouter.getParam('docId'))
        #_.findWhere currentDoc.bodyparts, name: "recipe"


Template.recipe_view.events
    'keyup #recipename': (e,t)->
        e.preventDefault()
        if e.which is 13
            name = $('#recipename').val()
            Meteor.call 'updateName', FlowRouter.getParam('docId'), name
            $('#recipename').val('')

    'keyup #ingredientamount': (e,t)->
        e.preventDefault()
        if e.which is 13
            amount = $('#ingredientamount').val()
            name = $('#ingredientname').val()

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
