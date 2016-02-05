@Docs = new Meteor.Collection 'docs'
@Keywords = new Meteor.Collection 'keywords'
@Concepts = new Meteor.Collection 'concepts'


FlowRouter.route '/profile/:username', action: (params, queryParams) ->
    console.log 'Yeah! We are on the post:', params.username
