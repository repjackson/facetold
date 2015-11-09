@selectedtags = new ReactiveArray []

Template.home.onCreated ->
    @autorun -> Meteor.subscribe 'tags', selectedtags.array()
    @autorun -> Meteor.subscribe 'people'
    @autorun -> Meteor.subscribe 'person', Meteor.userId()
    @autorun -> Meteor.subscribe 'docs', selectedtags.array(), Session.get 'editing'

Accounts.ui.config passwordSignupFields: 'USERNAME_ONLY'


Meteor.startup ->
    Session.setDefault 'editing', null

Template.view.helpers
    is_editing: -> Session.equals 'editing',@_id
    isAuthor: -> Meteor.userId() is @authorId
    when:-> moment(@time).fromNow()


Template.view.events
    'click .edit': -> Session.set 'editing', @_id




Template.home.helpers
    globaltags: ->
        doccount = Docs.find().count()
        if 0 < doccount < 5 then Tags.find { count: $lt: doccount } else Tags.find()
    selectedtags: -> selectedtags.list()
    is_editing: -> Session.equals 'editing',@_id
    user: -> Meteor.user()
    docs: -> Docs.find {}, sort: time: -1


Template.home.events
    'click #add': ->
        selectedtags.clear()
        Meteor.call 'add', (err,oid)->
            Session.set 'editing', oid

    'keyup #search': (e,t)->
        e.preventDefault()
        switch e.which
            when 13 #enter
                val = $('#search').val()
                switch val
                    when 'clear'
                        selectedtags.clear()
                        $('#search').val ''
                    else
                        unless val.length is 0
                            selectedtags.push val.toString()
                            $('#search').val ''

    'click .selecttag': -> selectedtags.push @name.toString()

    'click .unselecttag': -> selectedtags.remove @toString()

    'click #cleartags': -> selectedtags.clear()

Template.edit.onRendered ->
    $("textarea").autosize()

Template.edit.events
    'click #save': (e,t)->
        body = t.$('#body').val()
        Docs.update @_id,
            $set: body: body
        Session.set 'editing', null

    'click #delete': ->
        Docs.remove @_id
        #Meteor.call 'calcusercloud', ->
        Session.set 'editing', null

    'keyup #addtag': (e,t)->
        e.preventDefault
        val = $('#addtag').val().toLowerCase()
        if e.which is 13
            if val.length > 0
                Docs.update @_id, { $addToSet: tags: val }, ->
                $('#addtag').val('')

    'click .removetag': ->
        tag = @valueOf()
        Docs.update Template.instance().data._id,
            $pull: tags: tag
            , ->

    'click .add_suggested_tag': ->
        tag = @valueOf()
        Docs.update Template.instance().data._id,
            $addToSet: tags: tag
            , ->

    'click #suggest_tags': ->
        body = $('textarea').val()

        Meteor.call 'suggest_tags', @_id, body


Template.edit.helpers
    unique_suggested_tags: -> _.difference(@suggested_tags, @tags)