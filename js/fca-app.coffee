B = Backbone
R = React
RC = R.createClass
LinkedState = R.addons.LinkedStateMixin
{
  div, ul, li, p,
  table, caption, tr, th, td,
  form, label, input, button
} = R.DOM

AttributesForm = RC
  render: ->
    (form {onSubmit: @explore}, [
      (label {}, 'Перечислите свойства через "|": '),
      (input {valueLink: @props.attributesValueLink, style: {width: '50%'}, autoFocus: true}),
      (button {}, 'Исследовать')
    ])
  explore: ->
    @props.onExplore()
    false

ExamplesHeading = RC
  render: ->
    cells = @props.attributes.map (attr) ->
      (th {}, attr)
    (tr {}, (th {}, ' '), cells)

ExamplesRow = RC
  render: ->
    cells = @props.values.map (val) ->
      (td {}, val)
    (tr {}, cells)

ExamplesTable = RC
  render: ->
    rows = @props.examples.map (example) ->
      (ExamplesRow values: example)
    (table {}, [
      (caption {}, 'Примеры'),
      (ExamplesHeading attributes: @props.attributes),
      rows
    ])

RulesList = RC
  render: ->
    items = @props.rules.map ([from, to]) ->
      (li {}, if from.length then "Если #{from}, то #{to}" else "Всегда #{to}")
    (div {}, [
      (p {}, 'Правила'),
      (ul {}, items)
    ])

manualRelation = () ->
  cache = {}
  (g1, m1) ->
    cache[g1] = cache[g1] or {}
    rel = cache[g1][m1]
    if rel? then rel else cache[g1][m1] = confirm "#{g1} — #{m1}?"

App = RC
  mixins: [LinkedState]
  render: ->
    (div {}, [
      AttributesForm(attributesValueLink: @linkState('attributes'), onExplore: @explore),
      ExamplesTable(attributes: @attributes(), examples: @state.examples),
      RulesList(rules: @state.rules)
    ])
  getInitialState: ->
    attributes: ''
    examples: []
    rules: []
    model:
      examples: []
      rules: []
  attributes: () ->
    _.chain @state.attributes.split('|')
    .map (s) -> s.trim()
    .without ''
    .uniq()
    .value()
  explore: ->
    relation = manualRelation()
    fca.off 'add-example'
    fca.on 'add-example', (g1) =>
      @state.model.examples.push [g1].concat @attributes().map (m1) -> if relation(g1, m1) then '✓' else ''
      @setState @state.model
    fca.off 'add-rule'
    fca.on 'add-rule', (from, to) =>
      @state.model.rules.push [from, to]
      @setState @state.model
    @state.model.examples = []
    @state.model.rules = []
    @setState @state.model
    fca.explore [], @attributes(), relation,
      confirmationMessage: (from, to) ->
        if from.length then "Если #{from}, то #{to}?" else "Всегда ли #{to}?"
      counterexampleMessage: 'Контрпример:'

R.renderComponent App(), document.body
