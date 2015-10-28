Template.recipe_view.helpers
    totaltimedisplay: ->
        if @totaltime < 60 then @totaltime+' mins'
        else
            hours = Math.floor(@totaltime / 60)
            mins = @totaltime % 60
            "#{hours} hours #{mins} mins"
