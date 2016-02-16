Template.importerList.onCreated ->
    self = @
    self.autorun ->
        self.subscribe 'importers'


Template.importerList.helpers
    importers: -> Importers.find()

Template.importerList.events
    'click #addImporter': ->
        Importers.insert
            authorId: Meteor.userId()

    'click .editImporter': ->
        FlowRouter.go "/importers/#{@_id}"

    'click .deleteImporter': ->
        # if confirm "Delete?"
        Importers.remove @_id

Template.importerView.onCreated ->
    self = @
    self.autorun ->
        iId = FlowRouter.getParam('iId')
        self.subscribe 'importer', iId


Template.importerView.helpers
    importerDoc: ->
        iId = FlowRouter.getParam('iId')
        Importers.findOne iId

Template.importerView.events
    'click #saveImporter': ->
        console.log $('#urlField').val()
        Meteor.call 'saveImporter', FlowRouter.getParam('iId'), $('#urlField').val(), ->
            FlowRouter.go '/importers'
