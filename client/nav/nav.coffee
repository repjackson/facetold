Template.nav.onRendered ->
    $('.button-collapse').sideNav();

Template.nav.onCreated ->
    self = @
    self.autorun ->
        self.subscribe 'people'


Template.nav.helpers
    doc_counter: -> Counts.get('doc_counter')
    user_counter: -> Meteor.users.find().count()
    userperson: -> Meteor.user()

Template.nav.events
    'click #addDoc': ->
        Meteor.call 'createDoc', (err, id)->
            if err
                console.log err
            else
                FlowRouter.go "/edit/#{id}"
