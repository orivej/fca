# depends on underscore, backbone, iced-runtime

# Formal context (objects G, attributes M, relation L)
# is modeled as (list, list, list of conses).
# I is a lambda implementing L.

module = @fca = _.extend {}, Backbone.Events, {

phiMapping: (g, m, i) ->
  "All M1 from full set M that satisfy I for all G1"
  _.filter m, (m1) ->
    _.every g, (g1) ->
      i(g1, m1)

psiMapping: (m, g, i) ->
  "All G1 from full set G that satisfy I for all M1"
  @phiMapping m, g, (m1, g1) -> i(g1, m1)

gClosure: (a, g, m, i) ->
  "Closure from A ⊆ G onto G"
  @psiMapping (@phiMapping a, m, i), g, i

mClosure: (b, m, g, i) ->
  "Closure from B ⊆ M onto M"
  @phiMapping (@psiMapping b, g, i), m, i

nextClosure$: (a, m, l) ->
  "Next closed set of closure L on A ⊆ M. Mutates A."
  mr = m
  for m1, i in m
    mr = _.rest mr
    j = a.indexOf m1
    if j > -1
      # remove m1 from a
      a.splice j, 1
    else
      aCopy = a.slice()
      aCopy.push m1
      b = l aCopy
      # if mr ∩ (B \ A) = ∅ return B
      if (_.intersection(mr, _.difference(b, a))).length is 0
        return b
  return null

confirmationMessage: (from, to) ->
  if from.length
    "If something is #{from}, is it #{to}?"
  else
    "Is everything #{to}?"

ruleBasedClosure: (rules) ->
  (b) ->
    changed = true
    while changed
      changed = false
      for [p, q] in rules
        if _.difference(p, b).length is 0 and _.difference(q, b).length isnt 0
          b = _.union(b, q)
          changed = true
    return b

cps: (fun) ->
  (args..., cb) ->
    cb fun args...

explore: (e, m, i, options) ->
  "E ⊆ M; I is E → M
Initially E is NIL.
Change E.
Return values: implications L, (E, M, I)"
  mod = @
  _.extend options,
    confirm: module.cps _.bind(confirm, window)
    prompt: module.cps _.bind(prompt, window)
    parse: (x) -> x
  l = []
  a = []
  while a
    while true
      ajj = @mClosure a, m, e, i
      if _.isEqual(_.object(a, a), _.object(ajj, ajj))
        break
      ajj = _.difference ajj, a
      await options.confirm @confirmationMessage(a, ajj), defer confirmed
      if confirmed
        l.push [a, ajj]
        module.trigger 'add-rule', a, ajj
        break
      else
        await options.prompt "Counterexample:", defer e1
        e1 = options.parse e1
        e.push e1
        module.trigger 'add-example', e1
    a = @nextClosure$ a, m, @ruleBasedClosure l
  l # [e, m, i]

}
