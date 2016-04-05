@newTags = new ReactiveArray []
@selectedTags = new ReactiveArray []
@selectedUsernames = new ReactiveArray []
# @pinnedUsernames = new ReactiveArray []

Template.home.onCreated ->
    Meteor.subscribe 'people'
    # @autorun -> Meteor.subscribe('usernames', selectedTags.array())
    @autorun -> Meteor.subscribe('tags', selectedTags.array(), Session.get('view'))
    @autorun -> Meteor.subscribe('docs', selectedTags.array(), Session.get('view'))
    # @autorun -> Meteor.subscribe('usernames', selectedTags.array(), selectedUsernames.array(), pinnedUsernames.array(), Session.get('view'))
    # @autorun -> Meteor.subscribe('tags', selectedTags.array(), selectedUsernames.array(), pinnedUsernames.array(), Session.get('view'))
    # @autorun -> Meteor.subscribe('docs', selectedTags.array(), selectedUsernames.array(), pinnedUsernames.array(), Session.get('view'))

Template.home.helpers
    globalTags: ->
        # docCount = Docs.find().count()
        # if 0 < docCount < 3 then Tags.find { count: $lt: docCount } else Tags.find()
        Tags.find()

    docs: -> Docs.find()

    globalTagClass: ->
        buttonClass = switch
            when @index <= 10 then 'huge'
            when 10 < @index <= 20 then 'big'
            when 20 < @index <= 30 then 'large'
            when 30 < @index <= 40 then ''
            when 40 < @index <= 50 then 'small'
            when 50 < @index <= 60 then 'tiny'
            when @index > 60 then 'mini'
        return buttonClass

    selectedTags: -> selectedTags.list()
    newTags: -> newTags.list()

    # globalUsernames: -> Usernames.find()
    selectedUsernames: -> selectedUsernames.list()

    # pinnedUsernames: -> pinnedUsernames.list()

    # pinnedButtonClass: -> if @text in pinnedUsernames.array() then 'btn-primary' else 'btn-default'

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


    'click .pinUsername': -> if @text in pinnedUsernames.array() then pinnedUsernames.remove @text else pinnedUsernames.push @text

    'click .selectUsername': -> selectedUsernames.push @text
    'click .unselectUsername': -> selectedUsernames.remove @valueOf()
    'click #clearUsernames': -> selectedUsernames.clear()


    'click .newDocTag': ->
        tag = @valueOf()
        newTags.remove tag
        $('#addTag').val(tag)

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
