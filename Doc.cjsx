{ div, a, i, button, hr } = React.DOM

@Doc = React.createClass(
    mixins: [ReactMeteorData]

    getMeteorData: ->
        Meteor.subscribe 'person', @authorId

    isAuthor: -> Meteor.userId() is @props.doc.authorId

    render: ->
        div null,
            #{body}
            div null, "Doc Sentiment: #{@props.doc.docSentiment}"
            div null, "Doc Sentiment Amount: #{@props.doc.docSentimentScore}"
            div className:'tags',
                'Yaki Tags'
                @props.doc.tags.map (tag)->
                    div className:'ui small compact button',
                        i.tag.icon
                        #{tag}
            div className:'keywords',
                'Alchemy Keywords'
                # @props.doc.keywords.map (keyword)->
                #     div className:'ui button',
                #         "#{keyword.text} #{keyword.relevance}"
            hr null
            div className:'footer',
                "#{@props.doc.authorId}"
                (if @isAuthor()
                    button null,
                        "by #{@props.doc.authorId}"
                )
                button onclick=@clickEdit,
                    'Edit'

)

