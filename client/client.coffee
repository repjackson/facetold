@selected_keywords = new ReactiveArray []
@selected_concepts = new ReactiveArray []


# Meteor.loginWithGoogle
#     requestOfflineToken: true
#     forceApprovalPrompt: false
#     requestPermissions: [ 'https://www.googleapis.com/auth/gmail.readonly' ]



Template.home.onCreated ->
    Meteor.subscribe 'people'
    @autorun -> Meteor.subscribe 'keywords', selected_keywords.array()
    @autorun -> Meteor.subscribe 'concepts', selected_concepts.array()
    @autorun -> Meteor.subscribe 'docs', selected_keywords.array(), selected_concepts.array()

Template.view.onCreated ->
    Meteor.subscribe 'person', @authorId


Template.home.helpers
    doc_counter: -> Counts.get('doc_counter')
    user_counter: -> Meteor.users.find().count()

    global_keywords: -> Keywords.find()
    selected_keywords: -> selected_keywords.list()

    global_concepts: -> Concepts.find()
    selected_concepts: -> selected_concepts.list()

    user: -> Meteor.user()
    docs: -> Docs.find()

Template.home.events
    'click .select_keyword': -> selected_keywords.push @text
    'click .unselect_keyword': -> selected_keywords.remove @valueOf()
    'click #clear_keywords': -> selected_keywords.clear()

    'click .select_concept': -> selected_concepts.push @text
    'click .unselect_concept': -> selected_concepts.remove @valueOf()
    'click #clear_concepts': -> selected_concepts.clear()

    'click .clear_docs': -> Meteor.call 'clear_docs'

    # 'click .get_messages': -> Meteor.call 'get_messages'
    'click .get_tweets': -> Meteor.call 'get_tweets'


Template.view.helpers
    doc_keyword_class: -> if @text.valueOf() in selected_keywords.array() then 'grey' else ''
    doc_concept_class: -> if @text.valueOf() in selected_concepts.array() then 'grey' else ''

