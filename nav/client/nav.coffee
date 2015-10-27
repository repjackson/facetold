    Template.nav.onCreated ->
        @autorun -> Meteor.subscribe 'person', Meteor.userId()
        selectedtags = new ReactiveArray []


    Template.nav.helpers
        user: -> Meteor.user()

    Template.nav.events
        'click #addDoc': -> Meteor.call 'addDoc', (err, newDocId)->
            if err then throw new Meteor.Error err
            FlowRouter.go '/edit/'+newDocId

