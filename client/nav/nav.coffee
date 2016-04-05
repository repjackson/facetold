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
    'autocompleteselect #tagDrilldown': (event, template, doc)->
        selected_tags.push doc.name.toString()
        $('#tagDrilldown').val('')

    'keyup #pageDrilldown': (event, template)->
        event.preventDefault()
        if event.which is 13
            val = $('#tagDrilldown').val()
            switch val
                when 'clear'
                    selected_tags.clear()
                    $('#tagDrilldown').val ''
                    $('#globalsearch').val ''

    'keyup #quickAdd': (e,t)->
        e.preventDefault
        tag = $('#addTag').val().toLowerCase()
        switch e.which
            when 13
                    splitTags = tag.match(/\S+/g);
                    $('#addTag').val('')
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
                analytics.track 'Added Doc'
                FlowRouter.go "/edit/#{id}"
