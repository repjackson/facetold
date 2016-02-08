@selected_keywords = new ReactiveArray []
@selected_concepts = new ReactiveArray []
@selected_screen_names = new ReactiveArray []



Template.view.onCreated ->
    Meteor.subscribe 'person', @authorId



Template.view.helpers
    doc_keyword_class: -> if @text.valueOf() in selected_keywords.array() then 'grey' else ''
    doc_concept_class: -> if @text.valueOf() in selected_concepts.array() then 'grey' else ''
    authorButtonClass: -> if @screen_name in selected_screen_names.array() then 'active' else ''

