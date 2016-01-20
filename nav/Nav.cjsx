{ input, div, i, a} = React.DOM

@Nav = React.createClass(
    mixins: [ReactMeteorData]
    displayName: 'Facet App'

    getInitialState: ->
        editing: null

    getMeteorData: ->
        {
            doc_counter: Counts.get('doc_counter')
            user_counter: Meteor.users.find().count()
        }

    render: ->
        div id:'facetnav',
            # if not @state.editing
            div className:'ui menu',
                a href:'#',className:'ui item', onClick:@clickHome,
                    i className:'home icon'
                    'Facet'
                div className:'ui item',
                    <AccountsUIWrapper />
                <AddButton />
                <Search />
                div className:'right menu',
                    div className:'ui item', "#{@data.user_counter} users"
                    div className:'ui item', "#{@data.doc_counter} docs"


    )