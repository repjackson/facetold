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

marked.setOptions
    renderer: new (marked.Renderer)
    gfm: true
    tables: true
    breaks: true
    pedantic: false
    sanitize: true
    smartLists: true
    smartypants: false

Meteor.startup ->
    React.render(<App />, document.getElementById('render-target'))
    Session.setDefault 'editing', null
    Session.setDefault 'selected_user', null
    Session.setDefault 'upvoted_cloud', null
    Session.setDefault 'downvoted_cloud', null
    GAnalytics.pageview("/")

Template.nav.events
    # 'click #home': ->
    #     Session.set 'downvoted_cloud', null
    #     Session.set 'selected_user', null
    #     Session.set 'upvoted_cloud', null
    #     selectedtags.clear()


    'click #add': ->
        Meteor.call 'add', (err,oid)->
            Session.set 'editing', oid
        selectedtags.clear()
        GAnalytics.pageview("/add")

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

Template.nav.helpers
    doc_counter: -> Counts.get('doc_counter')

    user_counter: -> Meteor.users.find().count()

Template.home.helpers
    globaltags: ->
        doccount = Docs.find().count()
        if doccount < 3 then Tags.find { count: $lt: doccount } else Tags.find()
        #Tags.find { count: $gt: 1 }
        #Tags.find()

    selectedtags: -> selectedtags.list()

    is_editing: -> Session.equals 'editing',@_id

    user: -> Meteor.user()

    docs: -> Docs.find()

    selected_user: -> if Session.get 'selected_user' then Meteor.users.findOne(Session.get('selected_user'))?.username

    upvoted_cloud: -> if Session.get 'upvoted_cloud' then Meteor.users.findOne(Session.get('upvoted_cloud'))?.username

    downvoted_cloud: -> if Session.get 'downvoted_cloud' then Meteor.users.findOne(Session.get('downvoted_cloud'))?.username


Template.home.events
    'click .selecttag': ->
        selectedtags.push @name.toString()
        GAnalytics.pageview(@name)

    'click .unselecttag': -> selectedtags.remove @toString()

    'click #cleartags': -> selectedtags.clear()

    'click .selected_user_button': -> Session.set 'selected_user', null
    'click .upvoted_cloud_button': -> Session.set 'upvoted_cloud', null
    'click .downvoted_cloud_button': -> Session.set 'downvoted_cloud', null


Template.edit.events
    'click #save': (e,t)->
        body = t.$('#codebody').val()
        Meteor.call 'save', @_id, body, ->
        Session.set 'editing', null
        selectedtags.push(tag) for tag in @tags

    'click #delete': ->
        if confirm 'Confirm delete'
            Docs.remove @_id, ->
            Session.set 'editing', null

    'keyup #addtag': (e,t)->
        e.preventDefault
        val = $('#addtag').val().toLowerCase()
        if e.which is 13
            if val.length > 0
                Docs.update @_id, { $addToSet: tags: val }, ->
                $('#addtag').val('')
            else
                body = t.$('#codebody').val()
                Meteor.call 'save', @_id, body, ->
                Session.set 'editing', null

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

    'click #add_all_suggested_tags': ->
        Docs.update @_id, $addToSet: tags: $each: @suggested_tags

    'click #clear_doc_tags': ->
        Docs.update @_id, $set: tags: []

    'click #clear_suggested_tags': ->
        Docs.update @_id, $set: suggested_tags: []


Template.edit.helpers
    unique_suggested_tags: -> _.difference(@suggested_tags, @tags)

    editorOptions: ->
        return {
            lineNumbers: false
            mode: "markdown"
            lineWrapping: true
            viewportMargin: Infinity
        }

Template.view.helpers
    is_editing: -> Session.equals 'editing',@_id

    isAuthor: -> Meteor.userId() is @authorId

    when:-> moment(@time).fromNow()

    vote_up_button_class: -> if not Meteor.userId() then 'disabled' else ''
    vote_up_icon_class: -> if Meteor.userId() and @up_voters and Meteor.userId() in @up_voters then '' else 'outline'
    vote_down_button_class: -> if not Meteor.userId() then 'disabled' else ''
    vote_down_icon_class: -> if Meteor.userId() and @down_voters and Meteor.userId() in @down_voters then '' else 'outline'

    doc_tag_class: -> if @valueOf() in selectedtags.array() then 'grey' else ''

    select_user_button_class: -> if Session.equals 'selected_user', @authorId then 'grey' else ''
    author_downvotes_button_class: -> if Session.equals 'downvoted_cloud', @authorId then 'grey' else ''
    author_upvotes_button_class: -> if Session.equals 'upvoted_cloud', @authorId then 'grey' else ''

    authored_cloud_intersection: ->
        author_list = Meteor.users.findOne(@authorId).authored_list
        author_tags = Meteor.users.findOne(@authorId).authored_cloud

        your_list = Meteor.user().authored_list
        your_tags = Meteor.user().authored_cloud


        list_intersection = _.intersection(author_list, your_list)
        console.log 'list_intersection', list_intersection

        intersection_tags = []
        for tag in list_intersection
            author_count = author_tags.tag.count
            your_count = your_tags.tag.count
            lower_value = Math.min(author_count, your_count)
            cloud_object = name: tag, count: lower_value
            intersection_tags.push cloud_object

        console.log intersection_tags


Template.view.events
    'click .edit': ->
        Session.set 'editing', @_id
        selectedtags.clear()

    'click .vote_up': -> Meteor.call 'vote_up', @_id
    'click .vote_down': -> Meteor.call 'vote_down', @_id

    'click .doc_tag': -> if @valueOf() in selectedtags.array() then selectedtags.remove @valueOf() else selectedtags.push @valueOf()

    'click .select_user': -> if Session.equals('selected_user', @authorId) then Session.set('selected_user', null) else Session.set('selected_user', @authorId)
    'click .author_upvotes': -> if Session.equals('upvoted_cloud', @authorId) then Session.set('upvoted_cloud', null) else Session.set('upvoted_cloud', @authorId)
    'click .author_down votes': -> if Session.equals('downvoted_cloud', @authorId) then Session.set('downvoted_cloud', null) else Session.set('downvoted_cloud', @authorId)