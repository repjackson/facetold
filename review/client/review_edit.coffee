Template.review_edit.events
    'click #good': (e,t)->
        Meteor.call 'updateName', FlowRouter.getParam('docId'), name
        $('#reviewname').val('')
