{ div, a, i, input } = React.DOM

@App = React.createClass(
    mixins: [ReactMeteorData]
    displayName: 'Facet App'

    getInitialState: ->
        editing: null
        selected_user: null
        upvoted_cloud: null
        downvoted_cloud: null

    getMeteorData: ->
        {
            docs: Docs.find({}, sort: createdAt: -1).fetch()
            tags: Tags.find({}, sort: referenceNum: -1).fetch()
            currentUser: Meteor.user()
            doc_counter: Counts.get('doc_counter')
            user_counter: Meteor.users.find().count()
        }

    clickAdd: ->
        self = @
        Meteor.call 'add', (err,postId)->
            self.setState editing: postId
        selectedtags.clear()
        GAnalytics.pageview("/add")

    clickHome: ->
        @setState downvoted_cloud: null
        @setState selected_user: null
        @setState upvoted_cloud: null
        selectedtags.clear()


    renderDocs: ->
        @data.docs.map (doc) ->
            currentUserId = @data.currentUser and @data.currentUser._id
            showPrivateButton = doc.owner == currentUserId
            return <Doc key={doc._id} doc={doc} />

    renderTags: ->
        @data.tags.map (tag) ->
            return <Tag key={tag._id} tag={tag} />

    render: ->
        div id:'facetnav',
            # if not @state.editing
            div className:'ui menu',
                a href:'#',className:'ui item', onClick:@clickHome,
                    i className:'home icon'
                    'Facet'
                div className:'ui item', <AccountsUIWrapper />
                if @data.currentUser
                    [
                        a id:'add', className:'ui item', onClick:@clickAdd,
                            i className:'plus icon'
                            'Add'
                        a id:'mine', className:'ui item',
                            i className:'user icon'
                            'Mine'
                        a id:'my_upvoted', className:'ui item',
                            i className:'thumbs up icon'
                            'My Upvoted'
                        a id:'my_downvoted', className:'ui item',
                            i className:'thumbs down icon'
                            'My Downvoted'
                    ]
                div className:'ui item',
                    div className:'ui left icon input',
                        i className:'search icon'
                        input id:'search', type:'text', autofocus:''
                div className:'right menu',
                    div className:'ui item', "#{@data.user_counter} users"
                    div className:'ui item', "#{@data.doc_counter} docs"
    )