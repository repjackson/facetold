@selected_tags = new ReactiveArray []

Template.home.events
    'click .select_tag': -> selected_tags.push @name
    'click .unselect_tag': -> selected_tags.remove @valueOf()
    'click #clear_tags': -> selected_tags.clear()

    'keyup #search': (e)->
        switch e.which
            when 13
                if e.target.value is 'clear'
                    selected_tags.clear()
                    $('#search').val('')
                else
                    selected_tags.push e.target.value
                    $('#search').val('')
            when 8
                if e.target.value is ''
                    selected_tags.pop()
    'click #addDoc': ->
        newId = Docs.insert({})
        FlowRouter.go "/edit/#{newId}"

Template.home.onCreated ->
    Meteor.subscribe 'people'
    @autorun -> Meteor.subscribe('tags', selected_tags.array(), Session.get('view'))
    @autorun -> Meteor.subscribe('docs', selected_tags.array(), Session.get('view'))

Template.home.helpers
    global_tags: ->
        doccount = Docs.find().count()
        if 0 < doccount < 3 then Tags.find { count: $lt: doccount } else Tags.find()

    selected_tags: -> selected_tags.list()

    user: -> Meteor.user()
    docs: -> Docs.find()
