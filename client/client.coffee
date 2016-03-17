Meteor.startup ->
    GoogleMaps.load
        key: 'AIzaSyBluAacaAcSdXuk0hTRrnvoly0HI5wcf2Q'
        libraries: 'places'

    @analytics.load Meteor.settings.segmentKey
    Tracker.autorun (c)->
        user = Meteor.user()
        if !user then return
        else
            analytics.identify user._id,
                name: user.profile.username
        c.stop()


Accounts.ui.config
    passwordSignupFields: 'USERNAME_AND_OPTIONAL_EMAIL'