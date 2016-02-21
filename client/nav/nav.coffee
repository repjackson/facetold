Template.nav.onRendered ->
    $('.button-collapse').sideNav();


Template.nav.helpers
    doc_counter: -> Counts.get('doc_counter')
    user_counter: -> Meteor.users.find().count()

Template.nav.events
    'click #addDoc': ->
        Meteor.call 'create', (err, response)->
            FlowRouter.go "/edit/#{response}"

    'keyup #search': (e)->
        switch e.which
            when 13
                if e.target.value is 'clear'
                    selected_tags.clear()
                    $('#search').val('')
                else
                    selected_tags.push e.target.value
                    $('#search').val('')
            when 8
                if e.target.value is ''
                    selected_tags.pop()