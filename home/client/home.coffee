@selectedtags = new ReactiveArray []

Template.home.onCreated ->
    @autorun -> Meteor.subscribe 'tags', selectedtags.array()
    @autorun -> Meteor.subscribe 'people'
    @autorun -> Meteor.subscribe 'person', Meteor.userId()
    @autorun -> Meteor.subscribe 'offers', selectedtags.array()

Template.home.helpers
    globaltags: ->
        offerCount = Offers.find().count()
        #console.log offerCount
        if 0 < offerCount < 5 then Tags.find { count: $lt: offerCount } else Tags.find()
        Tags.find()

    selectedtags: -> selectedtags.list()

    is_editing: -> Session.equals 'editing',@_id

    user: -> Meteor.user()

    offerlist: -> Offers.find {}, sort: time: -1

    mynumber: -> Meteor.user().number


Template.home.events
    'click #add': ->
        Meteor.call 'add_offer', (err,oid)->
            if err then console.log err
            Session.set 'editing', oid
            Meteor.setTimeout (->
                $('#addtag').focus()
                ), 500

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
                            oid = Offersinsert
                                aid: Meteor.userId()
                                time: Date.now()
                                tags: []
                                , ->
                            offer_edit.set(oid)
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


    'click .selecttag': -> selectedtags.push @name.toString()

    'click .unselecttag': -> selectedtags.remove @toString()

    'click #cleartags': -> selectedtags.clear()

    'click #home': -> Session.set 'editing', null

