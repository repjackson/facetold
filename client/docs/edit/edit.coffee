Template.edit.onCreated ->
    self = @
    self.autorun ->
        docId = FlowRouter.getParam('docId')
        self.subscribe 'doc', docId


Template.edit.onRendered ->
    Meteor.setTimeout (->
        $('#summernote').froalaEditor()
            # height: 300

    #     # $('.datepicker').pickadate
    #     #     selectMonths: true
    #     #     selectYears: 15
        # $('#datetimepicker').datetimepicker(
        #     onChangeDateTime: (dp,$input)->
        #         val = $input.val()

        #         # console.log moment(val).format("dddd, MMMM Do YYYY, h:mm:ss a")
        #         minute = moment(val).minute()
        #         hour = moment(val).format('h')
        #         date = moment(val).format('Do')
        #         ampm = moment(val).format('a')
        #         weekdaynum = moment(val).isoWeekday()
        #         weekday = moment().isoWeekday(weekdaynum).format('dddd')

        #         month = moment(val).format('MMMM')
        #         year = moment(val).format('YYYY')

        #         datearray = [hour, minute, ampm, weekday, month, date, year]
        #         datearray = _.map(datearray, (el)-> el.toString().toLowerCase())
        #         # datearray = _.each(datearray, (el)-> console.log(typeof el))

        #         docid = FlowRouter.getParam 'docId'

        #         doc = Docs.findOne docid
        #         tagsWithoutDate = _.difference(doc.tags, doc.datearray)
        #         tagsWithNew = _.union(tagsWithoutDate, datearray)

        #         Docs.update docid,
        #             $set:
        #                 tags: tagsWithNew
        #                 datearray: datearray
        #                 dateTime: val
        #     )
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

    userSettings: -> {
        position: 'bottom'
        limit: 10
        rules: [
            {
                collection: Meteor.users
                field: 'username'
                template: Template.userPill
            }
        ]
    }

	getFEContext: ->
        self = @
        console.log @
        {
          _value: self.myDoc.myHTMLField
          _keepMarkers: true
          _className: 'froala-reactive-meteorized-override'
          toolbarInline: true
          initOnClick: false
          tabSpaces: false
          '_onsave.before': (e, editor) ->
            # Get edited HTML from Froala-Editor
            newHTML = editor.html.get(true)
            # Do something to update the edited value provided by the Froala-Editor plugin, if it has changed:
            if !_.isEqual(newHTML, self.myDoc.myHTMLField)
              console.log 'onSave HTML is :' + newHTML
              myCollection.update { _id: self.myDoc._id }, $set: myHTMLField: newHTML
            false
            # Stop Froala Editor from POSTing to the Save URL

        }



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
                    FlowRouter.go '/'
            when 8
                console.log 'back'
                Docs.update FlowRouter.getParam('docId'),
                    $pull: tags: tag


    'click .docTag': ->
        tag = @valueOf()
        Docs.update FlowRouter.getParam('docId'),
            $pull: tags: tag
        $('#addTag').val(tag)


    'click #saveDoc': ->
        body = $('#body').val()
        Docs.update FlowRouter.getParam('docId'),
            $set: body: body
        FlowRouter.go '/'

    'click #deleteDoc': ->
        if confirm 'Delete?'
            Meteor.call 'deleteDoc', @_id, (err, result)->
                if err then console.error err
                else
                    FlowRouter.go '/'
