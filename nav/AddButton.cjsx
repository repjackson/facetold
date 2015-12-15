{ a, i } = React.DOM

@AddButton = React.createClass(
    # mixins: [ReactMeteorData]
    displayName: 'Add Button'

    clickAdd: ->
        self = @
        Meteor.call 'add', (err,postId)->
            self.setState editing: postId
        selectedtags.clear()


    render: ->
        a id:'add', className:'ui item', onClick:@clickAdd,
            i className:'plus icon'
            'Add'

  )