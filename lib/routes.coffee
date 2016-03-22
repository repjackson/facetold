FlowRouter.route '/', action: (params) ->
    analytics.page()
    Session.set('view', 'all')
    BlazeLayout.render 'layout', main: 'home'

FlowRouter.route '/edit/:docId', action: (params) ->
    analytics.page()
    BlazeLayout.render 'layout', main: 'edit'

FlowRouter.route '/view/:docId', action: (params) ->
    BlazeLayout.render 'layout', main: 'viewFull'

FlowRouter.route '/leaderboard', action: (params) ->
    BlazeLayout.render 'layout', main: 'leaderboard'

FlowRouter.route '/importers', action: (params) ->
    analytics.page()
    BlazeLayout.render 'layout', main: 'importerList'

FlowRouter.route '/importers/:iId', action: (params) ->
    analytics.page()
    BlazeLayout.render 'layout', main: 'importerView'

FlowRouter.route '/bulk', action: (params) ->
    analytics.page()
    BlazeLayout.render 'layout', main: 'bulk'

FlowRouter.route '/marketplace', action: (params) ->
    Session.set('view', 'marketplace')
    BlazeLayout.render 'layout', main: 'home'

FlowRouter.route '/mine', action: (params) ->
    analytics.page()
    Session.set('view', 'mine')
    BlazeLayout.render 'layout', main: 'home'

FlowRouter.route '/profile', action: (params) ->
    analytics.page()
    BlazeLayout.render 'layout', main: 'profile'