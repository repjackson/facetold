FlowRouter.route '/',
    action: (params) ->
        Session.set('view', 'all')
        BlazeLayout.render 'layout', main: 'home'

FlowRouter.route '/edit/:docId', action: (params) -> BlazeLayout.render 'layout', main: 'edit'

FlowRouter.route '/importers', action: (params) -> BlazeLayout.render 'layout', main: 'importerList'

FlowRouter.route '/importers/:iId', action: (params) -> BlazeLayout.render 'layout', main: 'importerView'

FlowRouter.route '/bulk', action: (params) -> BlazeLayout.render 'layout', main: 'bulk'

FlowRouter.route '/mine',
    action: (params) ->
        Session.set('view', 'mine')
        BlazeLayout.render 'layout', main: 'home'

FlowRouter.route '/profile', action: (params) -> BlazeLayout.render 'layout', main: 'profile'