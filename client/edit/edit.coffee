Template.edit.onCreated ->
    self = @
    self.autorun ->
        docId = FlowRouter.getParam('docId')
        self.subscribe 'doc', docId


Template.edit.onRendered ->
    Meteor.setTimeout (->
        $('#datetimepicker').datetimepicker(
            onChangeDateTime: (dp,$input)->
                val = $input.val()

                # console.log moment(val).format("dddd, MMMM Do YYYY, h:mm:ss a")
                minute = moment(val).minute()
                hour = moment(val).format('h')
                date = moment(val).format('Do')
                ampm = moment(val).format('a')
                weekdaynum = moment(val).isoWeekday()
                weekday = moment().isoWeekday(weekdaynum).format('dddd')

                month = moment(val).format('MMMM')
                year = moment(val).format('YYYY')

                datearray = [hour, minute, ampm, weekday, month, date, year]

                docid = FlowRouter.getParam 'docId'

                doc = Docs.findOne docid
                tagsWithoutDate = _.difference(doc.tags, doc.datearray)
                tagsWithNew = _.union(tagsWithoutDate, datearray)

                Docs.update docid,
                    $set:
                        tags: tagsWithNew
                        datearray: datearray
                        dateTime: val
            )), 2000

    @autorun ->
        if GoogleMaps.loaded()
            $('#place').geocomplete().bind 'geocode:result', (event, result) ->
                docid = Session.get 'editing'
                Meteor.call 'updatelocation', docid, result, ->

Template.edit.helpers
    doc: ->
        docId = FlowRouter.getParam('docId')
        Docs.findOne docId

    editorOptions: ->
        lineNumbers: true
        mode: 'markdown'
        lineWrapping: true

    unpickedConcepts: ->
        _.difference @concept_array, @tags
    unpickedKeywords: ->
        _.difference @keyword_array, @tags

    docKeywordClass: ->
        docId = FlowRouter.getParam('docId')
        doc = Docs.findOne docId
        if @text.toLowerCase() in doc.tags then 'disabled' else ''

Template.edit.events
    'keyup #addTag': (e,t)->
        e.preventDefault
        tag = $('#addTag').val().toLowerCase()
        switch e.which
            when 13
                if tag.length > 0
                    Docs.update FlowRouter.getParam('docId'),
                        $push: tags: tag
                    $('#addTag').val('')
                else
                    Docs.update FlowRouter.getParam('docId'),
                        $set: body: $('#body').val()

                    thisDocTags = @tags
                    FlowRouter.go '/'
                    selectedTags = thisDocTags

    'click .clearDT': ->
        tagsWithoutDate = _.difference(@tags, @datearray)
        Docs.update FlowRouter.getParam('docId'),
            $set:
                tags: tagsWithoutDate
                datearray: []
                dateTime: null
        $('#datetimepicker').val('')

    'click #addAll': ->
        docId = FlowRouter.getParam('docId')
        doc = Docs.findOne docId

        Docs.update docId,
            $addToSet: tags: $each: doc.keyword_array

    'click .docTag': ->
        tag = @valueOf()
        Docs.update FlowRouter.getParam('docId'),
            $pull: tags: tag
        $('#addTag').val(tag)

    'click #analyzeBody': ->
        Docs.update FlowRouter.getParam('docId'),
            $set: body: $('#body').val()
        Meteor.call 'analyze', FlowRouter.getParam('docId')

    'click #saveDoc': ->
        Docs.update FlowRouter.getParam('docId'),
            $set: body: $('#body').val()

        thisDocTags = @tags
        FlowRouter.go '/'
        selectedTags = thisDocTags

    'click #deleteDoc': ->
        if confirm 'Delete this doc?'
            Docs.remove @_id
            FlowRouter.go '/'


    'click .docKeyword': ->
        docId = FlowRouter.getParam('docId')
        Docs.update docId, $addToSet: tags: @valueOf()
