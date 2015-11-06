Template.request_edit.onRendered ->
    Meteor.setTimeout(->
        $('#datetimepicker').datetimepicker()
    , 500)


Template.request_edit.events
    'click #saverequest': (e,t)->
        datetime = $('#datetimepicker').val()
        message = $('#message').val()

        Requests.update @_id,
            $set:
                datetime: datetime
                message: message

        Session.set 'editing',null

    'keyup #message': (e,t)->
        if e.which is 13
            datetime = $('#datetimepicker').val()
            message = $('#message').val()

            Requests.update @_id,
                $set:
                    datetime: datetime
                    message: message

            Session.set 'editing',null
