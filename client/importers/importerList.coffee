Template.importerList.onCreated ->
    self = @
    self.autorun ->
        self.subscribe 'importers'


Template.importerList.helpers
    importers: -> Importers.find()

Template.importerList.events
    'click #addImporter': ->
        newId = Importers.insert
            authorId: Meteor.userId()
        FlowRouter.go "/importers/#{newId}"


    'click .editImporter': ->
        FlowRouter.go "/importers/#{@_id}"


    'keyup #importTweets': (event)->
        if event.keyCode is 13
            author = event.target.value.toLowerCase()
            Meteor.call 'get_tweets', author, (err, res)->
                if err and err.error is 'already-imported'
                    console.log err
                    Bert.alert "Tweets from #{author} already exist, not importing", 'danger', 'growl-top-right'
                else
                    console.log res
                    Bert.alert "Imported tweets from #{author}", 'success', 'growl-top-right'
                Meteor.setTimeout (->
                    event.target.value = ''
                    ), 2000
