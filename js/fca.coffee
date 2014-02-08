# depends on underscore

# Formal context (objects G, attributes M, relation L)
# is modeled as (list, list, list of conses).
# I is a lambda implementing L.

@fca = {

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
  return false

userConfirm: (from, to) ->
  if from.length
    confirm "If something is #{from}, is it #{_.difference to, from}?"
  else
    confirm "Is everything #{to}?"

userExtend$: (e, parse) ->
  e.push parse prompt "Counterexample:"

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

explore: (e, m, i, options) ->
  "E ⊆ M; I is E → M
Initially E is NIL.
Change E.
Return values: implications L, (E, M, I)"
  mod = @
  _.extend options,
    confirm: mod.userConfirm
    parse: (x) -> x
    extend$: mod.userExtend$
  l = []
  a = []
  while a
    while true
      ajj = @mClosure a, m, e, i
      if _.isEqual(_.object(a, a), _.object(ajj, ajj))
        break
      if options.confirm a, ajj
        l.push [a, ajj]
        break
      else
        options.extend$ e, options.parse
    a = @nextClosure$ a, m, @ruleBasedClosure l
  l # [e, m, i]

}
