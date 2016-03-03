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

Template.importerView.onRendered ->
    Meteor.setTimeout ( ->
        $('select').material_select()
        ), 500
    return

Template.importerView.helpers
    importerDoc: ->
        iId = FlowRouter.getParam('iId')
        Importers.findOne iId

    uploading: ->
        Template.instance().uploading.get()

    selectedDataType: (fieldName)->
        console.log fieldname
        # console.log _.findWhere(@fieldsObject, {name: fieldName})

Template.importerView.events
    'keyup #importerName': (e)->
        switch e.which
            when 13
                id = FlowRouter.getParam('iId')
                Importers.update id,
                    $set: name: e.target.value
                    , (err, res)->
                        Bert.alert 'Importer Name Saved', 'success', 'growl-top-right'

    'keyup #importTag': (e)->
        switch e.which
            when 13
                id = FlowRouter.getParam('iId')
                Importers.update id,
                    $set: importTag: e.target.value
                    , (err, res)->
                        Bert.alert 'Importer Tag Saved', 'success', 'growl-top-right'


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

    'click #testRun': ->
        if confirm "Test this Importer?"
            Meteor.call 'testRunImporter', FlowRouter.getParam 'iId', (err, res)->
                if err then console.log error.reason
                else
                    console.log res

    'click .toggleTag': (e,t)->
        id = FlowRouter.getParam('iId')
        fieldName = e.currentTarget.id
        value = e.currentTarget.checked
        console.log fieldName
        Meteor.call 'toggleFieldTag', id, fieldName, value, (err, res)->
            if err then console.log error.reason
            else
                Bert.alert 'Setting Saved', 'success', 'growl-top-right'


    'change .typeSelector': (e,t)->
        id = FlowRouter.getParam('iId')
        fieldName = e.currentTarget.id
        value = e.currentTarget.value
        Meteor.call 'updateFieldType', id, fieldName, value, (err, res)->
            if err then console.log error.reason
            else
                Bert.alert 'Type Saved', 'success', 'growl-top-right'

    'change [name="uploadCSV"]': (event, template) ->
        id = FlowRouter.getParam('iId')
        template.uploading.set true
        Papa.parse event.target.files[0],
            header: true
            complete: (results, file) ->
                # console.log results
                # console.log results.data[0]
                fieldNames = results.meta.fields
                firstValues = _.values(results.data[0])
                fields = _.zip(fieldNames, firstValues)
                fieldsObject = _.map(fields, (field)->
                    name: field[0]
                    firstValue: field[1]
                    )
                Importers.update id,
                    $set:
                        fieldsObject: fieldsObject
                Meteor.call 'parseUpload', results.data, (err, res) ->
                    if err then console.log error.reason
                    else
                        template.uploading.set false
                        Bert.alert 'Upload complete!', 'success', 'growl-top-right'