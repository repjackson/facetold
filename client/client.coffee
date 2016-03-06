Meteor.startup ->
    GoogleMaps.load
        key: 'AIzaSyBluAacaAcSdXuk0hTRrnvoly0HI5wcf2Q'
        libraries: 'places'


Template.progressBar.helpers
    progress: ->
        Math.round @uploader.progress() * 100
