@selectedtags = new ReactiveArray []


Accounts.ui.config
    passwordSignupFields: 'USERNAME_ONLY'

marked.setOptions
    renderer: new (marked.Renderer)
    gfm: true
    tables: true
    breaks: true
    pedantic: false
    sanitize: true
    smartLists: true
    smartypants: false

Meteor.startup ->
    React.render(<App />, document.getElementById('render-target'))
    Session.setDefault 'editing', null


Template.edit.events
    'click #save': (e,t)->
        body = t.$('#codebody').val()
        Meteor.call 'save', @_id, body, ->
        Session.set 'editing', null
        selectedtags.push(tag) for tag in @tags

    'click #delete': ->
        if confirm 'Confirm delete'
            Docs.remove @_id, ->
            Session.set 'editing', null

    'keyup #addtag': (e,t)->
        e.preventDefault
        val = $('#addtag').val().toLowerCase()
        if e.which is 13
            if val.length > 0
                Docs.update @_id, { $addToSet: tags: val }, ->
                $('#addtag').val('')
            else
                body = t.$('#codebody').val()
                Meteor.call 'save', @_id, body, ->
                Session.set 'editing', null

    'click .removetag': ->
        tag = @valueOf()
        Docs.update Template.instance().data._id,
            $pull: tags: tag
            , ->

    'click .add_suggested_tag': ->
        tag = @valueOf()
        Docs.update Template.instance().data._id,
            $addToSet: tags: tag
            , ->

    'click #suggest_tags': ->
        body = $('textarea').val()
        Meteor.call 'suggest_tags', @_id, body

    'click #add_all_suggested_tags': ->
        Docs.update @_id, $addToSet: tags: $each: @suggested_tags

    'click #clear_doc_tags': ->
        Docs.update @_id, $set: tags: []

    'click #clear_suggested_tags': ->
        Docs.update @_id, $set: suggested_tags: []


Template.edit.helpers
    unique_suggested_tags: -> _.difference(@suggested_tags, @tags)

    editorOptions: ->
        return {
            lineNumbers: false
            mode: "markdown"
            lineWrapping: true
            viewportMargin: Infinity
        }

Template.view.helpers
    is_editing: -> Session.equals 'editing',@_id

    isAuthor: -> Meteor.userId() is @authorId

    doc_tag_class: -> if @valueOf() in selectedtags.array() then 'grey' else ''



Template.view.events
    'click .edit': ->
        Session.set 'editing', @_id
        selectedtags.clear()

    'click .doc_tag': -> if @valueOf() in selectedtags.array() then selectedtags.remove @valueOf() else selectedtags.push @valueOf()
