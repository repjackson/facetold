@selected_keywords = new ReactiveArray []
@selected_concepts = new ReactiveArray []
Session.setDefault 'author_filter', null



Template.home.onCreated ->
    Meteor.subscribe 'people'
    @autorun -> Meteor.subscribe('keywords', selected_keywords.array(), selected_concepts.array(), Session.get('author_filter'))
    @autorun -> Meteor.subscribe('concepts', selected_concepts.array(), selected_keywords.array(), Session.get('author_filter'))
    @autorun -> Meteor.subscribe('docs', selected_keywords.array(), selected_concepts.array(), Session.get('author_filter'))

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

    viewMyTweetsClass: -> if Session.equals 'author_filter', Meteor.user().profile.name then 'blue' else null
    hasReceivedTweets: -> Meteor.user().hasReceivedTweets

Template.home.events
    'click .select_keyword': -> selected_keywords.push @text
    'click .unselect_keyword': -> selected_keywords.remove @valueOf()
    'click #clear_keywords': -> selected_keywords.clear()

    'click .select_concept': -> selected_concepts.push @text
    'click .unselect_concept': -> selected_concepts.remove @valueOf()
    'click #clear_concepts': -> selected_concepts.clear()

    'click .clear_my_docs': -> Meteor.call 'clear_my_docs', ->
        Meteor.setTimeout (->
            Session.set 'author_filter', null
            ), 1000

    'click .get_tweets': -> Meteor.call 'get_tweets', Meteor.user().profile.name, ->
        Meteor.setTimeout (->
            Session.set 'author_filter', Meteor.user().profile.name
            ), 1000

    'click .view_my_tweets': -> if Session.equals('author_filter', Meteor.user().profile.name) then Session.set 'author_filter', null else Session.set 'author_filter', Meteor.user().profile.name

    'click .tweetViewAuthorButton': -> if Session.equals('author_filter', @screen_name) then Session.set 'author_filter', null else Session.set 'author_filter', @screen_name

    'keyup .authorName': (event)->
        if event.keyCode is 13
            Meteor.call 'get_tweets', event.target.value

    'click .authorFilterButton': (event)->
        if Session.equals('author_filter', event.target.innerHTML) then Session.set 'author_filter', null else Session.set 'author_filter', event.target.innerHTML

Template.view.helpers
    doc_keyword_class: -> if @text.valueOf() in selected_keywords.array() then 'grey' else ''
    doc_concept_class: -> if @text.valueOf() in selected_concepts.array() then 'grey' else ''
    authorButtonClass: -> if Session.equals('author_filter', @screen_name) then 'blue' else null

