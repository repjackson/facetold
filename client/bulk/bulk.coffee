Template.bulk.events
    'click #cleanNonStringTags': -> Meteor.call 'cleanNonStringTags', (err, response)->
        alert "Cleaned #{response} docs"

    'click #alchemize': -> Meteor.call 'alchemize', (err, response)->
        alert "Cleaned #{response} docs"