@selectedtags = new ReactiveArray []

Template.home.onCreated ->
    @autorun -> Meteor.subscribe 'tags', selectedtags.array()
    @autorun -> Meteor.subscribe 'people'
    @autorun -> Meteor.subscribe 'person', Meteor.userId()
    @autorun -> Meteor.subscribe 'docs', selectedtags.array()

Accounts.ui.config passwordSignupFields: 'USERNAME_ONLY'


Meteor.startup ->
    Session.setDefault 'editing',null

Template.view.helpers
    is_editing: -> Session.equals 'editing',@_id
    isAuthor: -> Meteor.userId() is @authorId
    when:-> moment(@time).fromNow()


Template.view.events
    'click .edit': -> Session.set 'editing', @_id




Template.home.helpers
    globaltags: ->
        doccount = Docs.find().count()
        #console.log nodeCount
        if 0 < doccount < 5 then Tags.find { count: $lt: doccount } else Tags.find()
        Tags.find()

    selectedtags: -> selectedtags.list()

    is_editing: -> Session.equals 'editing',@_id

    user: -> Meteor.user()

    docs: -> Docs.find {}, sort: time: -1


Template.home.events
    'click #add': ->
        selectedtags.clear()
        Meteor.call 'add', (err,oid)->
            if err then console.log err
            Session.set 'editing', oid
            Meteor.setTimeout (->
                $('#addtag').focus()
                ), 500

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
            when 8 #backspace
                val = $('#search').val()
                if val.length is 0
                    selectedtags.pop()


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
        switch e.which
            when 13
                if val.length is 0
                    #Meteor.call 'calcusercloud', ->
                    Session.set 'editing', null
                else
                    Docs.update @_id, { $addToSet: tags: val }, ->
                    $('#addtag').val('')
            when 8
                if val.length is 0
                    if @tags.length is 0
                        Docs.remove @_id
                    else
                        last =  @tags.slice(-1)
                        $('#addtag').val(last)
                        Docs.update @_id, { $pop: tags: 1 }, ->


    'click .removetag': ->
        tag = @valueOf()
        Docs.update Template.instance().data._id, $pull: tags: tag
