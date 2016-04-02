@newTags = new ReactiveArray []
@selectedTags = new ReactiveArray []
@selectedUsernames = new ReactiveArray []

Template.home.onCreated ->
    Meteor.subscribe 'people'
    @autorun -> Meteor.subscribe('usernames', selectedTags.array(), selectedUsernames.array(), Session.get('view'))
    @autorun -> Meteor.subscribe('tags', selectedTags.array(), selectedUsernames.array(), Session.get('view'))
    @autorun -> Meteor.subscribe('docs', selectedTags.array(), selectedUsernames.array(), Session.get('view'))

Template.home.helpers
    globalTags: ->
        # docCount = Docs.find().count()
        # if 0 < docCount < 3 then Tags.find { count: $lt: docCount } else Tags.find()
        Tags.find()

    docs: -> Docs.find()

    globalTagClass: ->
        buttonClass = switch
            when @index <= 7 then 'btn-lg'
            when 7 < @index <= 14 then ''
            when @index > 14 then 'btn-sm'
            # when @index < 50 then 'btn-sm'
        return buttonClass

    selectedTags: -> selectedTags.list()
    newTags: -> newTags.list()

    globalUsernames: -> Usernames.find()
    selectedUsernames: -> selectedUsernames.list()


    user: -> Meteor.user()

Template.home.events
    'click .selectTag': -> selectedTags.push @name
    'click .unselectTag': -> selectedTags.remove @valueOf()
    'click #clearTags': -> selectedTags.clear()

    'click .selectUsername': -> selectedUsernames.push @text
    'click .unselectUsername': -> selectedUsernames.remove @valueOf()
    'click #clearUsernames': -> selectedUsernames.clear()


    'keyup #addTag': (e,t)->
        e.preventDefault
        tag = $('#addTag').val().toLowerCase()
        switch e.which
            when 13
                if tag.length > 0
                    newTags.push tag
                    $('#addTag').val('')
                else
                    tags = newTags.array()
                    # console.log tags
                    Meteor.call 'createDoc', tags
                    newTags.clear()
                    selectedTags.clear()
                    for tag in tags
                        selectedTags.push tag
            when 8
                if tag.length is 0
                    last = newTags[-1..].toString()
                    newTags.remove last
                    # console.log last.toString()
                    $('#addTag').val(last)

    'click .newDocTag': ->
        tag = @valueOf()
        newTags.remove tag
        $('#addTag').val(tag)

    'click .authorFilterButton': (e)->
        if e.target.innerHTML in selected_screen_names.array() then selected_screen_names.remove e.target.innerHTML else selected_screen_names.push e.target.innerHTML
