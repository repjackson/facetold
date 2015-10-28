@Messages = new Meteor.Collection 'messages'

FlowRouter.route '/',
    action: (params, queryParams)->
        BlazeLayout.render 'layout', main: 'home'

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


@Features = ['recipe', 'review']