@Wants = new Meteor.Collection 'wants'
@Offers = new Meteor.Collection 'offers'
@Places = new Meteor.Collection 'places'


FlowRouter.route '/',
    action: (params, queryParams)->
        GAnalytics.pageview("/")
        BlazeLayout.render 'layout',
            nav: 'nav'
            wants: 'wants'
            offers: 'offers'
            places: 'places'
            main: 'people'

FlowRouter.route '/profile',
    action: (params, queryParams)->
        GAnalytics.pageview("/profile")
        BlazeLayout.render 'layout',
            nav: 'nav'
            main: 'profile'


if Meteor.isClient
    Accounts.ui.config
        passwordSignupFields: 'USERNAME_ONLY'
        dropdownClasses: 'simple'

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


    Template.people.onCreated ->
        @autorun -> Meteor.subscribe 'people', selectedwants.array(), selectedoffers.array(), selectedplaces.array()
    Template.people.helpers
        people: -> Meteor.users.find { _id: $ne: Meteor.userId() }

    Template.person.onRendered ->
        $('.shape').shape()

    Template.person.events
        'click .contact': (e,t)-> t.$('.shape').shape('flip over')
        'click .cancel': (e,t)-> t.$('.shape').shape('flip back')




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


if Meteor.isServer
    Meteor.users.allow
        insert: (userId, doc)-> true
        update: (userId, doc)-> true
        remove: (userId, doc)-> true

    Meteor.publish 'people', (selectedwants, selectedoffers, selectedplaces) ->
        match= {}
        if selectedwants.length > 0 then match["profile.wants"] = $all: selectedwants
        if selectedoffers.length > 0 then match["profile.offers"] = $all: selectedoffers
        if selectedplaces.length > 0 then match["profile.places"] = $all: selectedplaces

        Meteor.users.find match, fields: username: 1, profile: 1

    Meteor.publish 'wants', (selectedwants, selectedoffers, selectedplaces)->
        self = @
        match= {}
        if selectedwants.length > 0 then match["profile.wants"] = $all: selectedwants
        if selectedoffers.length > 0 then match["profile.offers"] = $all: selectedoffers
        if selectedplaces.length > 0 then match["profile.places"] = $all: selectedplaces
        match._id= $ne: @userId

        cloud = Meteor.users.aggregate [
            { $match: match }
            { $project: "profile.wants": 1 }
            { $unwind: '$profile.wants' }
            { $group: _id: '$profile.wants', count: $sum: 1 }
            { $match: _id: $nin: selectedwants }
            { $sort: count: -1, _id: 1 }
            { $limit: 100 }
            { $project: _id: 0, name: '$_id', count: 1 } ]
        cloud.forEach (want) -> self.added 'wants', Random.id(), name: want.name, count: want.count
        self.ready()

    Meteor.publish 'offers', (selectedwants, selectedoffers, selectedplaces)->
        self = @
        match= {}
        if selectedwants.length > 0 then match["profile.wants"] = $all: selectedwants
        if selectedoffers.length > 0 then match["profile.offers"] = $all: selectedoffers
        if selectedplaces.length > 0 then match["profile.places"] = $all: selectedplaces
        match._id= $ne: @userId


        cloud = Meteor.users.aggregate [
            { $match: match }
            { $project: "profile.offers": 1 }
            { $unwind: '$profile.offers' }
            { $group: _id: '$profile.offers', count: $sum: 1 }
            { $match: _id: $nin: selectedoffers }
            { $sort: count: -1, _id: 1 }
            { $limit: 100 }
            { $project: _id: 0, name: '$_id', count: 1 } ]
        cloud.forEach (offer) -> self.added 'offers', Random.id(), name: offer.name, count: offer.count
        self.ready()

    Meteor.publish 'places', (selectedwants, selectedoffers, selectedplaces)->
        self = @
        match= {}
        if selectedwants.length > 0 then match["profile.wants"] = $all: selectedwants
        if selectedoffers.length > 0 then match["profile.offers"] = $all: selectedoffers
        if selectedplaces.length > 0 then match["profile.places"] = $all: selectedplaces
        match._id= $ne: @userId

        cloud = Meteor.users.aggregate [
            { $match: match }
            { $project: "profile.places": 1 }
            { $unwind: '$profile.places' }
            { $group: _id: '$profile.places', count: $sum: 1 }
            { $match: _id: $nin: selectedplaces }
            { $sort: count: -1, _id: 1 }
            { $limit: 100 }
            { $project: _id: 0, name: '$_id', count: 1 } ]
        cloud.forEach (place) -> self.added 'places', Random.id(), name: place.name, count: place.count
        self.ready()