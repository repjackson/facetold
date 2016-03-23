Template.viewSmall.onCreated ->
    Meteor.subscribe 'person', @authorId

Template.viewSmall.helpers
    isAuthor: -> @authorId is Meteor.userId()
    # vote_up_button_class: -> if Meteor.userId() in @up_voters then 'active' else ''
    # vote_down_button_class: -> if Meteor.userId() in @down_voters then 'active' else ''
    when: -> moment(@timestamp).fromNow()
    doc_tag_class: -> if @valueOf() in selected_tags.array() then 'btn-default active' else 'btn-default'
    author: -> Meteor.users.findOne(@authorId)
    currentUserDonations: ->
        if @donators and Meteor.userId() in @donators
            result = _.find @donations, (donation)->
                donation.user is Meteor.userId()
            result.amount
        else return 0
    canRetrievePoints: -> if @donators and Meteor.userId() in @donators then true else false
    canSendPoints: -> Meteor.user().points > 0

Template.viewSmall.events
    'click .deletePost': -> if confirm 'Delete Post?' then Docs.remove @_id
    'click .cloneDoc': ->
        if confirm 'Clone Post?'
            id = Docs.insert
                tags: @tags
                timestamp: Date.now()
                authorId: Meteor.userId()
                username: Meteor.user().username
                points: 0
            FlowRouter.go "/edit/#{id}"

    'click .send_point': -> Meteor.call 'send_point', @_id
    'click .retrieve_point': -> Meteor.call 'retrieve_point', @_id

    'click .editDoc': -> FlowRouter.go "/edit/#{@_id}"
    'click .viewDoc': -> FlowRouter.go "/view/#{@_id}"

    'click .doc_tag': -> if @valueOf() in selected_tags.array() then selected_tags.remove @valueOf() else selected_tags.push @valueOf()

    'click .findTopDocMatches': ->
        Meteor.call 'findTopDocMatches', @_id, (err, result)->
            if err then console.error err
            else
                console.log result
    'click .sendpoint': -> Meteor.call 'sendpoint', @authorId, ->
