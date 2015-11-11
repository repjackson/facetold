@selectedtags = new ReactiveArray []

Template.nav.onCreated ->
    Meteor.subscribe 'person', Meteor.userId()

Template.home.onCreated ->
    Meteor.subscribe 'people'
    @autorun -> Meteor.subscribe 'tags', selectedtags.array(), Session.get('selected_user'), Session.get('upvoted_cloud'), Session.get('downvoted_cloud')
    @autorun -> Meteor.subscribe 'docs', selectedtags.array(), Session.get('editing'), Session.get('selected_user'), Session.get('upvoted_cloud'), Session.get('downvoted_cloud')

Template.view.onCreated ->
    Meteor.subscribe 'person', @authorId

Accounts.ui.config
    passwordSignupFields: 'USERNAME_ONLY'


Meteor.startup ->
    Session.setDefault 'editing', null
    Session.setDefault 'selected_user', null
    Session.setDefault 'upvoted_cloud', null
    Session.setDefault 'downvoted_cloud', null

Template.view.helpers
    is_editing: -> Session.equals 'editing',@_id

    isAuthor: -> Meteor.userId() is @authorId

    when:-> moment(@time).fromNow()

    vote_up_button_class: -> if not Meteor.userId() then 'disabled' else ''
    vote_up_icon_class: -> if Meteor.userId() and @up_voters and Meteor.userId() in @up_voters then '' else 'outline'
    vote_down_button_class: -> if not Meteor.userId() then 'disabled' else ''
    vote_down_icon_class: -> if Meteor.userId() and @down_voters and Meteor.userId() in @down_voters then '' else 'outline'

    doc_tag_class: -> if @valueOf() in selectedtags.array() then 'grey' else ''

    select_user_button_class: -> if Session.equals 'selected_user', @authorId then 'active' else ''
    author_downvotes_button_class: -> if Session.equals 'downvoted_cloud', @authorId then 'active' else ''
    author_upvotes_button_class: -> if Session.equals 'upvoted_cloud', @authorId then 'active' else ''


Template.view.events
    'click .edit': -> Session.set 'editing', @_id

    'click .vote_up': -> Meteor.call 'vote_up', @_id
    'click .vote_down': -> Meteor.call 'vote_down', @_id

    'click .doc_tag': -> if @valueOf() in selectedtags.array() then selectedtags.remove @valueOf() else selectedtags.push @valueOf()

    'click .select_user': -> if Session.equals('selected_user', @authorId) then Session.set('selected_user', null) else Session.set('selected_user', @authorId)
    'click .author_upvotes': -> if Session.equals('upvoted_cloud', @authorId) then Session.set('upvoted_cloud', null) else Session.set('upvoted_cloud', @authorId)
    'click .author_downvotes': -> if Session.equals('downvoted_cloud', @authorId) then Session.set('downvoted_cloud', null) else Session.set('downvoted_cloud', @authorId)


Template.nav.events
    'click #home': ->
        Session.set 'downvoted_cloud', null
        Session.set 'selected_user', null
        Session.set 'upvoted_cloud', null


    'click #add': ->
        Meteor.call 'add', (err,oid)->
            Session.set 'editing', oid
        selectedtags.clear()

    'click #mine': ->
        Session.set 'downvoted_cloud', null
        Session.set 'upvoted_cloud', null
        Session.set 'selected_user', Meteor.userId()

    'click #my_upvoted': ->
        Session.set 'selected_user', null
        Session.set 'downvoted_cloud', null
        Session.set 'upvoted_cloud', Meteor.userId()

    'click #my_downvoted': ->
        Session.set 'selected_user', null
        Session.set 'upvoted_cloud', null
        Session.set 'downvoted_cloud', Meteor.userId()

Template.nav.helpers
    doc_counter: -> Counts.get('doc_counter')

    user_counter: -> Meteor.users.find().count()

Template.home.helpers
    globaltags: ->
        doccount = Docs.find().count()
        if 0 < doccount < 3 then Tags.find { count: $lt: doccount } else Tags.find()

    selectedtags: -> selectedtags.list()

    is_editing: -> Session.equals 'editing',@_id

    user: -> Meteor.user()

    docs: -> Docs.find {}, sort: time: -1

    selected_user: -> if Session.get 'selected_user' then Meteor.users.findOne(Session.get('selected_user'))?.username

    upvoted_cloud: -> if Session.get 'upvoted_cloud' then Meteor.users.findOne(Session.get('upvoted_cloud'))?.username

    downvoted_cloud: -> if Session.get 'downvoted_cloud' then Meteor.users.findOne(Session.get('downvoted_cloud'))?.username


Template.home.events
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
    'click .upvoted_cloud_button': -> Session.set 'upvoted_cloud', null
    'click .downvoted_cloud_button': -> Session.set 'downvoted_cloud', null


Template.edit.events
    'click #save': (e,t)->
        body = t.$('#body').val()
        Meteor.call 'save', @_id, body
        Session.set 'editing', null

    'click #delete': ->
        if confirm 'Confirm delete'
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
            lineWrapping: true
        }
