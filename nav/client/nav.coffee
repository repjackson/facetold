    Template.nav.onCreated ->
        @autorun -> Meteor.subscribe 'allpeople'
    Template.nav.events
        'click #adddoc': -> Meteor.call 'addDoc', (err, newDocId)->
            if err then throw new Meteor.Error err
            FlowRouter.go '/editdoc/'+newDocId

        'click #addItem': -> Meteor.call 'addItem', (err, newItemId)->
            if err then throw new Meteor.Error err
            FlowRouter.go '/edititem/'+newItemId

    Template.nav.helpers
        user: -> Meteor.user()





