@selectedTags = new ReactiveArray []

Template.home.onCreated ->
    Meteor.subscribe 'people'
    @autorun -> Meteor.subscribe('tags', selectedTags.array(), Session.get('view'))
    @autorun -> Meteor.subscribe('docs', selectedTags.array(), Session.get('view'))

Template.home.helpers
    globalTags: ->
        # docCount = Docs.find().count()
        # if 0 < docCount < 3 then Tags.find { count: $lt: docCount } else Tags.find()
        Tags.find()

    docs: -> Docs.find()

    # globalTagClass: ->
    #     buttonClass = switch
    #         when @index <= 15 then 'huge'
    #         when @index <= 30 then 'big'
    #         when @index <= 45 then 'large'
    #         when @index <= 60 then ''
    #         when @index <= 75 then 'small'
    #         when @index <= 90 then 'tiny'
    #         when @index > 90 then 'mini'
    #     return buttonClass

    globalTagClass: ->
        buttonClass = switch
            when @index <= 10 then 'big'
            when @index <= 20 then 'large'
            when @index <= 30 then ''
            when @index <= 40 then 'small'
            when @index <= 50 then 'tiny'
        return buttonClass

    # globalTagClass: ->
    #     buttonClass = switch
    #         when @index <= 7 then 'big'
    #         when 7 < @index <= 14 then 'large'
    #         when 14 < @index <= 21 then ''
    #         when 21 < @index <= 28 then ''
    #         when 28 < @index <= 35 then 'small'
    #         when 35 < @index <= 42 then 'tiny'
    #         when @index > 42 then 'mini'
    #     return buttonClass

    selectedTags: -> selectedTags.list()

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


Template.home.events
    'click .selectTag': -> selectedTags.push @name
    'click .unselectTag': -> selectedTags.remove @valueOf()
    'click #clearTags': -> selectedTags.clear()

    'autocompleteselect #pageDrilldown': (event, template, doc)->
        selectedTags.push doc.name.toString()
        $('#pageDrilldown').val('')


    'click .authorFilterButton': (e)->
        if e.target.innerHTML in selected_screen_names.array() then selected_screen_names.remove e.target.innerHTML else selected_screen_names.push e.target.innerHTML

    'keyup #search': (e)->
        e.preventDefault()
        switch e.which
            when 13
                if e.target.value is 'clear'
                    selectedTags.clear()
                    $('#search').val('')
                else
                    selectedTags.push e.target.value.toLowerCase()
                    $('#search').val('')
            when 8
                if e.target.value is ''
                    selectedTags.pop()
