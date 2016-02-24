Template.nav.onRendered ->
    $('.button-collapse').sideNav();

Template.nav.onCreated ->
    self = @
    self.autorun ->
        self.subscribe 'people'


Template.nav.helpers
    doc_counter: -> Counts.get('doc_counter')
    user_counter: -> Meteor.users.find().count()

Template.nav.events
    'click #addDoc': ->
        newId = Docs.insert({})
        FlowRouter.go "/edit/#{newId}"