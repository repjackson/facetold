Template.edit.onCreated ->
    @autorun -> Meteor.subscribe 'doc', FlowRouter.getParam('docId')

Template.edit.helpers
    doc: -> Docs.findOne FlowRouter.getParam('docId')

    selectedfeatures: ->
        console.log 'parts', @parts
        parts = _.keys @parts?
        console.log parts

    availableFeatures: ->
        parts = _.keys @parts?
        _.difference(features, parts)

    templateEditName: ->
        @+'_edit'

Template.edit.events
    'click #save': ->
        Meteor.call 'saveDoc', FlowRouter.getParam('docId'), (err, result)->
            if err then throw new Meteor.Error err
            FlowRouter.go '/docs'

    'click #delete': ->
        $('.delete.modal').modal(
            onApprove: ->
                Meteor.call 'deleteDoc', FlowRouter.getParam('docId'), ->
                $('.ui.modal').modal('hide')
                FlowRouter.go '/docs'
        	).modal 'show'

    'click #addpart': ->
        part = @valueOf()
        Meteor.call 'addpart', FlowRouter.getParam('docId'), part, ->


    'click .removepart':->
        part = @valueOf()
        $('.ui.removepart.modal').modal(
            onApprove: ->
                Meteor.call 'removepart', FlowRouter.getParam('docId'), part, ->
                $('.ui.modal').modal('hide')
        	).modal 'show'
