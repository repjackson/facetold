@selected_tags = new ReactiveArray []
@selected_usernames = new ReactiveArray []
@newPost = new ReactiveArray []

Accounts.ui.config
    passwordSignupFields: 'USERNAME_ONLY'


Template.view.onCreated ->
    Meteor.subscribe 'person', @authorId

Template.home.onCreated ->
    Meteor.subscribe 'people'

    @autorun -> Meteor.subscribe('usernames', selected_tags.array())
    @autorun -> Meteor.subscribe('tags', selected_tags.array())
    @autorun -> Meteor.subscribe('docs', selected_tags.array())

Template.home.helpers
    doc_counter: -> Counts.get('doc_counter')
    user_counter: -> Meteor.users.find().count()

    global_tags: -> Tags.find()
    selected_tags: -> selected_tags.list()

    global_usernames: -> Screennames.find()
    selected_usernames: -> selected_usernames.list()

    newPostTags: -> newPost.list()

    user: -> Meteor.user()
    docs: -> Docs.find()

Template.home.events
    'click .select_username': -> selected_usernames.push @text
    'click .unselect_username': -> selected_usernames.remove @valueOf()
    'click #clear_usernames': -> selected_usernames.clear()

    'click .select_tag': -> selected_tags.push @text
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
    doc_tag_class: -> if @text.valueOf() in selected_tags.array() then 'grey' else ''

    isAuthor: -> @authorId is Meteor.userId()


Template.view.events
    'click .deletePost': -> Docs.remove @_id