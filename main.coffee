@Tags = new Meteor.Collection 'tags'

AccountsTemplates.configure
    defaultTemplate: 'myCustomFullPageAtForm'
    defaultLayout: 'layout'
    defaultLayoutRegions:
        nav: 'nav'
        cloud: 'cloud'
    defaultContentRegion: 'main'

AccountsTemplates.configureRoute('signIn')


FlowRouter.route '/',
    action: (params, queryParams)->
        BlazeLayout.render 'layout',
            nav: 'nav'
            cloud: 'cloud'
            body: 'people'

FlowRouter.route '/profile',
    action: (params, queryParams)->
        BlazeLayout.render 'layout',
            nav: 'nav'
            body: 'profile'


if Meteor.isClient
    selectedTags = new ReactiveArray []

    Template.cloud.onCreated ->
        @autorun ->
            Meteor.subscribe 'tags', selectedTags.array()

    Template.people.onCreated ->
        @autorun ->
            Meteor.subscribe 'people', selectedTags.array()

    Template.cloud.helpers
        displayedtags: ->
            personCount = Meteor.users.find().count()
            if 0 < personCount < 10 then Tags.find {count: $lt: personCount} else Tags.find()
        selectedTags: -> selectedTags.list()

    Template.people.helpers
        people: -> Meteor.users.find {}

    Template.cloud.events
        'click .selectTag': -> selectedTags.push @name.toString()
        'click .unselectTag': -> selectedTags.remove @toString()
        'click #clear': -> selectedTags.clear()

    Template.profile.events
        'click
            text = $('textarea').val()
            text = $('textarea').val()


if Meteor.isServer
    Accounts.onCreateUser (options, user)->
        user.wanted = []
        user.offered = []
        user.locationTags = []
        user

    Meteor.publish 'people', ->
        Meteor.users.find {},
            fields:
                username: 1
                profile: 1

    Meteor.publish 'tags', (tags)->
        self = @
        match = {}

        if tags.length > 0 then match.tags = $all: tags

        cloud = Posts.aggregate [
            { $match: match }
            { $project: tags: 1 }
            { $unwind: '$tags' }
            { $group: _id: '$tags', count: $sum: 1 }
            { $match: _id: $nin: tags }
            { $sort: count: -1, _id: 1 }
            { $limit: 100 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]

        cloud.forEach (tag) ->
            self.added 'tags', Random.id(),
                name: tag.name
                count: tag.count
        self.ready()

    Meteor.publish 'post', (postId) -> Posts.find postId

    Meteor.publish 'posts', (tags, author) ->
        match = {}
        if tags.length > 0 then match.tags = $all: tags else return null
        return Posts.find match,
            limit: 10
            sort:
                timestamp: -1