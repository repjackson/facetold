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
                daySection = moment(val).format('a')
                weekdaynum = moment(val).isoWeekday()
                weekday = moment().isoWeekday(weekdaynum).format('dddd')

                month = moment(val).format('MMMM')
                year = moment(val).format('YYYY')

                datearray = [hour, minute, date, weekday, month, daySection, year]
                console.log datearray

                # docid = FlowRouter.getParam 'docId'

                # doc = Docs.findOne docid
                # tagswithoutdate = _.difference(doc.tags, doc.datearray)
                # tagswithnew = _.union(tagswithoutdate, datearray)

                # Docs.update docid,
                #     $set:
                #         tags: tagswithnew
                #         datearray: datearray
            )), 3000

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

    # unpickedConcepts: ->
    #     diff = _.map @tags, (tag)->
    #         tag.toLowerCase() in @concept_array
    # unpickedKeywords: ->
    #     keywordNames = keyword.text for keyword in @keywords
    #     console.log keywordNames
    #     _.difference @tags, @keywords



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


    'click .docTag': ->
        tag = @valueOf()
        Docs.update FlowRouter.getParam('docId'),
            $pull: tags: @valueOf()
        $('#addTag').val(tag)

    'click #analyzeBody': ->
        Docs.update FlowRouter.getParam('docId'), $set: body: $('#body').val()
        Meteor.call 'analyze', FlowRouter.getParam('docId')

    'click #saveDoc': ->
        Docs.update FlowRouter.getParam('docId'),
            $set: body: $('#body').val()

        thisDocTags = @tags
        FlowRouter.go '/'
        selectedTags = thisDocTags

    'click .docKeyword': ->
        docId = FlowRouter.getParam('docId')
        doc = Docs.findOne docId
        loweredTag = @text.toLowerCase()
        if @text in doc.tags
            Docs.update FlowRouter.getParam('docId'), $pull: tags: loweredTag
        else
            Docs.update FlowRouter.getParam('docId'), $push: tags: loweredTag
