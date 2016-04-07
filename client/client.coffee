
Meteor.startup ->
    GoogleMaps.load
        key: 'AIzaSyBluAacaAcSdXuk0hTRrnvoly0HI5wcf2Q'
        libraries: 'places'


Accounts.ui.config
    passwordSignupFields: 'USERNAME_ONLY'
    # dropdownClasses: 'simple'