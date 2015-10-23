@Wants = new Meteor.Collection 'wants'
@Offers = new Meteor.Collection 'offers'
@Places = new Meteor.Collection 'places'
@Docs = new Meteor.Collection 'docs'
@Doctags = new Meteor.Collection 'docTags'
@Messages = new Meteor.Collection 'messages'
@Marketitems = new Meteor.Collection 'marketitems'
@Itemtags = new Meteor.Collection 'itemTags'

FlowRouter.route '/',
    triggersEnter: [ (context, redirect) ->
        redirect '/people'
    ]

FlowRouter.route '/people',
    action: (params, queryParams)->
        BlazeLayout.render 'layout', main: 'peoplepage'

FlowRouter.route '/profile',
    action: (params, queryParams)->
        BlazeLayout.render 'layout', main: 'profile'

FlowRouter.route '/docs',
    action: (params, queryParams)->
        BlazeLayout.render 'layout', main: 'docs'

FlowRouter.route '/editdoc/:docId',
    action: (params, queryParams)->
        BlazeLayout.render 'layout', main: 'editdoc'

FlowRouter.route '/messages',
    action: (params, queryParams)->
        BlazeLayout.render 'layout', main: 'messages'

FlowRouter.route '/market',
    action: (params, queryParams)->
        BlazeLayout.render 'layout', main: 'market'

FlowRouter.route '/edititem/:itemId',
    action: (params, queryParams)->
        BlazeLayout.render 'layout', main: 'editItem'


Docs.helpers
    author: (doc)-> Meteor.users.findOne @authorId
Marketitems.helpers
    author: (doc)-> Meteor.users.findOne @authorId

Messages.helpers
    from: (doc)-> Meteor.users.findOne @fromId
    to: (doc)-> Meteor.users.findOne @toId
