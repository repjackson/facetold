@selectedtags = new ReactiveArray []


Template.home.onCreated ->
    @autorun -> Meteor.subscribe 'people'
    @autorun -> Meteor.subscribe 'person', Meteor.userId()
    @autorun -> Meteor.subscribe 'tags', selectedtags.array(), Session.get 'selected_user'
    @autorun -> Meteor.subscribe 'docs', selectedtags.array(), Session.get('editing'), Session.get 'selected_user'

Accounts.ui.config passwordSignupFields: 'USERNAME_ONLY'


Meteor.startup ->
    Session.setDefault 'editing', null
    Session.setDefault 'selected_user', null

Template.view.helpers
    is_editing: -> Session.equals 'editing',@_id

    isAuthor: -> Meteor.userId() is @authorId

    when:-> moment(@time).fromNow()

    vote_up_button_class: -> if not Meteor.userId() then 'disabled' else ''

    vote_up_icon_class: -> if Meteor.userId() and @up_voters and Meteor.userId() in @up_voters then '' else 'outline'

    vote_down_button_class: -> if not Meteor.userId() then 'disabled' else ''

    vote_down_icon_class: -> if Meteor.userId() and @down_voters and Meteor.userId() in @down_voters then '' else 'outline'

    doc_tag_class: -> if @valueOf() in selectedtags.array() then 'grey' else ''


Template.view.events
    'click .edit': -> Session.set 'editing', @_id

    'click .vote_up': -> Meteor.call 'vote_up', @_id

    'click .vote_down': -> Meteor.call 'vote_down', @_id

    'click .doc_tag': -> if @valueOf() in selectedtags.array() then selectedtags.remove @valueOf() else selectedtags.push @valueOf()

    'click .select_user': ->
        if Session.equals 'selected_user', @authorId
            Session.set 'selected_user', null
        else
            Session.set 'selected_user', @authorId

Template.home.helpers
    globaltags: ->
        doccount = Docs.find().count()
        if 0 < doccount < 3 then Tags.find { count: $lt: doccount } else Tags.find()
    selectedtags: -> selectedtags.list()
    is_editing: -> Session.equals 'editing',@_id
    user: -> Meteor.user()
    docs: -> Docs.find {}, sort: time: -1
    selected_user: ->
        if Session.get 'selected_user'
            user = Meteor.users.findOne(Session.get('selected_user'))?.username
            user


Template.home.events
    'click #add': ->
        Meteor.call 'add', (err,oid)->
            Session.set 'editing', oid
        selectedtags.clear()

    'keyup #search': (e,t)->
        e.preventDefault()
        val = $('#search').val()
        switch e.which
            when 13 #enter
                switch val
                    when 'clear'
                        selectedtags.clear()
                        $('#search').val ''
                    else
                        unless val.length is 0
                            selectedtags.push val.toString()
                            $('#search').val ''
            when 8
                if val.length is 0
                    selectedtags.pop()
    'click .selecttag': -> selectedtags.push @name.toString()

    'click .unselecttag': -> selectedtags.remove @toString()

    'click #cleartags': -> selectedtags.clear()

    'click .selected_user_button': -> Session.set 'selected_user', null

#Template.edit.onRendered ->
    #$("#body").autosize()

Template.edit.events
    'click #save': (e,t)->
        body = t.$('#body').val()
        Meteor.call 'save', @_id, body
        Session.set 'editing', null

    'click #delete': ->
        if confirm 'Confirm delete?'
            Docs.remove @_id
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
    editorOptions: ->
        return {
            lineNumbers: true
            mode: "markdown"
        }
