Template.edit.helpers
    selectedfeatures: ->
        console.log 'parts', @parts
        console.log 'selected',parts
        parts = _.keys @parts?
        console.log parts

    availableFeatures: ->
        console.log @
        parts = _.keys(@parts?)
        console.log 'availeble',parts
        _.difference(Features, parts)

    templateEditName: -> @+'_edit'

    subtemplatecontext: ->
        #console.log Template.parentData(1).parts?[this]
        Template.parentData(1).parts?[this]

Template.edit.events
    'click #save': -> Session.set 'editing', null

    'click #delete': ->
        $('.delete.modal').modal(
            onApprove: ->
                docid = Session.get 'editing'
                Docs.remove docid
                $('.ui.modal').modal('hide')
                Session.set 'editing', null
        	).modal 'show'

    'click #addpart': ->
        part = @valueOf()
        docid = Session.get 'editing'
        Docs.update docid,
            $addToSet:
                partlist: part
                tags: part

    'click .removepart': ->
        part = @valueOf()
        $('.ui.removepart.modal').modal(
            onApprove: ->
                docid = Session.get 'editing'
                Docs.update docid,
                    $pull:
                        partlist: part
                        tags: part
                    $unset: parts: part
                $('.ui.modal').modal('hide')
        	).modal 'show'