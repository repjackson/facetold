Template.nav.onCreated ->
    self = @
    self.autorun ->
        self.subscribe 'people'


Template.nav.helpers
    doc_counter: -> Counts.get('doc_counter')
    user_counter: -> Meteor.users.find().count()
    user: -> Meteor.user()
    tagsettings: -> {
        position: 'bottom'
        limit: 10
        rules: [
            {
                collection: Tags
                field: 'name'
                template: Template.tagresult
            }
        ]
    }



Template.nav.events
    'keyup #quickAdd': (e,t)->
        e.preventDefault
        tag = $('#quickAdd').val().toLowerCase()
        switch e.which
            when 13
                splitTags = tag.match(/\S+/g);
                $('#quickAdd').val('')
                Meteor.call 'createDoc', splitTags
                selectedTags.clear()
                for tag in splitTags
                    selectedTags.push tag
                FlowRouter.go '/'

    'click #homeLink': ->
        selectedTags.clear()

    'click #addDoc': ->
        Meteor.call 'createDoc', (err, id)->
            if err
                console.log err
            else
                FlowRouter.go "/edit/#{id}"

    'keyup #search': (e)->
        e.preventDefault()
        searchTerm = e.target.value.toLowerCase().trim()
        switch e.which
            when 13
                if searchTerm is 'clear'
                    selectedTags.clear()
                    $('#search').val('')
                else
                    selectedTags.push searchTerm
                    $('#search').val('')
            when 8
                if searchTerm is ''
                    selectedTags.pop()
