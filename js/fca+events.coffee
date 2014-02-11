module = @fca

_.extend module, Backbone.Events, {

explore: (e, m, i, options={}) ->
  "E ⊆ M; I is E → M
Initially E is NIL.
Change E.
Return values: implications L, examples E"
  _.defaults options,
    confirm: _.bind(confirm, window)
    prompt: _.bind(prompt, window)
    parse: (x) -> x
    confirmationMessage: (from, to) ->
      if from.length then "If something is #{from}, is it #{to}?" else "Is everything #{to}?"
    counterexampleMessage: 'Counterexample:'
  l = []
  a = []
  while a
    while true
      ajj = @mClosure a, m, e, i
      if _.isEqual(_.object(a, a), _.object(ajj, ajj))
        break
      ajj = _.difference ajj, a
      if options.confirm options.confirmationMessage(a, ajj)
        l.push [a, ajj]
        module.trigger 'add-rule', a, ajj
        break
      else
        e1 = options.prompt options.counterexampleMessage
        unless e1
          module.trigger 'abort'
          return
        e1 = options.parse e1
        e.push e1
        module.trigger 'add-example', e1
    a = @nextClosure a, m, @ruleBasedClosure l
  [l, e]

}
