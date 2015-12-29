{ div, a, i, input, hr } = React.DOM

@App = React.createClass(
    mixins: [ReactMeteorData]
    displayName: 'Facet App'

    getInitialState: -> editing: null

    clickSelectTag: -> selectedtags.push @name.toString()

    # clickUnselectTag: -> selectedtags.remove @toString()

    clickClearTags: -> selectedtags.clear()

    getMeteorData: ->
        Meteor.subscribe 'people'
        Meteor.subscribe 'tags', selectedtags.array(), Session.get('selected_user')
        Meteor.subscribe 'docs', selectedtags.array(), Session.get('editing')

        # doccount = Docs.find().count()
        # globalTags = if doccount < 3 then Tags.find({ count: $lt: doccount }).fetch() else Tags.find().fetch()
        #Tags.find { count: $gt: 1 }
        #Tags.find()


        {
            is_editing: Session.equals 'editing',@_id
            user: Meteor.user()
            docs: Docs.find({}, sort: createdAt: -1).fetch()
            tags: Tags.find({}, sort: referenceNum: -1).fetch()
        }


    render: ->
        div null,
            <Nav />
            hr
            <TagCloud  />
            @data.docs.map (doc) ->
                div null,
                    <Doc key={doc._id} doc={doc} />
                    hr null
    )