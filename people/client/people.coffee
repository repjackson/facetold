Accounts.ui.config
    passwordSignupFields: 'USERNAME_ONLY'
    #dropdownClasses: 'simple'
    #dropdownTransition: 'scale'

selectedwants = new ReactiveArray []
selectedoffers = new ReactiveArray []
selectedplaces = new ReactiveArray []



Template.wants.onCreated ->
    @autorun -> Meteor.subscribe 'wants', selectedwants.array(), selectedoffers.array(), selectedplaces.array()

Template.wants.helpers
    wants: -> Wants.find()
    selectedwants: -> selectedwants.list()

Template.wants.events
    'click .selectwant': -> selectedwants.push @name.toString()
    'click .unselectwant': -> selectedwants.remove @toString()
    'click #clearwants': -> selectedwants.clear()


Template.offers.onCreated ->
    @autorun -> Meteor.subscribe 'offers', selectedwants.array(), selectedoffers.array(), selectedplaces.array()

Template.offers.helpers
    offers: -> Offers.find()
    selectedoffers: -> selectedoffers.list()

Template.offers.events
    'click .selectoffer': -> selectedoffers.push @name.toString()
    'click .unselectoffer': -> selectedoffers.remove @toString()
    'click #clearoffers': -> selectedoffers.clear()


Template.places.onCreated ->
    @autorun -> Meteor.subscribe 'places', selectedwants.array(), selectedoffers.array(), selectedplaces.array()

Template.places.helpers
    places: -> Places.find()
    selectedplaces: -> selectedplaces.list()

Template.places.events
    'click .selectplace': -> selectedplaces.push @name.toString()
    'click .unselectplace': -> selectedplaces.remove @toString()
    'click #clearplaces': -> selectedplaces.clear()



Template.peoplelist.onCreated ->
    @autorun -> Meteor.subscribe 'people', selectedwants.array(), selectedoffers.array(), selectedplaces.array()

Template.peoplelist.helpers
    people: -> Meteor.users.find { _id: $ne: Meteor.userId() }


Template.person.onRendered ->
    $('.shape').shape()


Template.person.events
    'keyup #message': (e,t)->
        e.preventDefault()
        if e.which is 13
            Meteor.call 'sendmessage', @_id, t.find('#message').value, ->



Template.profile.events
    'keyup #addwant': (e)->
        e.preventDefault()
        if e.which is 13
            val = $('#addwant').val()
            Meteor.users.update Meteor.userId(), $addToSet: "profile.wants": val
            $('#addwant').val('')

    'keyup #addoffer': (e)->
        e.preventDefault()
        if e.which is 13
            val = $('#addoffer').val()
            Meteor.users.update Meteor.userId(), $addToSet: "profile.offers": val
            $('#addoffer').val('')

    'keyup #addplace': (e)->
        e.preventDefault()
        if e.which is 13
            val = $('#addplace').val()
            Meteor.users.update Meteor.userId(), $addToSet: "profile.places": val
            $('#addplace').val('')

    'click .removewant': -> Meteor.users.update Meteor.userId(), $pull: "profile.wants": @.valueOf()
    'click .removeoffer': -> Meteor.users.update Meteor.userId(), $pull: "profile.offers": @.valueOf()
    'click .removelocation': -> Meteor.users.update Meteor.userId(), $pull: "profile.places": @.valueOf()

Template.profile.helpers
    user: -> Meteor.user()
