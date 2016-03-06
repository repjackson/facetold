Slingshot.createDirective 'myFileUploads', Slingshot.S3Storage,
    bucket: 'facetlive'
    acl: 'public-read'
    AWSAccessKeyId: Meteor.settings.AWSAccessKeyId
    AWSSecretAccessKey: Meteor.settings.AWSSecretAccessKey
    authorize: ->
        #Deny uploads if user is not logged in.
        if !@userId
            message = 'Please login before posting files'
            throw new (Meteor.Error)('Login Required', message)
        true
    key: (file) ->
        #Store file into a directory by the user's username.
        user = Meteor.users.findOne(@userId)
        user.username + '/' + file.name