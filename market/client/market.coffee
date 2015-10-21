selectedItemTags = new ReactiveArray []

Template.market.helpers
    doctags: -> Doctags.find {}, limit: 20
    docs: -> Docs.find {}, limit: 10
    selectedItemTags: -> selectedItemTags.list()
    itemsettings: -> {
        position: 'bottom'
        limit: 10
        rules: [
            {
                collection: Itemtags
                field: 'name'
                template: Template.tagresult
            }
        ]
    }

Template.market.events
    'autocompleteselect #marketItemSearch': (event, template, doc)->
        selectedItemTags.push doc.name.toString()
        $('#marketItemSearch').val('')

    'keyup #globalItemsearch': (e,t)->
        e.preventDefault()
        if event.which is 13
            val = $('#globalItemsearch').val()
            if val is 'clear'
                selectedItemTags.clear()
                $('#marketItemSearch').val ''
                $('#globalItemsearch').val ''
            else
                selectedItemTags.push val.toString()
                $('#globalItemsearch').val ''

    'keyup #marketItemSearch': (event, template)->
        event.preventDefault()
        if event.which is 13
            val = $('#marketItemSearch').val()
            switch val
                when 'clear'
                    selectedItemTags.clear()
                    $('#marketItemSearch').val ''
                    $('#globalItemsearch').val ''


    'click .selectItemtag': -> selectedItemTags.push @name.toString()
    'click .unselectdoctag': -> selectedItemTags.remove @toString()
    'click #clearItemTags': -> selectedItemTags.clear()


Template.market.onCreated ->
    @autorun -> Meteor.subscribe 'itemTags', selectedItemTags.array()
    @autorun -> Meteor.subscribe 'items', selectedItemTags.array()
    @autorun -> Meteor.subscribe 'allpeople'


Template.marketitem.helpers
    isAuthor: -> Meteor.userId() is @authorId

    canBuy: -> Meteor.user().points > @price

    when: -> moment(@timestamp).fromNow()

    user: -> Meteor.user()


Template.marketitem.events
    'click .editItem': -> FlowRouter.go '/edititem/'+@_id

    'click .buyItem': -> Meteor.call 'buyItem', @_id, ->


Template.editItem.onCreated ->
    @autorun -> Meteor.subscribe 'item', FlowRouter.getParam('itemId')


Template.editItem.helpers
    item: -> Marketitems.findOne FlowRouter.getParam 'itemId'

Template.editItem.events
    'click #generateItemTags': ->
        text = $('textarea').val()
        Meteor.call 'generateItemTags', FlowRouter.getParam('itemId'), text

    'click .removeItemTag': ->
        Marketitems.update FlowRouter.getParam('itemId'), $pull: itemTags: @valueOf()

    'click #save': ->
        text = $('textarea').val()
        Meteor.call 'saveItem', FlowRouter.getParam('itemId'), text, (err, result)->
            if err then throw new Meteor.Error err
            FlowRouter.go '/docs'

    'click #delete': ->
        $('.modal').modal(
            onApprove: ->
                Meteor.call 'deleteItem', FlowRouter.getParam('itemId'), ->
                $('.ui.modal').modal('hide')
                FlowRouter.go '/market'
        	).modal 'show'

    'keyup #addItemTag': (e)->
        e.preventDefault()
        if e.which is 13
            val = $('#addItemTag').val()
            Docs.update FlowRouter.getParam('itemId'), $addToSet: doctags: val
            $('#addItemTag').val('')
