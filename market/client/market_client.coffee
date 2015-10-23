selectedItemTags = new ReactiveArray []

Template.market.helpers
    itemTags: ->
        itemCount = Marketitems.find().count()
        if 0 < itemCount < 5 then Itemtags.find { count: $lt: itemCount } else Itemtags.find {}

    marketitems: -> Marketitems.find {}, limit: 5

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
    'click #addItem': -> Meteor.call 'addItem', (err, newItemId)->
        if err then throw new Meteor.Error err
        FlowRouter.go '/edititem/'+newItemId

    'autocompleteselect #marketItemSearch': (event, template, doc)->
        selectedItemTags.push doc.name.toString()
        $('#marketItemSearch').val('')

    'keyup #globalItemSearch': (e,t)->
        e.preventDefault()
        if event.which is 13
            val = $('#globalItemSearch').val()
            if val is 'clear'
                selectedItemTags.clear()
                $('#marketItemSearch').val ''
                $('#globalItemSearch').val ''
            else
                selectedItemTags.push val.toString()
                $('#globalItemSearch').val ''

    'keyup #marketItemSearch': (event, template)->
        event.preventDefault()
        if event.which is 13
            val = $('#marketItemSearch').val()
            switch val
                when 'clear'
                    selectedItemTags.clear()
                    $('#marketItemSearch').val ''
                    $('#globalItemSearch').val ''


    'click .selectItemTag': -> selectedItemTags.push @name.toString()

    'click .unselectItemTag': -> selectedItemTags.remove @toString()

    'click #clearItemTags': -> selectedItemTags.clear()


Template.market.onCreated ->
    @autorun -> Meteor.subscribe 'itemTags', selectedItemTags.array()

    @autorun -> Meteor.subscribe 'marketItems', selectedItemTags.array()

    @autorun -> Meteor.subscribe 'allpeople'


Template.marketitem.helpers
    isAuthor: -> Meteor.userId() is @authorId

    canBuy: -> Meteor.user()?.points > @price

    when: -> moment(@timestamp).fromNow()

    itemTagLabelClass: -> if @valueOf() in selectedItemTags.array() then 'black' else ''

    user: -> Meteor.user()?


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

    'click #saveItem': ->
        text = $('textarea').val()
        price = $('#itemPrice').val()
        priceInt = parseInt(price)

        Meteor.call 'saveItem', FlowRouter.getParam('itemId'), text, priceInt, (err, result)->
            if err then throw new Meteor.Error err
            FlowRouter.go '/market'

    'click #deleteItem': ->
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
            Marketitems.update FlowRouter.getParam('itemId'),
                $addToSet: itemTags: val
                ,->
            $('#addItemTag').val('')
