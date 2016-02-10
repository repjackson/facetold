Template.nav.helpers
    doc_counter: -> Counts.get('doc_counter')
    user_counter: -> Meteor.users.find().count()

Template.nav.events
    'click #addDoc': ->
        Meteor.call 'create', (err, response)->
            FlowRouter.go "/edit/#{response}"