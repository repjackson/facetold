selectedtags = new ReactiveArray []


Template.docs.onCreated ->
    @autorun -> Meteor.subscribe 'tags', selectedtags.array()

    @autorun -> Meteor.subscribe 'docs', selectedtags.array()

    @autorun -> Meteor.subscribe 'allpeople'

Template.docs.helpers
    tags: ->
        docCount = Docs.find().count()
        if 0 < docCount < 5 then Tags.find { count: $lt: docCount } else Tags.find()

    docs: -> Docs.find {}, limit: 5

    selectedtags: -> selectedtags.list()

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

Template.docs.events
    'autocompleteselect #tagsearch': (event, template, doc)->
        selectedtags.push doc.name.toString()
        $('#tagsearch').val('')

    'keyup #globalsearch': (e,t)->
        e.preventDefault()
        if event.which is 13
            val = $('#globalsearch').val()
            if val is 'clear'
                selectedtags.clear()
                $('#tagsearch').val ''
                $('#globalsearch').val ''
            else
                selectedtags.push val.toString()
                $('#globalsearch').val ''

    'keyup #tagsearch': (event, template)->
        event.preventDefault()
        if event.which is 13
            val = $('#tagsearch').val()
            switch val
                when 'clear'
                    selectedtags.clear()
                    $('#tagsearch').val ''
                    $('#globalsearch').val ''


    'click .selectDocTag': -> selectedtags.push @name.toString()

    'click .unselectDocTag': -> selectedtags.remove @toString()

    'click #cleartags': -> selectedtags.clear()

