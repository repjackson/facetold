    Template.nav.onCreated ->
        @autorun -> Meteor.subscribe 'person', Meteor.userId()

    Template.nav.helpers
        user: -> Meteor.user()

    Template.nav.events
        'click #addDoc': ->
            newdocid = Docs.insert
                authorId: Meteor.userId()
                timestamp: Date.now()

            Session.set 'editing', newdocid

