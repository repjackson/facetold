@Offers = new Meteor.Collection 'offers'
@Tags = new Meteor.Collection 'tags'



Offers.helpers
    author: -> Meteor.users.findOne @aid

