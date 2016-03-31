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

    globalTagClass: ->
        buttonClass = switch
            when @index <= 7 then 'btn-lg'
            when 7 < @index <= 14 then ''
            when @index > 14 then 'btn-sm'
            # when @index < 50 then 'btn-sm'
        return buttonClass

    selectedTags: -> selectedTags.list()

    user: -> Meteor.user()

Template.home.events
    'click .selectTag': -> selectedTags.push @name
    'click .unselectTag': -> selectedTags.remove @valueOf()
    'click #clearTags': -> selectedTags.clear()