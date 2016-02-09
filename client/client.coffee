@selected_tags = new ReactiveArray []
@selected_usernames = new ReactiveArray []
@newPost = new ReactiveArray []

Accounts.ui.config
    passwordSignupFields: 'USERNAME_ONLY'


Template.view.onCreated ->
    Meteor.subscribe 'person', @authorId

Template.home.onCreated ->
    Meteor.subscribe 'people'

    @autorun -> Meteor.subscribe('tags', selected_tags.array())
    @autorun -> Meteor.subscribe('docs', selected_tags.array())

Template.home.helpers
    doc_counter: -> Counts.get('doc_counter')
    user_counter: -> Meteor.users.find().count()

    global_tags: -> Tags.find()
    selected_tags: -> selected_tags.list()

    newPostTags: -> newPost.list()

    user: -> Meteor.user()
    docs: -> Docs.find()

Template.home.events
    'click .select_tag': -> selected_tags.push @name
    'click .unselect_tag': -> selected_tags.remove @valueOf()
    'click #clear_tags': -> selected_tags.clear()

    'keyup #addNew': (e,t)->
        e.preventDefault
        val = $('#addNew').val().toLowerCase()
        switch e.which
            when 13
                if val.length > 0
                    newPost.push val
                    $('#addNew').val('')
                else
                    Meteor.call 'save', newPost.array()
                    newPost.clear()
            when 8
                newPost.pop()


Template.view.helpers
    doc_tag_class: -> if @valueOf() in selected_tags.array() then 'grey' else ''

    isAuthor: -> @authorId is Meteor.userId()

    vote_up_button_class: -> if Meteor.userId() is @authorId or not Meteor.userId() then 'disabled' else ''

    vote_up_icon_class: -> if Meteor.userId() and @up_voters and Meteor.userId() in @up_voters then '' else 'outline'

    vote_down_button_class: -> if Meteor.userId() is @authorId or not Meteor.userId() then 'disabled' else ''

    vote_down_icon_class: -> if Meteor.userId() and @down_voters and Meteor.userId() in @down_voters then '' else 'outline'

    when:-> moment(@timestamp).fromNow()


Template.view.events
    'click .deletePost': ->
        if confirm 'Delete Post?' then Docs.remove @_id

    'click .vote_up': -> Meteor.call 'vote_up', @_id

    'click .vote_down': -> Meteor.call 'vote_down', @_id

    'click .doc_tag': -> if @valueOf() in selected_tags.array() then selected_tags.remove @valueOf() else selected_tags.push @valueOf()
