Session.setDefault 'editing', null
@selected_tags = new ReactiveArray []

Accounts.ui.config
    passwordSignupFields: 'USERNAME_ONLY'
    dropdownClasses: 'simple'


Template.edit.helpers
    doc: ->
        docId = Session.get 'editing'
        Docs.findOne docId

    editorOptions: ->
        lineNumbers: false
        mode: 'markdown'
        lineWrapping: true


Template.edit.events
    'click #saveDoc': ->
        docId = Session.get 'editing'
        body = $('#body').val()

        Meteor.call 'save', docId, body

        Meteor.setTimeout (->
            doc = Docs.findOne docId
            # console.log doc
            selected_tags.push(tag) for tag in doc.tags
            Session.set 'editing', null
            ), 2000

    'keyup #addTag': (e,t)->
        e.preventDefault
        tag = $('#addTag').val().toLowerCase()
        switch e.which
            when 13
                if tag.length > 0
                    Docs.update Session.get('editing'),
                        $addToSet: tags: tag
                    $('#addTag').val('')


    'click #deleteDoc': ->
        Docs.remove @_id
        Session.set 'editing', null



Template.home.events
    'click .select_tag': -> selected_tags.push @name
    'click .unselect_tag': -> selected_tags.remove @valueOf()
    'click #clear_tags': -> selected_tags.clear()
    'click #addDoc': ->
        Meteor.call 'create', (err, response)->
            Session.set 'editing', response
    'keyup #search': (e)->
        switch e.which
            when 13
                if e.target.value is 'clear'
                    selected_tags.clear()
                    $('#search').val('')
                else
                    selected_tags.push e.target.value
                    $('#search').val('')
            when 8
                if e.target.value is ''
                    selected_tags.pop()

Template.home.onCreated ->
    @autorun -> Meteor.subscribe('tags', selected_tags.array())
    @autorun -> Meteor.subscribe('docs', selected_tags.array(), Session.get('editing'))

Template.home.helpers
    selected_tags: -> selected_tags.list()

    global_tags: ->
        doccount = Docs.find().count()
        if 0 < doccount < 3 then Tags.find { count: $lt: doccount } else Tags.find()

    docs: -> Docs.find {}


Template.view.helpers
    isAuthor: -> @authorId is Meteor.userId()
    doc_tag_class: -> if @valueOf() in selected_tags.array() then 'grey' else ''

Template.view.events
    'click .editDoc': -> Session.set 'editing', @_id
    'click .doc_tag': -> if @valueOf() in selected_tags.array() then selected_tags.remove @valueOf() else selected_tags.push @valueOf()
