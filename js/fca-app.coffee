R = React
RC = R.createClass
LinkedState = R.addons.LinkedStateMixin
{
  div, ul, li, p, small, br,
  table, caption, thead, tbody, tr, th, td,
  form, label, input, button
} = R.DOM

delay = (ms, callback) ->
  setTimeout callback, ms

AttributesForm = RC
  render: ->
    (form {onSubmit: @props.onSubmit}, [
      (label {}, 'Перечислите свойства через "|": '),
      (input {ref: 'input', onChange: @onChange, style: {width: '70%'}, autoFocus: true})])
  onChange: (e) ->
    @props.onAttributesChange e.target.value
  focus: ->
    @refs['input'].getDOMNode().focus()

ExamplesHeading = RC
  render: ->
    cells = @props.attributes.map (attr) ->
      (th {}, attr)
    (tr {}, (th {}, 'Пример'), cells)

ExampleRow = RC
  render: ->
    cells = @props.example.vals.map (val, i) =>
      (td {}, (input {ref: i, onChange: @onChange, type: 'checkbox', checked: val}))
    (tr {}, [
      (td {}, @props.example.name)
      cells
      (td {}, (button {onClick: @onDelete, title: 'Удалить'}, '−'))
    ])
  onChange: (e) ->
    @props.onChangeExample
      name: @props.example.name
      vals: @refs[i].getDOMNode().checked for i in [0...@props.example.vals.length]
  onDelete: (e) ->
    @props.onDeleteExample @props.example.name

ExampleAdd = RC
  render: ->
    cells = _(@props.length).times (i) =>
      (td {}, (input {ref: i, type: 'checkbox', onKeyUp: @checkboxKeyUp}))
    (tr {onKeyPress: @keyPress, onKeyUp: @keyUp}, [
      (td {}, (input {ref: 'name'}))
      cells
      (td {}, (button {onClick: @add, title: 'Добавить'}, '+'))
    ])
  focus: ->
    @refs[i].getDOMNode().checked = false for i in [0...@props.length]
    @refs['name'].getDOMNode().value = ''
    @refs['name'].getDOMNode().focus()
  keyPress: (e) -> # Enter.  Do not add twice when Enter on Button
    if e.keyCode == 13
      @add()
      e.preventDefault()
  keyUp: (e) -> # Esc
    if e.keyCode == 27 then @props.onCancel()
  checkboxKeyUp: (e) -> # digits
    if 48 <= e.keyCode <= 57
      i = (e.keyCode+1) % 10
      node = @refs[i].getDOMNode()
      node.checked = not node.checked
  add: ->
    @props.onUpsertExample
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
    rows = @props.examples.map (example, i) =>
      (ExampleRow
        onChangeExample: @props.onUpsertExample,
        onDeleteExample: @props.onDeleteExample,
        example: example)
    (div hideIf(not @props.attributes.length), [
      (p {}, [
        'Добавляйте примеры, пока все выводы не будут истинны.'
        (br {})
        (small {}, 'Предпосылка: все заключения от наличия одного набора свойств к наличию другого истинны, если не показано обратное.')
      ])
      (table {}, [
        (thead {}, (ExamplesHeading attributes: @props.attributes))
        (tbody {}, [
          rows
          (ExampleAdd
            ref: 'exampleAdd',
            onUpsertExample: @props.onUpsertExample,
            onCancel: @props.onCancel,
            length: @props.attributes.length)
        ])
      ])
    ])
  focusAddExample: ->
    @refs.exampleAdd.focus()

RulesList = RC
  render: ->
    items = @props.rules.map ([from, to]) ->
      (li {}, if from.length then "если #{from}, то #{to}" else "всегда #{to}")
    (div hideIf(not @props.show), [
      (p {}, [
        'Выводы '
        (br {})
        (small {}, 'из предпосылки, ограниченной примерами')
      ])
      if items.length
        (ul {}, items)
      else
        (p {style: {'font-style': 'italic'}}, [
          'Больше ничего вывести нельзя.'
        ])
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
        onSubmit: @focusAddExample)
      ExamplesTable(
        ref: 'examplesTable'
        onUpsertExample: @onUpsertExample,
        onDeleteExample: @onDeleteExample,
        onCancel: @focusAttributesForm,
        attributes: @state.attributes,
        examples: @state.examples)
      RulesList(
        rules: @state.rules
        show: @state.attributes.length)
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
      unless cur.length is next.length
        @model.examples = []
      @setState @model
      @autoexplore()
  focusAddExample: ->
    @refs['examplesTable'].focusAddExample()
    false
  focusAttributesForm: ->
    @refs['attributesForm'].focus()
  onUpsertExample: (example) ->
    old = _.find @model.examples, (x) -> x.name == example.name
    if old then old.vals = example.vals else @model.examples.push example
    @setState @model
    @autoexplore()
  onDeleteExample: (name) ->
    for x, i in @model.examples
      if x.name is name
        @model.examples.splice i, 1
        @setState @model
        @autoexplore()
        break
  autoexplore: ->
    attrIndices = _.invert _.extend {}, @model.attributes
    @setState rules: fca.autoexplore @model.examples, @model.attributes, (g, m) ->
      g.vals[attrIndices[m]]

R.renderComponent App(), document.body
