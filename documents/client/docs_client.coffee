selecteddoctags = new ReactiveArray []

Template.docs.onCreated ->
    @autorun -> Meteor.subscribe 'doctags', selecteddoctags.array()
    @autorun -> Meteor.subscribe 'docs', selecteddoctags.array()
    @autorun -> Meteor.subscribe 'allpeople'

Template.docs.helpers
    doctags: -> Doctags.find {}, limit: 20
    docs: -> Docs.find {}, limit: 10
    selecteddoctags: -> selecteddoctags.list()
    tagsettings: -> {
        position: 'bottom'
        limit: 10
        rules: [
            {
                collection: Doctags
                field: 'name'
                template: Template.tagresult
            }
        ]
    }

Template.docs.events
    'autocompleteselect #tagsearch': (event, template, doc)->
        selecteddoctags.push doc.name.toString()
        $('#tagsearch').val('')

    'keyup #globalsearch': (e,t)->
        e.preventDefault()
        if event.which is 13
            val = $('#globalsearch').val()
            if val is 'clear'
                selecteddoctags.clear()
                $('#tagsearch').val ''
                $('#globalsearch').val ''
            else
                selecteddoctags.push val.toString()
                $('#globalsearch').val ''

    'keyup #tagsearch': (event, template)->
        event.preventDefault()
        if event.which is 13
            val = $('#tagsearch').val()
            switch val
                when 'clear'
                    selecteddoctags.clear()
                    $('#tagsearch').val ''
                    $('#globalsearch').val ''


    'click .selectdoctag': -> selecteddoctags.push @name.toString()
    'click .unselectdoctag': -> selecteddoctags.remove @toString()
    'click #cleardoctags': -> selecteddoctags.clear()


Template.doc.helpers
    isAuthor: -> Meteor.userId() is @authorId
    cansend: -> @authorId not in Meteor.user().cantsendto
    when: -> moment(@timestamp).fromNow()
    user: -> Meteor.user()

Template.doc.events
    'click .editDoc': -> FlowRouter.go '/editdoc/'+@_id
    'click .sendpoint': -> Meteor.call 'sendpoint', @authorId, ->


Template.editdoc.onCreated ->
    @autorun -> Meteor.subscribe 'doc', FlowRouter.getParam('docId')

Template.editdoc.helpers
    doc: -> Docs.findOne FlowRouter.getParam 'docId'

Template.editdoc.events
    'click #generateTags': ->
        text = $('textarea').val()
        Meteor.call 'generateTags', FlowRouter.getParam('docId'), text
    'click .removeTag': -> Docs.update FlowRouter.getParam('docId'), $pull: doctags: @valueOf()
    'click #save': ->
        text = $('textarea').val()
        Meteor.call 'savedoc', FlowRouter.getParam('docId'), text, (err, result)->
            if err then throw new Meteor.Error err
            FlowRouter.go '/docs'

    'click #delete': ->
        $('.modal').modal(
            onApprove: ->
                Meteor.call 'deletedoc', FlowRouter.getParam('docId'), ->
                $('.ui.modal').modal('hide')
                FlowRouter.go '/docs'
        	).modal 'show'
    'keyup #addDocTag': (e)->
        e.preventDefault()
        if e.which is 13
            val = $('#addDocTag').val()
            Docs.update FlowRouter.getParam('docId'), $addToSet: doctags: val
            $('#addDocTag').val('')
