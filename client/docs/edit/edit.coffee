Template.edit.onCreated ->
    self = @
    self.autorun ->
        docId = FlowRouter.getParam('docId')
        self.subscribe 'doc', docId


Template.edit.onRendered ->
    Meteor.setTimeout (->
        $('#body').froalaEditor
            height: 500
            toolbarButtonsXS: ['bold', 'italic', 'fontFamily', 'fontSize', 'undo', 'redo', 'insertImage']

    #     $('#datetimepicker').datetimepicker(
    #         onChangeDateTime: (dp,$input)->
    #             val = $input.val()

    #             # console.log moment(val).format("dddd, MMMM Do YYYY, h:mm:ss a")
    #             minute = moment(val).minute()
    #             hour = moment(val).format('h')
    #             date = moment(val).format('Do')
    #             ampm = moment(val).format('a')
    #             weekdaynum = moment(val).isoWeekday()
    #             weekday = moment().isoWeekday(weekdaynum).format('dddd')

    #             month = moment(val).format('MMMM')
    #             year = moment(val).format('YYYY')

    #             datearray = [hour, minute, ampm, weekday, month, date, year]
    #             datearray = _.map(datearray, (el)-> el.toString().toLowerCase())
    #             # datearray = _.each(datearray, (el)-> console.log(typeof el))

    #             docid = FlowRouter.getParam 'docId'

    #             doc = Docs.findOne docid
    #             tagsWithoutDate = _.difference(doc.tags, doc.datearray)
    #             tagsWithNew = _.union(tagsWithoutDate, datearray)

    #             Docs.update docid,
    #                 $set:
    #                     tags: tagsWithNew
    #                     datearray: datearray
    #                     dateTime: val
    #         )
        ), 300

    # @autorun ->
    #     if GoogleMaps.loaded()
    #         docId = FlowRouter.getParam('docId')
    #         $('#place').geocomplete().bind 'geocode:result', (event, result) ->
    #             # console.log result.geometry.location.lat()
    #             Meteor.call 'updatelocation', docId, result, ->

Template.edit.helpers
    doc: ->
        docId = FlowRouter.getParam('docId')
        Docs.findOne docId



Template.edit.events
    'keydown #addTag': (e,t)->
        e.preventDefault
        tag = $('#addTag').val().toLowerCase().trim()
        switch e.which
            when 13
                if tag.length > 0
                    Docs.update FlowRouter.getParam('docId'),
                        $addToSet: tags: tag
                    $('#addTag').val('')
                else
                    body = $('#body').val()
                    Docs.update FlowRouter.getParam('docId'),
                        $set:
                            body: body
                            tagCount: @tags.length
                    selectedTags.clear()
                    for tag in @tags
                        selectedTags.push tag
                    FlowRouter.go '/'
            when 8
                if tag.length is 0
                    last = @tags.pop()
                    Docs.update FlowRouter.getParam('docId'),
                        $pop: tags: 1
                    $('#addTag').val(last)

    'click .clearDT': ->
        tagsWithoutDate = _.difference(@tags, @datearray)
        Docs.update FlowRouter.getParam('docId'),
            $set:
                tags: tagsWithoutDate
                datearray: []
                dateTime: null
        $('#datetimepicker').val('')

    'click .clearAddress': ->
        tagsWithoutAddress = _.difference(@tags, @addresstags)
        Docs.update FlowRouter.getParam('docId'),
            $set:
                tags: tagsWithoutAddress
                addresstags: []
                locationob: null
        $('#place').val('')



    'click .docTag': ->
        tag = @valueOf()
        Docs.update FlowRouter.getParam('docId'),
            $pull: tags: tag
        $('#addTag').val(tag)


    'click #saveDoc': ->
        body = $('#body').val()
        Docs.update FlowRouter.getParam('docId'),
            $set:
                body: body
                tagCount: @tags.length
        selectedTags.clear()
        for tag in @tags
            selectedTags.push tag
        FlowRouter.go '/'


    'click #deleteDoc': ->
        if confirm 'Delete?'
            Meteor.call 'deleteDoc', @_id, (err, result)->
                if err then console.error err
                else
                    FlowRouter.go '/'
