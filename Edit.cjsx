{ div, a, i, small } = React.DOM

@Edit = React.createClass(





    render: ->
        div className:'ui segment',
            h3 className:'ui header',
                'Document Tags'
                (if tags
                    #clear_doc_tags.ui.basic.compact.button
                        i className:'remove icon'
                        'Clear All Tags'
                )
            div className:'ui divider'
            for tag in tags
                div className:'ui button large compact removetag',
                    i className:'minus icon'
                    "#{tag}"
            div className:'ui left icon small input',
                i className:'plus icon'
                input id:'addtag',type:'text',autofocus:''
        div className:'ui segment',
            h3 className:'ui header',
                'Suggested Tags'
                div className;'ui basic compact button',
                    i className:'wizard icon'
                    'Learn from Body'
                (if unique_suggested_tags
                    div className:'ui compact button',
                        i className:'up arrow icon'
                        'Add All Suggested Tags'
                    div className:'ui compact button',
                        i className:'remove icon'
                        'Clear Suggested Tags'
                )
            div className:'ui divider'
            for tag in unique_suggested_tags
                div className:'ui compact basic large button add_suggested_tag',
                    i className:'plus icon'
                    "#{tag}"
        div className:'ui segment',
            h3 className:'ui header',
                'Body'
            textarea value:@props.body
            # +CodeMirror id:"codebody" name:"someName" options:editorOptions code:body
            div null,
                h4 className:'ui header', "Doc Sentiment: #{docSentiment}"
                h4 className:'ui header', "Doc Sentiment Amount: #{docSentimentScore}"
            div null,
                h4 className:'ui.header', 'Keywords'
                for keyword in keywords
                    div className='ui button',
                        "#{keyword.text} #{keyword.relevance}"
        div null,
            div className:'ui big button',
                i className:'check icon'
                'Save'
            div className:'ui icon button',
                i className:'trash icon'






)

