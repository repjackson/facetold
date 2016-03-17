Template.nav.onCreated ->
    self = @
    self.autorun ->
        self.subscribe 'people'


Template.nav.helpers
    doc_counter: -> Counts.get('doc_counter')
    user_counter: -> Meteor.users.find().count()
    userperson: -> Meteor.user()

Template.nav.events
    'click #addDoc': ->
        Meteor.call 'createDoc', (err, id)->
            if err
                console.log err
            else
                analytics.track 'Added Doc'
                FlowRouter.go "/edit/#{id}"

    'keyup #search': (e)->
        e.preventDefault()
        switch e.which
            when 13
                if e.target.value is 'clear'
                    selected_tags.clear()
                    $('#search').val('')
                else
                    selected_tags.push e.target.value.toLowerCase()
                    $('#search').val('')
            when 8
                if e.target.value is ''
                    selected_tags.pop()
