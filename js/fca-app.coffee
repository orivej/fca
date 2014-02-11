B = Backbone
R = React
RC = R.createClass
LinkedState = R.addons.LinkedStateMixin
{
  div, ul, li, p,
  table, caption, thead, tbody, tr, th, td,
  form, label, input, button
} = R.DOM

delay = (ms, callback) ->
  setTimeout callback, ms

AttributesForm = RC
  render: ->
    (form {onSubmit: @props.onSubmit}, [
      (label {}, 'Перечислите свойства через "|": '),
      (input {
        ref: 'input'
        onChange: @onChange,
        style: {width: '70%'},
        autoFocus: true}),
    ])
  onChange: (e) ->
    @props.onAttributesChange e.target.value
  focus: ->
    @refs['input'].getDOMNode().focus()

ExamplesHeading = RC
  render: ->
    cells = @props.attributes.map (attr) ->
      (th {}, attr)
    (tr {}, (th {}, ' '), cells)

ExampleRow = RC
  render: ->
    cells = @props.example.vals.map (val) ->
      (td {}, (input {type: 'checkbox', disabled: true, checked: val}))
    (tr {}, [
      (td {}, @props.example.name)
      cells
    ])

ExampleAdd = RC
  render: ->
    cells = _(@props.length).times (i) ->
      (td {}, (input {type: 'checkbox', ref: i}))
    (tr {onKeyPress: @keyPress, onKeyUp: @keyUp}, [
      (td {}, (input {ref: 'name'})),
      cells,
      (td {}, (button {onClick: @add}, 'Добавить'))
    ])
  focus: ->
    @refs[i].getDOMNode().checked = false for i in [0...@props.length]
    @refs['name'].getDOMNode().value = ''
    @refs['name'].getDOMNode().focus()
  keyPress: (e) ->
    if e.keyCode == 13 then @add()
  keyUp: (e) ->
    if e.keyCode == 27 then @props.onCancel()
  add: ->
    @props.onAddExample
      name: @refs['name'].getDOMNode().value
      vals: @refs[i].getDOMNode().checked for i in [0...@props.length]
    @focus()

hideIf = (cond, props) ->
  if cond
    props ?= {}
    props.style ?= {}
    props.style.display = 'none'
  props

ExamplesTable = RC
  render: ->
    rows = @props.examples.map (example) ->
      (ExampleRow example: example)
    (table hideIf(not @props.attributes.length), [
      (caption {}, 'Примеры'),
      (thead {}, (ExamplesHeading attributes: @props.attributes)),
      (tbody {}, [
        rows,
        (ExampleAdd
          ref: 'exampleAdd',
          onAddExample: @props.onAddExample,
          onCancel: @props.onCancel,
          length: @props.attributes.length)
      ])
    ])
  focusAddExample: ->
    @refs.exampleAdd.focus()

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
      AttributesForm(
        ref: 'attributesForm'
        onAttributesChange: @attributesChanged,
        onSubmit: @focusAddExample),
      ExamplesTable(
        ref: 'examplesTable'
        onAddExample: @addExample,
        onCancel: @focusAttributesForm,
        attributes: @state.attributes,
        examples: @state.examples),
      RulesList(
        rules: @state.rules)
    ])
  getInitialState: ->
    @model =
      attributes: []
      examples: []
    _.extend {
      rules: []
    }, @model
  attributesChanged: (attributes) ->
    cur = @model.attributes
    next = _.chain attributes.split('|')
      .map (s) -> s.trim()
      .without ''
      .uniq()
      .value()
    unless _.isEqual cur, next
      @model.attributes = next
      @model.examples = []
      @setState @model
      @autoexplore()
  focusAddExample: ->
    @refs['examplesTable'].focusAddExample()
    false
  focusAttributesForm: ->
    @refs['attributesForm'].focus()
  addExample: (example) ->
    @model.examples.push example
    @setState @model
    @autoexplore()
  autoexplore: ->
    attrIndices = _.invert _.extend {}, @model.attributes
    @setState rules: fca.autoexplore @model.examples, @model.attributes, (g, m) ->
      g.vals[attrIndices[m]]

R.renderComponent App(), document.body
