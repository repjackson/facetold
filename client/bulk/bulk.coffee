Template.bulk.onCreated ->
    Session.setDefault 'resultCount', null

Template.bulk.events
    'click #cleanNonStringTags': -> Meteor.call 'cleanNonStringTags', (err, response)->
        alert "Cleaned #{response} docs"

    'click #alchemize': -> Meteor.call 'alchemize', (err, response)->
        alert "Cleaned #{response} docs"

    'click #findDocsWithTag': (e,t)->
        tagSelector = t.find('#tagSelector').value
        Meteor.call 'findDocsWithTag', tagSelector, (err,res)->
            console.log res
            Session.set 'resultCount', res.count

    'keyup #tagSelector': (e)->
        switch e.which
            when 13
                query = e.target.value
                Session.set 'query', query
                Meteor.call 'findDocsWithTag', query, (err,res)->
                    console.log res
                    Session.set 'resultCount', res.count

    'click #deleteQueryDocs': ->
        if confirm 'Delete all docs matching query?'
            Meteor.call 'deleteQueryDocs', Session.get 'query', (err,res)->
                console.log res
                Bert.alert "Deleted #{res} docs", 'success', 'growl-top-right'