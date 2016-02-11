Template.edit.onCreated ->
    self = @
    self.autorun ->
        docId = FlowRouter.getParam('docId')
        self.subscribe 'doc', docId

Template.edit.helpers
    newPostTags: -> newPost.list()
    doc: ->
        docId = FlowRouter.getParam('docId')
        Docs.findOne docId
    editorOptions: ->
        lineNumbers: true
        mode: "markdown"
        lineWrapping: true

    docKeywordClass: ->
        docId = FlowRouter.getParam('docId')
        doc = Docs.findOne docId
        if @text in doc.tags then 'grey' else ''

Template.edit.events
    'keyup #addTag': (e,t)->
        e.preventDefault
        tag = $('#addTag').val().toLowerCase()
        switch e.which
            when 13
                if tag.length > 0
                    Docs.update FlowRouter.getParam('docId'),
                        $push: tags: tag
                    $('#addTag').val('')

    'click .docTag': ->
        tag = @valueOf()
        Docs.update FlowRouter.getParam('docId'),
            $pull: tags: @valueOf()
        $('#addTag').val(tag)

    'click #analyzeBody': ->
        Docs.update FlowRouter.getParam('docId'), $set: body: $('#body').val()
        Meteor.call 'analyze', FlowRouter.getParam('docId')

    'click #saveDoc': ->
        Docs.update FlowRouter.getParam('docId'),
            $set: body: $('#body').val()

        thisDocTags = @tags
        FlowRouter.go '/'
        selectedTags = thisDocTags

    'click .docKeyword': ->
        docId = FlowRouter.getParam('docId')
        doc = Docs.findOne docId
        if @text in doc.tags
            Docs.update FlowRouter.getParam('docId'), $pull: tags: @text
        else
            Docs.update FlowRouter.getParam('docId'), $push: tags: @text
