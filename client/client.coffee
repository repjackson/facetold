Session.setDefault 'editing', null
@selected_tags = new ReactiveArray []

Accounts.ui.config
    passwordSignupFields: 'USERNAME_ONLY'
    dropdownClasses: 'simple'


Template.edit.onCreated ->
    self = @
    self.autorun ->
        docId = Session.get 'editing'
        self.subscribe 'doc', docId


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

        Docs.update docId,
            $set: body: $('#body').val()
        Meteor.call 'analyze', docId
        doc = Docs.findOne docId
        Session.set 'editing', null
        selected_tags.push(tag) for tag in doc.tags

    'click #deleteDoc': ->
        if confirm 'Delete?'
            Docs.remove @_id
            Session.set 'editing', null



Template.home.events
    'click .select_tag': -> selected_tags.push @name
    'click .unselect_tag': -> selected_tags.remove @valueOf()
    'click #clear_tags': -> selected_tags.clear()
    'click #addDoc': ->
        Meteor.call 'create', (err, response)->
            Session.set 'editing', response

Template.home.onCreated ->
    @autorun -> Meteor.subscribe('tags', selected_tags.array())
    @autorun -> Meteor.subscribe('docs', selected_tags.array())

Template.home.helpers
    selected_tags: -> selected_tags.list()

    global_tags: ->
        doccount = Docs.find().count()
        if 0 < doccount < 3 then Tags.find { count: $lt: doccount } else Tags.find()

    docs: -> Docs.find {}, limit: 1


Template.view.helpers
    isAuthor: -> @authorId is Meteor.userId()

Template.view.events
    'click .editDoc': -> Session.set 'editing', @_id
