Template.offer_edit.events
    'click #save': (e,t)->
        Session.set 'editing', null

    'click #delete': ->
        Offers.remove @_id
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
                    Offers.update @_id, { $addToSet: tags: val }, ->
                    $('#addtag').val('')
            when 8
                if val.length is 0
                    if @tags.length is 0
                        Offers.remove @_id
                    else
                        last =  @tags.slice(-1)
                        $('#addtag').val(last)
                        Offers.update @_id, { $pop: tags: 1 }, ->


    'click .removeoffertag': ->
        tag = @valueOf()
        if Template.instance().data.tags.length is 1
            Offers.remove Template.instance().data._id
        else
            Offers.update Template.instance().data._id, $pull: tags: tag
