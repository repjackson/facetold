Template.registerHelper('Features', Features)

Accounts.ui.config
    passwordSignupFields: 'USERNAME_ONLY'

Session.setDefault 'editing', null

Template.doc.helpers
    isAuthor: -> Meteor.userId() is @authorId
    user: -> Meteor.user()
    templateViewName: -> "#{@}_view"
    subtemplatecontext: -> Template.parentData(1).parts?[this]

Template.doc.events
    'click .edit': -> Session.set 'editing', @_id

