@Messages = new Meteor.Collection 'messages'

FlowRouter.route '/',
    triggersEnter: [ (context, redirect) ->
        redirect '/docs'
    ]

FlowRouter.route '/docs',
    action: (params, queryParams)->
        BlazeLayout.render 'layout', main: 'docs'

FlowRouter.route '/edit/:docId',
    action: (params, queryParams)->
        BlazeLayout.render 'layout', main: 'edit'

FlowRouter.route '/messages',
    action: (params, queryParams)->
        BlazeLayout.render 'layout', main: 'messages'


Docs.helpers
    author: (doc)-> Meteor.users.findOne @authorId

Messages.helpers
    from: (doc)-> Meteor.users.findOne @fromId
    to: (doc)-> Meteor.users.findOne @toId


@Schemas = {}

@features = ['recipe', 'review']