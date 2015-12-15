{ span } = React.DOM

@AccountsUIWrapper = React.createClass(
    displayName: 'Accounts UI'
    componentDidMount: ->
        @view = Blaze.render(Template.loginButtons, React.findDOMNode(@refs.container))
    componentWillUnmount: -> Blaze.remove @view
    render: -> span ref:'container'
)
