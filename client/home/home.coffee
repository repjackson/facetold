@newTags = new ReactiveArray []
@selectedTags = new ReactiveArray []
@selectedUsernames = new ReactiveArray []
@pinnedUsernames = new ReactiveArray []

Template.home.onCreated ->
    Meteor.subscribe 'people'
    # @autorun -> Meteor.subscribe('usernames', selectedTags.array())
    @autorun -> Meteor.subscribe('tags', selectedTags.array())
    @autorun -> Meteor.subscribe('docs', selectedTags.array())
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
            when @index <= 7 then 'btn-lg'
            when 7 < @index <= 14 then ''
            when @index > 14 then 'btn-sm'
            # when @index < 50 then 'btn-sm'
        return buttonClass

    selectedTags: -> selectedTags.list()
    newTags: -> newTags.list()

    # globalUsernames: -> Usernames.find()
    selectedUsernames: -> selectedUsernames.list()

    # pinnedUsernames: -> pinnedUsernames.list()

    # pinnedButtonClass: -> if @text in pinnedUsernames.array() then 'btn-primary' else 'btn-default'

    user: -> Meteor.user()

Template.home.events
    'click .selectTag': -> selectedTags.push @name
    'click .unselectTag': -> selectedTags.remove @valueOf()
    'click #clearTags': -> selectedTags.clear()


    'click .pinUsername': -> if @text in pinnedUsernames.array() then pinnedUsernames.remove @text else pinnedUsernames.push @text

    'click .selectUsername': -> selectedUsernames.push @text
    'click .unselectUsername': -> selectedUsernames.remove @valueOf()
    'click #clearUsernames': -> selectedUsernames.clear()


    'keyup #addTag': (e,t)->
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

    'click .newDocTag': ->
        tag = @valueOf()
        newTags.remove tag
        $('#addTag').val(tag)

    'click .authorFilterButton': (e)->
        if e.target.innerHTML in selected_screen_names.array() then selected_screen_names.remove e.target.innerHTML else selected_screen_names.push e.target.innerHTML
