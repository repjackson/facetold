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


Template.importerView.onCreated ->
    self = @
    self.autorun ->
        iId = FlowRouter.getParam('iId')
        self.subscribe 'importer', iId

    Template.instance().uploading = new ReactiveVar( false )
    return


Template.importerView.helpers
    importerDoc: ->
        iId = FlowRouter.getParam('iId')
        Importers.findOne iId

    uploading: ->
        Template.instance().uploading.get()


Template.importerView.events
    'keyup #importerName': (e)->
        switch e.which
            when 13
                id = FlowRouter.getParam('iId')
                Importers.update id,
                    $set: name: e.target.value

    'click #saveImporter': ->
        Meteor.call 'saveImporter', FlowRouter.getParam('iId'), $('#urlField').val(), $('#methodField').val(), ->
            FlowRouter.go '/importers'

    'click #runImporter': ->
        Meteor.call 'runImporter', @_id, (err, response)->
            Session.set 'jsonResponse', true

    'click #deleteImporter': ->
        if confirm "Delete this Importer?"
            Importers.remove @_id
            FlowRouter.go '/importers'

    'change [name="uploadCSV"]': (event, template) ->
        id = FlowRouter.getParam('iId')
        template.uploading.set true
        Papa.parse event.target.files[0],
            header: true
            complete: (results, file) ->
                console.log results.meta
                Importers.update id,
                    $set: fields: results.meta.fields
                Meteor.call 'parseUpload', results.data, (err, res) ->
                    if err
                        console.log error.reason
                    else
                        template.uploading.set false
                        Bert.alert 'Upload complete!', 'success', 'growl-top-right'