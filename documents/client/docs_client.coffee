selectedDocTags = new ReactiveArray []

Template.docs.onCreated ->
    @autorun -> Meteor.subscribe 'docTags', selectedDocTags.array()

    @autorun -> Meteor.subscribe 'docs', selectedDocTags.array()

    @autorun -> Meteor.subscribe 'allpeople'

Template.docs.helpers
    docTags: ->
        docCount = Docs.find().count()
        if 0 < docCount < 5 then Doctags.find { count: $lt: docCount } else Doctags.find()

    docs: -> Docs.find {}, limit: 5

    selectedDocTags: -> selectedDocTags.list()

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
    'click #addDoc': -> Meteor.call 'addDoc', (err, newDocId)->
        if err then throw new Meteor.Error err
        FlowRouter.go '/editdoc/'+newDocId

    'autocompleteselect #tagsearch': (event, template, doc)->
        selectedDocTags.push doc.name.toString()
        $('#tagsearch').val('')

    'keyup #globalsearch': (e,t)->
        e.preventDefault()
        if event.which is 13
            val = $('#globalsearch').val()
            if val is 'clear'
                selectedDocTags.clear()
                $('#tagsearch').val ''
                $('#globalsearch').val ''
            else
                selectedDocTags.push val.toString()
                $('#globalsearch').val ''

    'keyup #tagsearch': (event, template)->
        event.preventDefault()
        if event.which is 13
            val = $('#tagsearch').val()
            switch val
                when 'clear'
                    selectedDocTags.clear()
                    $('#tagsearch').val ''
                    $('#globalsearch').val ''


    'click .selectDocTag': -> selectedDocTags.push @name.toString()

    'click .unselectDocTag': -> selectedDocTags.remove @toString()

    'click #cleardocTags': -> selectedDocTags.clear()


Template.doc.helpers
    isAuthor: -> Meteor.userId() is @authorId
    cansend: -> @authorId not in Meteor.user().cantsendto
    when: -> moment(@timestamp).fromNow()
    user: -> Meteor.user()
    docTagLabelClass: -> if @valueOf() in selectedDocTags.array() then 'black' else 'basic'
    voteUpIconClass: -> if @_id in Meteor.user()?.upVotes? then '' else 'outline'


Template.doc.events
    'click .editDoc': ->
        FlowRouter.go '/editdoc/'+@_id

    'click .sendpoint': ->
        Meteor.call 'sendpoint', @authorId, ->

    'click .cloneDoc': -> Meteor.call 'cloneDoc', @_id, (err, newDocId)->
        if err then throw new Meteor.Error err
        FlowRouter.go '/editdoc/'+newDocId

    'click .voteUp': -> Meteor.call 'voteUp', @_id

Template.editdoc.onCreated ->
    @autorun -> Meteor.subscribe 'doc', FlowRouter.getParam('docId')

Template.editdoc.helpers
    doc: -> Docs.findOne FlowRouter.getParam 'docId'

Template.editdoc.events
    'click #generateTags': ->
        text = $('textarea').val()
        Meteor.call 'generateTags', FlowRouter.getParam('docId'), text

    'click .removeTag': ->
        Docs.update FlowRouter.getParam('docId'),
            $pull: docTags: @valueOf()
            , ->

    'click #save': ->
        text = $('textarea').val()
        Meteor.call 'saveDoc', FlowRouter.getParam('docId'), text, (err, result)->
            if err then throw new Meteor.Error err
            FlowRouter.go '/docs'

    'click #delete': ->
        $('.modal').modal(
            onApprove: ->
                Meteor.call 'deleteDoc', FlowRouter.getParam('docId'), ->
                $('.ui.modal').modal('hide')
                FlowRouter.go '/docs'
        	).modal 'show'

    'keyup #addDocTag': (e)->
        e.preventDefault()
        if e.which is 13
            val = $('#addDocTag').val()
            Docs.update FlowRouter.getParam('docId'), $addToSet: docTags: val
            $('#addDocTag').val('')
