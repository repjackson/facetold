    Template.nav.onCreated ->
        @autorun -> Meteor.subscribe 'person', Meteor.userId()

    Template.nav.helpers
        user: -> Meteor.user()





