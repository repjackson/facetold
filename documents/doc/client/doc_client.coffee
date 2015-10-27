Template.doc.helpers
    isAuthor: -> Meteor.userId() is @authorId

    cansend: -> @authorId not in Meteor.user().cantsendto

    when: -> moment(@timestamp).fromNow()

    user: -> Meteor.user()

    voteUpIconClass: -> if @_id in Meteor.user()?.upVotes? then '' else 'outline'

    parts: (e,t)->
        console.log @parts
        parts = _.keys @parts?
        console.log 'part array', parts
        parts

    templateViewName: ->
        @+'_view'

Template.doc.events
    'click .edit': ->
        FlowRouter.go '/edit/'+@_id

    'click .sendpoint': ->
        Meteor.call 'sendpoint', @authorId, ->

    'click .cloneDoc': -> Meteor.call 'cloneDoc', @_id, (err, newDocId)->
        if err then throw new Meteor.Error err
        FlowRouter.go '/edit/'+newDocId

    'click .voteUp': -> Meteor.call 'voteUp', @_id

