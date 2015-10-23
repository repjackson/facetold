
AccountsTemplates.configure
    defaultLayout: 'layout'
    defaultLayoutRegions: {}
    defaultContentRegion: 'main'
    showForgotPasswordLink: true
    #overrideLoginErrors: true
    enablePasswordChange: true
    negativeValidation: true
    positiveValidation: true
    negativeFeedback: false
    positiveFeedback: true

pwd = AccountsTemplates.removeField('password')
AccountsTemplates.removeField 'email'
AccountsTemplates.addFields [
    {
        _id: 'username'
        type: 'text'
        displayName: 'username'
        required: true
        minLength: 3
    }
    {
        _id: 'email'
        type: 'email'
        required: false
        displayName: 'email'
        re: /.+@(.+){2,}\.(.+){2,}/
        errStr: 'Invalid email'
    }
    {
        _id: 'username_and_email'
        type: 'text'
        required: false
        displayName: 'Login'
    }
    pwd
]


AccountsTemplates.configureRoute 'changePwd'
AccountsTemplates.configureRoute 'forgotPwd'
AccountsTemplates.configureRoute 'resetPwd'
AccountsTemplates.configureRoute 'signIn'
AccountsTemplates.configureRoute 'signUp'
AccountsTemplates.configureRoute 'verifyEmail'
