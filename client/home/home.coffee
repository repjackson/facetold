@selected_tags = new ReactiveArray []

Template.home.onCreated ->
    Meteor.subscribe 'people'
    @autorun -> Meteor.subscribe('tags', selected_tags.array(), Session.get('view'))
    @autorun -> Meteor.subscribe('docs', selected_tags.array(), Session.get('view'))

Template.home.helpers
    global_tags: ->
        # doccount = Docs.find().count()
        # if 0 < doccount < 3 then Tags.find { count: $lt: doccount } else Tags.find()
        Tags.find()
    docs: -> Docs.find()

    selected_tags: -> selected_tags.list()

    user: -> Meteor.user()

Template.home.events
    'click .select_tag': -> selected_tags.push @name
    'click .unselect_tag': -> selected_tags.remove @valueOf()
    'click #clear_tags': -> selected_tags.clear()


    'click .authorFilterButton': (event)->
        if event.target.innerHTML in selected_usernames.array() then selected_usernames.remove event.target.innerHTML else selected_usernames.push event.target.innerHTML
