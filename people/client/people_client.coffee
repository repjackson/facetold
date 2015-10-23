#Accounts.ui.configure
    #passwordSignupFields: 'USERNAME_AND_OPTIONAL_EMAIL'



selectedwants = new ReactiveArray []
selectedoffers = new ReactiveArray []
selectedplaces = new ReactiveArray []



Template.wants.onCreated ->
    @autorun -> Meteor.subscribe 'wants', selectedwants.array(), selectedoffers.array(), selectedplaces.array()

Template.wants.helpers
    wants: -> Wants.find()
    selectedwants: -> selectedwants.list()

Template.wants.events
    'click .selectwant': -> selectedwants.push @name.toString()
    'click .unselectwant': -> selectedwants.remove @toString()
    'click #clearwants': -> selectedwants.clear()


Template.offers.onCreated ->
    @autorun -> Meteor.subscribe 'offers', selectedwants.array(), selectedoffers.array(), selectedplaces.array()

Template.offers.helpers
    offers: -> Offers.find()
    selectedoffers: -> selectedoffers.list()

Template.offers.events
    'click .selectoffer': -> selectedoffers.push @name.toString()
    'click .unselectoffer': -> selectedoffers.remove @toString()
    'click #clearoffers': -> selectedoffers.clear()


Template.places.onCreated ->
    @autorun -> Meteor.subscribe 'places', selectedwants.array(), selectedoffers.array(), selectedplaces.array()

Template.places.helpers
    places: -> Places.find()
    selectedplaces: -> selectedplaces.list()

Template.places.events
    'click .selectplace': -> selectedplaces.push @name.toString()
    'click .unselectplace': -> selectedplaces.remove @toString()
    'click #clearplaces': -> selectedplaces.clear()



Template.peoplelist.onCreated ->
    @autorun -> Meteor.subscribe 'people', selectedwants.array(), selectedoffers.array(), selectedplaces.array()

Template.peoplelist.helpers
    people: -> Meteor.users.find { _id: $ne: Meteor.userId() }



Template.person.events
    'keyup #message': (e,t)->
        e.preventDefault()
        if e.which is 13
            Meteor.call 'sendmessage', @_id, t.find('#message').value, ->

Template.person.helpers
    wantTagClass: -> if @valueOf() in selectedwants.array() then '' else 'basic'
    offerTagClass: -> if @valueOf() in selectedoffers.array() then '' else 'basic'
    placeTagClass: -> if @valueOf() in selectedplaces.array() then '' else 'basic'


Template.profile.events
    'keyup #addwant': (e)->
        e.preventDefault()
        if e.which is 13
            Meteor.call 'createSchema'
            jsonSchemaDoc = JSON.parse(Assets.getBinary('tree.jsonld'))
            jsonSchema = new JSONSchema(jsonSchemaDoc)
            simpleSchema = jsonSchema.toSimpleSchema()
            console.log simpleSchema
            console.log (tree.jsonld)

            #val = $('#addwant').val()
            #Meteor.users.update Meteor.userId(), $addToSet: "profile.wants": val
            #$('#addwant').val('')

    'keyup #addoffer': (e)->
        e.preventDefault()
        if e.which is 13
            val = $('#addoffer').val()
            Meteor.users.update Meteor.userId(), $addToSet: "profile.offers": val
            $('#addoffer').val('')

    'keyup #addplace': (e)->
        e.preventDefault()
        if e.which is 13
            val = $('#addplace').val()
            Meteor.users.update Meteor.userId(), $addToSet: "profile.places": val
            $('#addplace').val('')

    'click .removewant': -> Meteor.users.update Meteor.userId(), $pull: "profile.wants": @.valueOf()

    'click .removeoffer': -> Meteor.users.update Meteor.userId(), $pull: "profile.offers": @.valueOf()

    'click .removelocation': -> Meteor.users.update Meteor.userId(), $pull: "profile.places": @.valueOf()

Template.profile.helpers
    user: -> Meteor.user()
    flowDef:[
        {
            'formId': 'form1'
            'schemaFormat': 'SimpleSchema'
            'nextForm': 'form2'
            'nextRoute': 'fracsim'
            'collectionName': 'Jobs'
            'collectionId': 'JobID1'
            'schema':
                'Status_HydraulicFractureSimulation':
                    'type': 'string'
                    'defaultValue': 'submitted'
                    'autoflow': 'mapTo': 'Status.HydraulicFractureSimulation'
                    'autoform': 'type': 'hidden'
                'Status_ProppantTransportSimulation':
                    'type': 'string'
                    'defaultValue': 'submitted'
                    'autoflow': 'mapTo': 'Status.ProppantTransportSimulation'
                    'autoform': 'type': 'hidden'
                'demoMode':
                    'type': 'string'
                    'defaultValue': 1
                    'autoform': 'type': 'hidden'
                'Hydraulic Fracture': 'type': 'object'
                'Hydraulic Fracture.injectionRate':
                    'type': 'string'
                    'label': 'Injection Rate'
                    'defaultValue': '40'
                    'autoflow':
                        'mapTo': 'Simulations.FluidSimulation.BoundaryConditions.FlowRate'
                        'units': 'kg/s'
                'Hydraulic Fracture.fluidType':
                    'type': 'string'
                    'label': 'Fluid Type'
                    'autoform':
                        'defaultValue': 'Water'
                        'options': [
                            {
                                'label': 'Water'
                                'value': 'Water'
                                'density': '1000 kg m^{-3}'
                                'viscosity': '0.001 Pa s'
                            }
                            {
                                'label': 'Slick Stuff'
                                'value': 'Slick Stuff'
                                'density': '20'
                                'viscosity': '30'
                            }
                        ]
                    'autoflow': 'mapTo': 'Simulations.FluidSimulation.Materials.FluidType'
                'Hydraulic Fracture.density':
                    'type': 'string'
                    'label': 'Density'
                    'optional': true
                    'autoflow':
                        'displayOnly': true
                        'selectionDep': 'Hydraulic Fracture.fluidType'
                        'selectionDepProperty': 'density'
                'Hydraulic Fracture.viscosity':
                    'type': 'string'
                    'label': 'Viscosity'
                    'optional': true
                    'autoflow':
                        'displayOnly': true
                        'selectionDep': 'Hydraulic Fracture.fluidType'
                        'selectionDepProperty': 'viscosity'
                'Proppant': 'type': 'object'
                'Proppant.injectionTime':
                    'type': 'string'
                    'label': 'Injection Time'
                    'defaultValue': '600'
                    'autoflow':
                        'mapTo': 'Simulations.ProppantTransportSimulation.InjectionTime'
                        'units': 's'
                'Proppant.injectionRate':
                    'type': 'string'
                    'label': 'Injection Rate'
                    'defaultValue': '17'
                    'autoflow':
                        'mapTo': 'Simulations.ProppantTransportSimulation.InjectionRate'
                        'units': 'kg/s'
                'Proppant.amount':
                    'type': 'string'
                    'label': 'Amount'
                    'optional': true
                    'autoflow':
                        'displayOnly': true
                        'formula': '[Proppant.injectionTime] * [Proppant.injectionRate]'
                        'units': 'kg'
                'Proppant.proppantType':
                    'type': 'string'
                    'label': 'Proppant Type'
                    'autoform':
                        'defaultValue': 'Melior60'
                        'options': [
                            {
                                'label': 'WhiteSand100'
                                'value': 'WhiteSand100'
                                'density': '2650 kg m^{-3}'
                                'diameter': '0.00015 m'
                            }
                            {
                                'label': 'Kryptosphere25'
                                'value': 'Kryptosphere25'
                                'density': '3900 kg m^{-3}'
                                'diameter': '0.00078 m'
                            }
                            {
                                'label': 'WhiteSand30'
                                'value': 'WhiteSand30'
                                'density': '2650 kg m^{-3}'
                                'diameter': '0.000595 m'
                            }
                            {
                                'label': 'Melior60'
                                'value': 'Melior60'
                                'density': '1980 kg m^{-3}'
                                'diameter': '0.00025 m'
                            }
                        ]
                    'autoflow': 'mapTo': 'Simulations.ProppantTransportSimulation.Materials.ProppantType'
                'Proppant.density':
                    'type': 'string'
                    'label': 'Density'
                    'optional': true
                    'autoflow':
                        'displayOnly': true
                        'selectionDep': 'Proppant.proppantType'
                        'selectionDepProperty': 'density'
                'Proppant.diameter':
                    'type': 'string'
                    'label': 'Diameter'
                    'optional': true
                    'autoflow':
                        'displayOnly': true
                        'selectionDep': 'Proppant.proppantType'
                        'selectionDepProperty': 'diameter'
        }
        {
            'formId': 'form2'
            'schemaFormat': 'SimpleSchema'
            'nextForm': 'form3'
            'schema':
                'name':
                    'type': 'string'
                    'label': 'Your name'
                    'max': 50
                'email':
                    'type': 'string'
                    'label': 'E-mail address'
                'message':
                    'type': 'string'
                    'label': 'Message'
                    'optional': true
                    'max': 1000
        }
        {
            'formId': 'form3'
            'schemaFormat': 'SimpleSchema'
            'nextForm': 'form1'
            'schema':
                'testField2':
                    'type': 'string'
                    'label': 'Best NBA Team'
                    'defaultValue': 'Warriors'
                'testField3':
                    'type': 'string'
                    'label': 'Best Futbol Club'
                    'defaultValue': 'Barcelona'
        }
    ]
