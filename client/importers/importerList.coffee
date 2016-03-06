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


