selectedtags = new ReactiveArray []


Template.home.onCreated ->
    @autorun -> Meteor.subscribe 'tags', selectedtags.array()
    @autorun -> Meteor.subscribe 'docs', selectedtags.array(), Session.get 'editing'
    @autorun -> Meteor.subscribe 'allpeople'

Template.home.helpers
    tags: ->
        docCount = Docs.find().count()
        if 0 < docCount < 5 then Tags.find { count: $lt: docCount } else Tags.find()
    docs: -> Docs.find {}, limit: 5
    isediting: -> Session.equals 'editing', @_id
    selectedtags: -> selectedtags.list()

Template.home.events
    'keyup #search': (e,t)->
        e.preventDefault()
        if e.which is 13
            val = $('#search').val()
            if val is 'clear'
                selectedtags.clear()
                $('#search').val ''
            else
                selectedtags.push val.toString()
                $('#search').val ''

    'click .selecttag': -> selectedtags.push @name.toString()

    'click .unselecttag': -> selectedtags.remove @toString()

    'click #cleartags': -> selectedtags.clear()

    'click #home': -> Session.set 'editing', null