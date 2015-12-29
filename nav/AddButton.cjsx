{ button, i } = React.DOM

@AddButton = React.createClass(
    # mixins: [ReactMeteorData]
    displayName: 'Add Button'

    getInitialState: ->
        selectedTags: []

    clickAdd: ->
        self = @
        Meteor.call 'add', (err,postId)->
            self.setState editing: postId
        @setState.selectedTags = []


    render: ->
        button onClick:@clickAdd, 'Add'

  )