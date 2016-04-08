@selectedTags = new ReactiveArray []
@selectedUsernames = new ReactiveArray []

Template.docs.onCreated ->
    @autorun -> Meteor.subscribe('docs', selectedTags.array(), selectedUsernames.array(), Session.get('view'))

Template.docs.helpers
    # docs: -> Docs.find({}, limit: 1)
    docs: -> Docs.find()


Template.cloud.onCreated ->
    Meteor.subscribe 'people'
    @autorun -> Meteor.subscribe('usernames', selectedTags.array(), selectedUsernames.array(), Session.get('view'))
    @autorun -> Meteor.subscribe('tags', selectedTags.array(), selectedUsernames.array(), Session.get('view'))

Template.cloud.helpers
    globalTags: ->
        docCount = Docs.find().count()
        if 0 < docCount < 3 then Tags.find { count: $lt: docCount } else Tags.find()
        # Tags.find()

    # globalTagClass: ->
    #     buttonClass = switch
    #         when @index <= 20 then 'big'
    #         when @index <= 40 then 'large'
    #         when @index <= 60 then ''
    #         when @index <= 80 then 'small'
    #         when @index <= 100 then 'tiny'
    #     return buttonClass

    globalTagClass: ->
        buttonClass = switch
            when @index <= 10 then 'big'
            when @index <= 20 then 'large'
            when @index <= 30 then ''
            when @index <= 40 then 'small'
            when @index <= 50 then 'tiny'
        return buttonClass

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

    globalUsernames: -> Usernames.find()
    selectedUsernames: -> selectedUsernames.list()


Template.cloud.events
    'click .selectTag': -> selectedTags.push @name
    'click .unselectTag': -> selectedTags.remove @valueOf()
    'click #clearTags': -> selectedTags.clear()

    'click .selectUsername': -> selectedUsernames.push @text
    'click .unselectUsername': -> selectedUsernames.remove @valueOf()
    'click #clearUsernames': -> selectedUsernames.clear()

