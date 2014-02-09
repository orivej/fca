B = Backbone
R = React
RC = R.createClass
LinkedState = R.addons.LinkedStateMixin
{
  div, ul, li, p,
  table, caption, tr, th, td,
  form, label, input, button
} = R.DOM

delay = (ms, callback) ->
  setTimeout callback, ms

AttributesForm = RC
  render: ->
    (form {onSubmit: @explore}, [
      (label {}, 'Перечислите свойства через "|": '),
      (input {onChange: @onChange, style: {width: '50%'}, autoFocus: true}),
      (button {}, 'Исследовать')
    ])
  explore: ->
    @props.onExplore()
    false
  onChange: (e) ->
    @props.onAttributesChange e.target.value

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

hideIf = (cond, props) ->
  if cond
    props ?= {}
    props.style ?= {}
    props.style.display = 'none'
  props

ExamplesTable = RC
  render: ->
    rows = @props.examples.map (example) ->
      (ExamplesRow values: example)
    (table hideIf(not @props.attributes.length), [
      (caption {}, 'Примеры'),
      (ExamplesHeading attributes: @props.attributes),
      rows
    ])

RulesList = RC
  render: ->
    items = @props.rules.map ([from, to]) ->
      (li {}, if from.length then "Если #{from}, то #{to}" else "Всегда #{to}")
    (div hideIf(not items.length), [
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
  render: ->
    (div {}, [
      AttributesForm(onAttributesChange: @attributesChanged, onExplore: @explore),
      ExamplesTable(attributes: @state.attributes, examples: @state.examples),
      RulesList(rules: @state.rules)
    ])
  getInitialState: ->
    attributes: []
    examples: []
    rules: []
    model:
      attributes: []
      examples: []
      rules: []
  reset: ->
    @state.model.examples = []
    @state.model.rules = []
    @setState @state.model
  attributesChanged: (attributes) ->
    cur = @state.model.attributes
    next = _.chain attributes.split('|')
      .map (s) -> s.trim()
      .without ''
      .uniq()
      .value()
    unless _.isEqual cur, next
      @state.model.attributes = next
      @reset()
  explore: ->
    relation = manualRelation()
    fca.off('add-example').on 'add-example', (g1) =>
      @state.model.examples.push [g1].concat @state.attributes.map (m1) -> if relation(g1, m1) then '✓' else ''
      @setState @state.model
    fca.off('add-rule').on 'add-rule', (from, to) =>
      @state.model.rules.push [from, to]
      @setState @state.model
    fca.off('abort').on 'abort', =>
      @reset()
    @reset()
    delay 0, =>
      fca.explore [], @state.attributes, relation,
        confirmationMessage: (from, to) ->
          if from.length then "Если #{from}, то #{to}?" else "Всегда ли #{to}?"
        counterexampleMessage: 'Контрпример:'

R.renderComponent App(), document.body
