selectedtags = new ReactiveArray []
Template.registerHelper('Features', Features)

Accounts.ui.config passwordSignupFields: 'USERNAME_ONLY'

Session.setDefault 'editing', null
Session.setDefault 'selectedpart', null

Template.home.onCreated ->
    @autorun -> Meteor.subscribe 'tags', selectedtags.array()
    @autorun -> Meteor.subscribe 'docs', selectedtags.array(), Session.get 'editing'
    @autorun -> Meteor.subscribe 'allpeople'

Template.home.helpers
    isAuthor: -> Meteor.userId() is @authorId
    globaltags: ->
        docCount = Docs.find().count()
        if 0 < docCount < 5 then Tags.find { count: $lt: docCount } else Tags.find()
    docs: -> Docs.find {}, limit: 5
    isediting: -> Session.equals('editing', @_id)
    editmode: -> Session.get('editing')
    selectedtags: -> selectedtags.list()
    availableparts: -> _.difference(Features, @partlist)
    templateEditName: -> @+'_edit'
    subtemplatecontext: ->
        part = Session.get 'selectedpart'
        console.log @parts?.part
        #Template.parentData(1).parts?[this]
    user: -> Meteor.user()
    templateViewName: -> "#{@}_view"
    #subtemplatecontext: -> Template.parentData(1).parts?[this]


Template.home.events
    'click .partmenuitem': ->
        Session.set 'selectedpart', @valueOf()

    'click #addpart': ->
        part = @valueOf()
        parts = template.data.parts
        console.log parts
        docid = Session.get 'editing'
        Docs.update docid,
            $addToSet:
                partlist: part
                tags: part

    'click .removepart': ->
        part = @valueOf()
        $('.ui.removepart.modal').modal(
            onApprove: ->
                docid = Session.get 'editing'
                Docs.update docid,
                    $pull:
                        partlist: part
                        tags: part
                    $unset: parts: part
                $('.ui.modal').modal('hide')
        	).modal 'show'

    'click .edit': -> Session.set 'editing', @_id

    'click #save': -> Session.set 'editing', null

    'click #delete': ->
        $('.delete.modal').modal(
            onApprove: ->
                docid = Session.get 'editing'
                Docs.remove docid
                $('.ui.modal').modal('hide')
                Session.set 'editing', null
        	).modal 'show'

    'keyup #search': (e,t)->
        e.preventDefault()
        if e.which is 13
            val = $('#search').val()
            if val is 'clear'
                selectedtags.clear()
                $('#search').val ''
            else
                selectedtags.push val.toString()
                $('#search').val ''

    'click .selecttag': -> selectedtags.push @name.toString()

    'click .unselecttag': -> selectedtags.remove @toString()

    'click #cleartags': -> selectedtags.clear()

    'click #home': -> Session.set 'editing', null