selectedtags = new ReactiveArray []

Accounts.ui.config passwordSignupFields: 'USERNAME_ONLY'

Session.setDefault 'editing', null
Session.setDefault 'mode', 'people'

Template.home.onCreated ->
    @autorun -> Meteor.subscribe 'tags', selectedtags.array(), Session.get('mode')
    @autorun -> Meteor.subscribe 'person', Meteor.userId()


Template.docs.helpers doclist: -> Docs.find {}
Template.docs.onCreated -> @autorun -> Meteor.subscribe 'docs', selectedtags.array(), Session.get 'editing'

Template.people.helpers peoplelist: -> Meteor.users.find {}
Template.people.onCreated -> @autorun -> Meteor.subscribe 'people', selectedtags.array()

Template.doc.helpers
    isAuthor: -> Meteor.userId() is @authorId
    isediting: -> Session.equals('editing', @_id)
    doctagclass: -> if @valueOf() in selectedtags.array() then 'grey' else 'basic'
    when:-> moment(@time).fromNow()
    templateEditName: -> @+'_edit'
    subtemplatecontext: ->
        part = Session.get 'selectedpart'
        console.log @parts?.part
        #Template.parentData(1).parts?[this]



Template.doc.events
    'click .edit': ->
        Session.set 'editing', @_id
        Meteor.setTimeout (->
            $('#addtag').focus()
            ),200

    'click #save': ->
        Meteor.call 'calcusercloud', ->
        Session.set 'editing', null

    'click #delete': ->
        docid = Session.get 'editing'
        Docs.remove docid
        Meteor.call 'calcusercloud', ->
        Session.set 'editing', null

    'click .doctag': ->
        if @valueOf() in selectedtags.array() then selectedtags.remove @valueOf() else selectedtags.push @valueOf()

Template.person.helpers
    persontagclass: -> if @name in selectedtags.array() then 'grey' else 'basic'

Template.person.events
    'click .persontag': ->
        if @name in selectedtags.array() then selectedtags.remove @name else selectedtags.push @name

Template.home.helpers
    ismydocsmode: -> Session.equals 'mode', 'mydocs'
    globaltags: ->
        #docCount = Docs.find().count()
        #if 0 < docCount < 5 then Tags.find { count: $lt: docCount } else Tags.find()
        Tags.find()
    editmode: -> Session.get('editing')
    selectedtags: -> selectedtags.list()
    user: -> Meteor.user()


Template.home.events
    'click #viewpeople': ->
        selectedtags.clear()
        Session.set 'mode','people'

    'click #viewmydocs': ->
        selectedtags.clear()
        Session.set 'mode','mydocs'

    'keyup #search': (e,t)->
        e.preventDefault()
        switch e.which
            when 13 #enter
                val = $('#search').val()
                switch val
                    when 'clear'
                        selectedtags.clear()
                        $('#search').val ''
                    when 'add'
                        if Meteor.userId()
                            newdocid = Docs.insert
                                authorId: Meteor.userId()
                                time: Date.now()
                                tags: []
                                , ->
                            Session.set 'editing', newdocid
                            Meteor.setTimeout (->
                                $('#addtag').focus()
                                ),200
                            $('#search').val ''
                    else
                        unless val.length is 0
                            selectedtags.push val.toString()
                            $('#search').val ''
            when 8 #backspace
                val = $('#search').val()
                if val.length is 0
                    selectedtags.pop()

    'click #add': ->
        Session.set 'mode', 'mydocs'
        newdocid = Docs.insert
            authorId: Meteor.userId()
            time: Date.now()
            tags: []
            , ->
        Session.set 'editing', newdocid
        Meteor.setTimeout (->
            $('#addtag').focus()
            ),200

    'keyup #addtag': (e,t)->
        e.preventDefault
        docid = Session.get 'editing'
        val = $('#addtag').val().toLowerCase()
        switch e.which
            when 13 #enter
                if val.length is 0
                    Meteor.call 'calcusercloud', ->
                    Session.set 'editing', null
                else
                    switch val
                        when 'location'
                            Docs.update docid,
                                $addToSet:
                                    tags: val
                                    parts: name: 'location'
                            $('#addtag').val('')
                        else
                            Docs.update docid, { $addToSet: tags: val }, ->
                            $('#addtag').val('')
            when 8 #backspace
                if val.length is 0
                    last =  @tags.slice(-1)
                    $('#addtag').val(last)
                    Docs.update docid, { $pop: tags: 1 }, ->

    'click .removedoctag': ->
        tag = @valueOf()
        docid = Session.get 'editing'
        doc = Docs.findOne docid
        Docs.update docid, $pull: tags: tag
        Meteor.users.update Meteor.userId(), $pull: tags: tag

    'click .selecttag': -> selectedtags.push @name.toString()

    'click .unselecttag': -> selectedtags.remove @toString()

    'click #cleartags': -> selectedtags.clear()

    'click #home': -> Session.set 'editing', null


Meteor.startup ->
    GoogleMaps.load
        key: 'AIzaSyBWVZCEIuKZaRl04lCttrg7PneGJbJpcks'
        libraries: 'places'


Template.edit.onRendered ->
    $('#datetimepicker').datetimepicker(
        onChangeDateTime: (dp,$input)->
            val = $input.val()

            console.log moment(val).format("dddd, MMMM Do YYYY, h:mm:ss a")
            minute = moment(val).minute()
            hour = moment(val).hour()

            datenum = moment(val).date()
            date = moment(datenum).format('Do')

            weekdaynum = moment(val).isoWeekday()
            weekday = moment(weekdaynum).format('dddd')

            monthnum = moment($input.val()).month()
            month = moment(monthnum).format('MMMM')

            datearray = [minute, hour, date, weekday, month]
            console.log datearray

            docid = Session.get 'editing'

            doc = Docs.findOne docid
            tagswithoutdate = _.difference(doc.tags, doc.datearray)
            tagswithnew = _.union(tagswithoutdate, datearray)

            Docs.update docid,
                $set:
                    tags: tagswithnew
                    datearray: datearray
        )

    @autorun ->
        if GoogleMaps.loaded()
            $('#place').geocomplete().bind 'geocode:result', (event, result) ->
                docid = Session.get 'editing'
                Meteor.call 'updatelocation', docid, result, ->