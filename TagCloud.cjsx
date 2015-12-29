{ div, button, i, a, small } = React.DOM

@TagCloud = React.createClass(

    mixins: [ReactMeteorData]
    displayName: 'Global Tag Cloud'

    getMeteorData: ->
        tags: Tags.find().fetch()
        selectedTags: selectedtags.list()

    render: ->
        # unless @props.editing
        div className='ui segment',
            @data.selectedTags.map (selectedTag) ->
                <SelectedTag key=selectedTag />
            @data.tags.map (tag)->
                <Tag key=tag.name tag=tag />
    )


@SelectedTag = React.createClass(
    render:->
        div className='ui large compact grey button',
            i className='minus icon'
            "#{@props.key}"
    )

@Tag = React.createClass(
    render:->
        button className='ui black button',
            "#{@props.tag.name}"
            "#{@props.tag.count}"
    )