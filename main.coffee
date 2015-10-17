@Tags = new Meteor.Collection 'tags'
@Posts = new Meteor.Collection 'posts'

FlowRouter.route '/',
    action: (params, queryParams)->
        BlazeLayout.render 'layout',
            nav: 'nav'
            cloud: 'cloud'
            body: 'posts'

FlowRouter.route '/edit/:postId',
    action: (params, queryParams)->
        BlazeLayout.render 'layout', body: 'edit'

FlowRouter.route '/add',
    action: (params, queryParams)->
        BlazeLayout.render 'layout', body: 'add'


Posts.helpers
    author: (doc)-> Meteor.users.findOne @authorId
    buyer: (doc)-> Meteor.users.findOne @buyerId


if Meteor.isClient
    selectedTags = new ReactiveArray []

    Accounts.ui.config
        passwordSignupFields: 'USERNAME_ONLY'
        dropdownClasses: 'simple'

    Template.cloud.onCreated ->
        @autorun ->
            Meteor.subscribe 'tags', selectedTags.array(), Session.get('selectedAuthor')

    Template.posts.onCreated ->
        @autorun ->
            Meteor.subscribe 'people'
            Meteor.subscribe 'posts', selectedTags.array(),Session.get('selectedAuthor')

    Template.edit.onCreated ->
        @autorun -> Meteor.subscribe 'post', FlowRouter.getParam('postId')


    Template.nav.helpers
        homeLinkClass: -> if selectedTags.list().length is 0 then 'active' else ''

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

    Template.cloud.helpers
        displayedtags: ->
            postCount = Posts.find().count()
            if 0 < postCount < 10 then Tags.find {count: $lt: postCount} else Tags.find()

        selectedTags: -> selectedTags.list()

    Template.posts.helpers
        posts: -> Posts.find {}

    Template.nav.events
        'autocompleteselect #tagsearch': (event, template, doc)->
            selectedTags.push doc.name.toString()
            $('input').val('')

        'keyup #globalsearch': (e,t)->
            e.preventDefault()
            if event.which is 13
                val = $('#globalsearch').val()
                selectedTags.push val.toString()
                $('#globalsearch').val ''

        'keyup #tagsearch': (event, template)->
            event.preventDefault()
            if event.which is 13
                val = $('#tagsearch').val()
                switch val
                    when 'clear'
                        selectedTags.clear()
                        $('#tagsearch').val ''
                        $('#globalsearch').val ''
                    when 'logout'
                        Meteor.logout()
                        $('#globalsearch').val ''
                        $('#tagsearch').val ''

        'click #home': ->
            selectedTags.clear()
            $('#globalsearch').val ''
            $('#tagsearch').val('')

    Template.cloud.events
        'click .selectTag': -> selectedTags.push @name.toString()

        'click .unselectTag': -> selectedTags.remove @toString()

        'click #clear': -> selectedTags.clear()

    Template.edit.events
        'click #save': (e,t)->
            text = $('textarea').val()
            Meteor.call 'save', @_id, text, (err, result)->
                selectedTags.clear()
                result.tags.forEach (tag)-> selectedTags.push tag
                FlowRouter.go '/'

        'click #cancel': -> FlowRouter.go '/'

        'click #delete': ->
            Posts.remove @_id
            FlowRouter.go '/'

    Template.add.events
        'click #add': ->
            text = $('textarea').val()
            if text.length isnt 0
                Meteor.call 'add', text, (err, result)->
                    selectedTags.clear()
                    result.tags.forEach (tag)-> selectedTags.push tag
                    FlowRouter.go '/'

        'click #cancel': -> FlowRouter.go '/'

    Template.post.events
        'click .author': (e)->
            if Session.equals('selectedAuthor', @authorId)
                Session.set('selectedAuthor',null)
            else Session.set('selectedAuthor', @authorId)

    Template.post.helpers
        post: -> Posts.find(FlowRouter.getParam('postId'))
        editaddress: -> '/edit/'+@_id
        isAuthor: -> Meteor.userId() and Meteor.userId() is @authorId
        authorButtonClass: -> if Session.equals('selectedAuthor',@authorId) then 'active' else 'basic'

    Template.edit.helpers
        post: -> Posts.findOne()



if Meteor.isServer
    Meteor.methods
        save: (postId, text)->
            result = Yaki(text).extract()
            cleaned = Yaki(result).clean()
            lowered = cleaned.map (tag)-> tag.toLowerCase()

            Posts.update postId, {
                $set:
                    tags: lowered
                    body: text
                }

            return Posts.findOne postId


        add: (text)->
            result = Yaki(text).extract()
            cleaned = Yaki(result).clean()
            lowered = cleaned.map (tag)-> tag.toLowerCase()

            newId = Posts.insert
                tags: lowered
                body: text
                authorId: Meteor.userId()
                timestamp: Date.now()

            return Posts.findOne newId


    Posts.allow
        insert: (userId, post)-> userId and post.authorId is userId
        update: (userId, post)-> post.authorId is userId
        remove: (userId, post)-> post.authorId is userId


    Meteor.publish 'people', ->
        Meteor.users.find {},
            fields:
                username: 1
                points: 1
                cloud: 1


    Meteor.publish 'tags', (tags, author)->
        self = @
        match = {}

        if tags.length > 0 then match.tags = $all: tags

        if author then match.authorId = author

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
        if author then match.authorId = author
        return Posts.find match,
            limit: 10
            sort:
                timestamp: -1