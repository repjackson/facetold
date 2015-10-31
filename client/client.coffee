selectedtags = new ReactiveArray []

Accounts.ui.config passwordSignupFields: 'USERNAME_ONLY'

Session.setDefault 'editing', null
Session.setDefault 'mode', 'people'

Template.home.onCreated ->
    @autorun -> Meteor.subscribe 'tags', selectedtags.array(), Session.get('mode')
    @autorun -> Meteor.subscribe 'person', Meteor.userId()


Template.docs.helpers doclist: -> Docs.find {}
Template.docs.onCreated -> @autorun -> Meteor.subscribe 'docs', selectedtags.array(), Session.get 'editing'

Template.people.helpers peoplelist: -> Meteor.users.find {}
Template.people.onCreated -> @autorun -> Meteor.subscribe 'people', selectedtags.array()

Template.doc.helpers
    isAuthor: -> Meteor.userId() is @authorId
    isediting: -> Session.equals('editing', @_id)

Template.home.helpers
    ismydocsmode: -> Session.equals 'mode', 'mydocs'


    globaltags: ->
        docCount = Docs.find().count()
        if 0 < docCount < 5 then Tags.find { count: $lt: docCount } else Tags.find()



    editmode: -> Session.get('editing')

    selectedtags: -> selectedtags.list()

    user: -> Meteor.user()


Template.home.events
    'click #viewpeople': -> Session.set 'mode','people'

    'click #viewmydocs': -> Session.set 'mode','mydocs'

    'click .edit': ->
        Session.set 'editing', @_id
        Meteor.setTimeout (->
            $('#addtag').focus()
            ),200

    'click #save': ->
        Meteor.call 'calcusercloud', ->
        Session.set 'editing', null

    'keyup #search': (e,t)->
        e.preventDefault()
        switch e.which
            when 13 #enter
                val = $('#search').val()
                switch val
                    when 'clear'
                        selectedtags.clear()
                        $('#search').val ''
                    when 'add'
                        if Meteor.userId()
                            newdocid = Docs.insert
                                authorId: Meteor.userId()
                                time: Date.now()
                                tags: []
                                , ->
                            Session.set 'editing', newdocid
                            Meteor.setTimeout (->
                                $('#addtag').focus()
                                ),200
                            $('#search').val ''
                    else
                        unless val.length is 0
                            selectedtags.push val.toString()
                            $('#search').val ''
            when 8 #backspace
                val = $('#search').val()
                if val.length is 0
                    selectedtags.pop()

    'click #add': ->
        newdocid = Docs.insert
            authorId: Meteor.userId()
            time: Date.now()
            tags: []
            , ->
        Session.set 'editing', newdocid
        Meteor.setTimeout (->
            $('#addtag').focus()
            ),200

    'keyup #addtag': (e,t)->
        e.preventDefault
        docid = Session.get 'editing'
        val = $('#addtag').val()
        switch e.which
            when 13 #enter
                if val.length is 0
                    Meteor.call 'calcusercloud', ->
                    Session.set 'editing', null
                else
                    Docs.update docid, { $addToSet: tags: val }, ->
                    Meteor.users.update Meteor.userId(), { $addToSet: tags: val }, ->
                    $('#addtag').val('')
            when 8 #backspace
                if val.length is 0
                    doc = Docs.findOne docid
                    if doc.tags.length < 2
                        Docs.remove docid
                        Meteor.call 'calcusercloud', ->
                        Session.set 'editing',null
                    else
                        Docs.update docid, { $pop: tags: 1 }, ->
                        Meteor.users.update Meteor.userId(), { $addToSet: tags: val }, ->

    'click .removedoctag': ->
        tag = @valueOf()
        docid = Session.get 'editing'
        doc = Docs.findOne docid
        if doc.tags.length is 1
            Docs.remove docid
            Meteor.call 'calcusercloud', ->
            Session.set 'editing', null
        else
            Docs.update docid, $pull: tags: tag
        Meteor.users.update Meteor.userId(), $pull: tags: tag


    'click .selecttag': -> selectedtags.push @name.toString()

    'click .unselecttag': -> selectedtags.remove @toString()

    'click #cleartags': -> selectedtags.clear()

    'click #home': -> Session.set 'editing', null


