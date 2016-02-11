@selected_permittags = new ReactiveArray []

Template.boulder.events
    'click .select_tag': -> selected_permittags.push @name
    'click .unselect_tag': -> selected_permittags.remove @valueOf()
    'click #clear_permittags': -> selected_permittags.clear()
    'click #loadData': -> Meteor.call 'loadBoulderData'
    'click #clearPermits': -> Meteor.call 'clearPermits'

Template.boulder.onCreated ->
    @autorun -> Meteor.subscribe('permittags', selected_permittags.array())
    @autorun -> Meteor.subscribe('permits', selected_permittags.array())

Template.boulder.helpers
    global_tags: -> Permittags.find()
    selected_permittags: -> selected_permittags.list()

    user: -> Meteor.user()
    permits: -> Permits.find()
