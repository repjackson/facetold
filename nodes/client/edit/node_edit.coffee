Template.node_edit.events
    'click #save': (e,t)->
        Session.set 'editing', null

    'click #delete': ->
        Nodes.remove @_id
        #Meteor.call 'calcusercloud', ->
        Session.set 'editing', null

    'keyup #addtag': (e,t)->
        e.preventDefault
        val = $('#addtag').val().toLowerCase()
        switch e.which
            when 13
                if val.length is 0
                    #Meteor.call 'calcusercloud', ->
                    Session.set 'editing', null
                else
                    Nodes.update @_id, { $addToSet: tags: val }, ->
                    $('#addtag').val('')
            when 8
                if val.length is 0
                    if @tags.length is 0
                        Nodes.remove @_id
                    else
                        last =  @tags.slice(-1)
                        $('#addtag').val(last)
                        Nodes.update @_id, { $pop: tags: 1 }, ->


    'click .removenodetag': ->
        tag = @valueOf()
        if Template.instance().data.tags.length is 1
            Nodes.remove Template.instance().data._id
        else
            Nodes.update Template.instance().data._id, $pull: tags: tag
