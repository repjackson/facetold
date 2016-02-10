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

    'click #saveDoc': ->
        Docs.update FlowRouter.getParam('docId'),
            $set: body: $('#body').val()

        thisDocTags = @tags
        FlowRouter.go '/'
        selectedTags = thisDocTags