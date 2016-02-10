Template.nav.helpers
    doc_counter: -> Counts.get('doc_counter')
    user_counter: -> Meteor.users.find().count()

Template.nav.events
    'click #addDoc': ->
        Meteor.call 'create', (err, response)->
            FlowRouter.go "/edit/#{response}"

    'keyup #search': (e)->
        if e.which is 13
            selected_tags.push e.target.value
            $('#search').val('')