R = React
RC = R.createClass
{
  div, ul, li, p, span, small, br,
  table, caption, thead, tbody, tr, th, td,
  form, label, input, button
} = R.DOM

negateAttributes = (attributes) ->
  attributes.concat attributes.map (attr) -> "¬#{attr}"

icon = (className) ->
  (R.DOM.i {className: 'icon ' + className})

AttributesForm = RC
  render: ->
    (form {onSubmit: @props.onSubmit}, [
      (label {}, [R.DOM.b({}, 'Attributes'),' (a|b): ']),
      (input {ref: 'input', onChange: @onChange, style: {width: '70%'}, autoFocus: true, type: 'search'})
      (br {})
      (small {}, 'Premise: all implications between sets of attributes are true unless there is a counterexample.')
    ])
  onChange: (e) ->
    @props.onAttributesChange e.target.value
  focus: ->
    @refs['input'].getDOMNode().focus()

ExamplesHeading = RC
  render: ->
    cells = @props.attributes.map (attr) ->
      (th {}, attr)
    (tr {}, (th {contentEditable: true}, 'Examples'), cells)

ExampleRow = RC
  render: ->
    cells = @props.example.vals.map (val, i) =>
      (td {onClick: @onClick i}, [
        (input {ref: i, onChange: @onChange, type: 'checkbox', checked: val})
      ])
    (tr {}, [
      (td {ref: 'name', onBlur: @onChange, contentEditable: true, spellCheck: false}, @props.example.name)
      cells
      (td {}, (button {onClick: @onDelete, title: 'Remove'}, '−'))
    ])
  onClick: (i) ->
    (e) =>
      if e.target.tagName isnt 'INPUT'
        el = @refs[i].getDOMNode()
        el.checked = not el.checked
        el.focus()
        @onChange()
  onChange: () ->
    @props.onChangeExample {
      name: @refs['name'].getDOMNode().textContent
      vals: @refs[i].getDOMNode().checked for i in [0...@props.example.vals.length]
    }, @props.index
  onDelete: () ->
    @props.onDeleteExample @props.index

ExampleAdd = RC
  render: ->
    cells = _(@props.length).times (i) =>
      (td {onClick: @onClick i}, [
        (input {ref: i, type: 'checkbox', onKeyUp: @checkboxKeyUp})
      ])
    (tr {onKeyPress: @keyPress, onKeyUp: @keyUp}, [
      (td {}, (input {ref: 'name', size: 6}))
      cells
      (td {}, (button {onClick: @add, title: 'Add'}, '+'))
    ])
  onClick: (i) ->
    (e) =>
      if e.target.tagName isnt 'INPUT'
        el = @refs[i].getDOMNode()
        el.checked = not el.checked
        el.focus()
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
        example: example,
        index: i)
    (div hideIf(not @props.attributes.length, {className: 'examples'}), [
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
    curRuleKeys = @props.rules.map (rule) -> JSON.stringify rule
    lostRuleKeys = _.difference _.keys(@model.confirmedRules), curRuleKeys
    attributes = negateAttributes @props.attributes
    attrText = (attrs) ->
      attrs
      .map (attr) -> attributes[attr]
      .join ', '
    describeRule = ([from, to]) ->
      if from.length then "#{attrText from} → #{attrText to}" else "∅ → #{attrText to}"
    items = []
    addRule = (key, rule, className) =>
      ruleNode = (span {className: className + ' rule', onClick: => @toggleConfirmed key, rule}, icon(className), describeRule(rule))
      if not @state.tableView
        items.push (li {}, ruleNode)
      else
        boundary = @props.attributes.length
        cells = _.map _.range(boundary), -> []
        [from, to] = rule
        _.each from, (i) ->
          cells[i % boundary].push (input {type: 'checkbox', checked: i < boundary})
        _.each to, (i) ->
          cells[i % boundary].push (icon if i < boundary then 'true' else 'false')
        items.push (tr {}, [
          cells.map (cell) -> (td {}, cell)
          (td {}, ruleNode)
        ])

    _.each lostRuleKeys, (key) =>
      rule = @model.confirmedRules[key]
      addRule key, rule, 'lost'

    confirmedRuleKeys = []
    _.each @props.rules, (rule, i) =>
      key = curRuleKeys[i]
      confirmed = _.has(@model.confirmedRules, key)
      if confirmed and @state.confirmedBelow
        confirmedRuleKeys.push [key]
      else
        addRule key, rule, if confirmed then 'confirmed' else 'unconfirmed'

    _.each confirmedRuleKeys, (key) =>
      rule = @model.confirmedRules[key]
      addRule key, rule, 'confirmed'

    option = (text, checked, onChange) ->
      (label {className: 'small'}, (input {type: 'checkbox', checked: checked, onChange: onChange}), text)

    (div hideIf(not @props.attributes.length, {className: 'implications'}), [
      (form {}, [
        (label {}, [R.DOM.b({}, 'Implications')])
        option 'as table', @state.tableView, (e) => @setState(tableView: e.target.checked)
        option 'accepted last', @state.confirmedBelow, (e) => @setState(confirmedBelow: e.target.checked)
        option 'negate', @props.autoNegate.get(), @props.autoNegate.set
      ])
      if items.length
        if @state.tableView
          (table {className: 'rules'}, [
            (thead {}, (tr {}, [
              (@props.attributes.map (attr) -> (th {}, attr))
              (th {})
            ]))
            (tbody {}, items)
          ])
        else
          (ul {className: 'rules'}, items)
      else
        (p {}, R.DOM.i {}, [
          'No more nontrivial implications.'
        ])
    ])
  getInitialModel: ->
    @model =
      confirmedRules: {}
  getInitialState: ->
    _.extend {
      tableView: false
      confirmedBelow: false
    }, @getInitialModel()
  reset: ->
    @setState @getInitialModel()
  toggleConfirmed: (key, rule) ->
    if _.has @model.confirmedRules, key
      delete @model.confirmedRules[key]
    else
      @model.confirmedRules[key] = rule
    @setState @model

manualRelation = () ->
  cache = {}
  (g1, m1) ->
    cache[g1] = cache[g1] or {}
    rel = cache[g1][m1]
    if rel? then rel else cache[g1][m1] = confirm "#{g1} — #{m1}?"

App = RC
  render: ->
    div {},
      AttributesForm
        ref: 'attributesForm'
        onAttributesChange: @attributesChanged,
        onSubmit: @focusAddExample
      ExamplesTable
        ref: 'examplesTable'
        onUpsertExample: @onUpsertExample,
        onDeleteExample: @onDeleteExample,
        onCancel: @focusAttributesForm,
        attributes: @state.attributes,
        examples: @state.examples
      RulesList
        ref: 'rulesList'
        attributes: @state.attributes
        rules: @state.rules
        autoNegate:
          get: => @state.autoNegate
          set: (e) =>
            @model.autoNegate = e.target.checked
            @setState @model
            @autoexplore()
  getInitialState: ->
    @model =
      attributes: []
      examples: []
      autoNegate: false
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
        @refs['rulesList'].reset()
      @setState @model
      @autoexplore()
  focusAddExample: ->
    @refs['examplesTable'].focusAddExample()
    false
  focusAttributesForm: ->
    @refs['attributesForm'].focus()
  onUpsertExample: (example, index) ->
    if index?
      _.extend @model.examples[index], example
    else
      @model.examples.push example
    @setState @model
    @autoexplore()
  onDeleteExample: (index) ->
    @model.examples.splice index, 1
    @setState @model
    @autoexplore()
  autoexplore: ->
    if @model.autoNegate
      attributes = negateAttributes @model.attributes
      boundary = @model.attributes.length
      rules = fca.autoexplore @model.examples, _.range(attributes.length), (g, m) ->
        (g.vals[m % boundary]) ^ (m >= boundary)
      rules = _.filter rules, ([from, to]) ->
        not _.intersection(from, _.map(from, (i) -> i-boundary)).length
    else
      rules = fca.autoexplore @model.examples, _.range(@model.attributes.length), (g, m) -> g.vals[m]
    @setState rules: rules

R.renderComponent App(), document.body
