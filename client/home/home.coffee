@selected_tags = new ReactiveArray []
@selected_usernames = new ReactiveArray []

Template.home.onCreated ->
    Meteor.subscribe 'people'
    @autorun -> Meteor.subscribe('usernames', selected_tags.array(), selected_usernames.array())
    @autorun -> Meteor.subscribe('tags', selected_tags.array(), Session.get('view'),selected_usernames.array())
    @autorun -> Meteor.subscribe('docs', selected_tags.array(), Session.get('view'),selected_usernames.array())

Template.home.helpers
    global_tags: ->
        # doccount = Docs.find().count()
        # if 0 < doccount < 3 then Tags.find { count: $lt: doccount } else Tags.find()
        Tags.find()
    global_usernames: -> Usernames.find()
    docs: -> Docs.find()

    selected_usernames: -> selected_usernames.list()
    selected_tags: -> selected_tags.list()

    user: -> Meteor.user()

Template.home.events
    'click .select_tag': -> selected_tags.push @name
    'click .unselect_tag': -> selected_tags.remove @valueOf()
    'click #clear_tags': -> selected_tags.clear()

    'click .select_username': -> selected_usernames.push @text
    'click .unselect_username': -> selected_usernames.remove @valueOf()
    'click #clear_usernames': -> selected_usernames.clear()


    'keyup #search': (e)->
        switch e.which
            when 13
                if e.target.value is 'clear'
                    selected_tags.clear()
                    $('#search').val('')
                else
                    selected_tags.push e.target.value.toLowerCase()
                    $('#search').val('')
            when 8
                if e.target.value is ''
                    selected_tags.pop()

    'click #addDoc': ->
        Meteor.call 'createDoc', (err, id)->
            if err
                console.log err
            else
                FlowRouter.go "/edit/#{id}"

    'click .authorFilterButton': (event)->
        if event.target.innerHTML in selected_usernames.array() then selected_usernames.remove event.target.innerHTML else selected_usernames.push event.target.innerHTML
