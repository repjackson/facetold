@selectedTags = new ReactiveArray []

Meteor.startup ->
    GoogleMaps.load
        key: 'AIzaSyBluAacaAcSdXuk0hTRrnvoly0HI5wcf2Q'
        libraries: 'places'


Accounts.ui.config
    passwordSignupFields: 'USERNAME_AND_OPTIONAL_EMAIL'