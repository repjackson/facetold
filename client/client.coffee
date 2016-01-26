@selected_keywords = new ReactiveArray []


Meteor.loginWithGoogle
    requestOfflineToken: true
    forceApprovalPrompt: false
    requestPermissions: [ 'https://www.googleapis.com/auth/gmail.readonly' ]



Template.nav.onCreated ->
    Meteor.subscribe 'person', Meteor.userId()

Template.home.onCreated ->
    Meteor.subscribe 'people'
    @autorun -> Meteor.subscribe 'keywords', selected_keywords.array()
    @autorun -> Meteor.subscribe 'docs', selected_keywords.array()

Template.view.onCreated ->
    Meteor.subscribe 'person', @authorId


Template.nav.events
    'click .get_messages': ->
        Meteor.call 'get_gmail_messages', (err,response)->
            console.dir response

Template.nav.helpers
    doc_counter: -> Counts.get('doc_counter')
    user_counter: -> Meteor.users.find().count()

Template.home.helpers
    global_keywords: ->
        doc_count = Docs.find().count()
        Keywords.find()
    selected_keywords: -> selected_keywords.list()
    user: -> Meteor.user()
    docs: -> Docs.find()

Template.home.events
    'click .select_keyword': -> selected_keywords.push @text
    'click .unselect_keyword': -> selected_keywords.remove @valueOf()
    'click #clear_keywords': -> selected_keywords.clear()



Template.view.helpers
    doc_keyword_class: -> if @valueOf() in selected_keywords.array() then 'grey' else ''
