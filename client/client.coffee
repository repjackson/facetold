Accounts.ui.config passwordSignupFields: 'USERNAME_ONLY'


Meteor.startup ->
    Session.setDefault 'editing',null