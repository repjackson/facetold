{ input, div, i } = React.DOM

@Search = React.createClass(
    keyupSearch: (e,t)->
        e.preventDefault()
        val = $('#search').val()
        switch e.which
            when 13 #enter
                switch val
                    when 'clear'
                        selectedtags.clear()
                        $('#search').val ''
                    else
                        unless val.length is 0
                            selectedtags.push val.toString()
                            $('#search').val ''
            when 8
                if val.length is 0
                    selectedtags.pop()

    render: ->
        div className:'ui item',
            div className:'ui left icon input',
                i className:'search icon'
                input id:'search', type:'text', autofocus:'', onKeyUp: @keyupSearch


    )