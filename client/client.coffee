@selected_keywords = new ReactiveArray []
@dict = new ReactiveDict()
dict.set('weather', 'cloudy')


Template.nav.onCreated ->
    Meteor.subscribe 'person', Meteor.userId()

Template.home.onCreated ->
    Meteor.subscribe 'people'
    @autorun -> Meteor.subscribe 'keywords', selected_keywords.array()
    @autorun -> Meteor.subscribe 'docs', selected_keywords.array(), Session.get('editing')

Template.view.onCreated ->
    Meteor.subscribe 'person', @authorId

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
    Session.setDefault 'editing', null

Template.nav.events
    'click #add': ->
        Meteor.call 'add', (err,postId)-> Session.set 'editing', postId
        selected_keywords.clear()

Template.nav.helpers
    doc_counter: -> Counts.get('doc_counter')
    user_counter: -> Meteor.users.find().count()

Template.home.helpers
    global_keywords: ->
        doc_count = Docs.find().count()
        Keywords.find()
    selected_keywords: -> selected_keywords.list()
    is_editing: -> Session.equals 'editing',@_id
    user: -> Meteor.user()
    docs: -> Docs.find()

Template.home.events
    'click .select_keyword': -> selected_keywords.push @text
    'click .unselect_keyword': -> selected_keywords.remove @valueOf()
    'click #clear_keywords': -> selected_keywords.clear()


Template.edit.events
    'click #save': (e,t)->
        body = t.$('#codebody').val()
        Meteor.call 'save', @_id, body, ->
        Session.set 'editing', null
        selected_keywords.push(keyword) for keyword in @keyword_array

    'click #delete': ->
        if confirm 'Confirm delete'
            Docs.remove @_id, ->
            Session.set 'editing', null

    'click #analyze': ->
        body = $('textarea').val()
        Meteor.call 'analyze', @_id, body


Template.edit.helpers
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

    when:-> moment(@time).fromNow()

    doc_keyword_class: -> if @valueOf() in selected_keywords.array() then 'grey' else ''

Template.view.events
    'click .edit': ->
        Session.set 'editing', @_id
        selected_keywords.clear()

    # 'click .doc_keyword': ->
    #     if(@) in selected_keywords.array() then selected_keywords.remove(@) else selected_keywords.push(@)
