Meteor.publish 'docs', (selected_keywords, selected_concepts, selected_screen_names)->
    Counts.publish(this, 'doc_counter', Docs.find(), { noReady: true })

    match = {}
    if selected_keywords.length > 0 then match.keyword_array = $all: selected_keywords
    if selected_concepts.length > 0 then match.concept_array = $all: selected_concepts
    if selected_concepts.length > 0 then match.concept_array = $all: selected_concepts
    if selected_screen_names.length > 0 then match.screen_name = $in: selected_screen_names

    Docs.find match, limit: 20

Meteor.publish 'doc', (id)-> Docs.find id

Meteor.publish 'people', -> Meteor.users.find {}

Meteor.publish 'person', (id)-> Meteor.users.find id

Meteor.publish 'screen_names', (selected_keywords, selected_concepts, selected_screen_names)->
    self = @

    match = {}
    if selected_keywords.length > 0 then match.keyword_array = $all: selected_keywords
    if selected_concepts.length > 0 then match.concept_array = $all: selected_concepts
    if selected_screen_names.length > 0 then match.screen_name = $in: selected_screen_names

    cloud = Docs.aggregate [
        { $match: match }
        { $project: screen_name: 1 }
        { $group: _id: '$screen_name', count: $sum: 1 }
        { $match: _id: $nin: selected_screen_names }
        { $sort: count: -1, _id: 1 }
        { $limit: 50 }
        { $project: _id: 0, text: '$_id', count: 1 }
        ]

    cloud.forEach (screen_name) ->
        self.added 'screen_names', Random.id(),
            text: screen_name.text
            count: screen_name.count
    self.ready()


Meteor.publish 'keywords', (selected_keywords, selected_concepts, selected_screen_names)->
    self = @

    match = {}
    if selected_keywords.length > 0 then match.keyword_array = $all: selected_keywords
    if selected_concepts.length > 0 then match.concept_array = $all: selected_concepts
    if selected_screen_names.length > 0 then match.screen_name = $in: selected_screen_names

    cloud = Docs.aggregate [
        { $match: match }
        { $project: keywords: 1 }
        { $unwind: '$keywords' }
        { $group: _id: '$keywords.text', count: $sum: 1 }
        { $match: _id: $nin: selected_keywords }
        { $sort: count: -1, _id: 1 }
        { $limit: 50 }
        { $project: _id: 0, text: '$_id', count: 1 }
        ]

    cloud.forEach (keyword) ->
        self.added 'keywords', Random.id(),
            text: keyword.text
            count: keyword.count

    self.ready()

Meteor.publish 'concepts', (selected_concepts, selected_keywords, selected_screen_names)->
    self = @

    match = {}
    if selected_keywords.length > 0 then match.keyword_array = $all: selected_keywords
    if selected_concepts.length > 0 then match.concept_array = $all: selected_concepts
    if selected_screen_names.length > 0 then match.screen_name = $in: selected_screen_names

    cloud = Docs.aggregate [
        { $match: match }
        { $project: concepts: 1 }
        { $unwind: '$concepts' }
        { $group: _id: '$concepts.text', count: $sum: 1 }
        { $match: _id: $nin: selected_concepts }
        { $sort: count: -1, _id: 1 }
        { $limit: 50 }
        { $project: _id: 0, text: '$_id', count: 1 }
        ]

    cloud.forEach (concept) ->
        self.added 'concepts', Random.id(),
            text: concept.text
            count: concept.count

    self.ready()
