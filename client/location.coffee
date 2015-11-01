Meteor.startup ->
    GoogleMaps.load
        key: 'AIzaSyBWVZCEIuKZaRl04lCttrg7PneGJbJpcks'
        libraries: 'places'
Template.location.onRendered ->
    @autorun ->
        if GoogleMaps.loaded()
            $('#place').geocomplete(
                map: $('#map')
            ).bind 'geocode:result', (event, result) ->
                docid = Session.get 'editing'
                Meteor.call 'updatelocation', docid, result, ->