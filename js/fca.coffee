# depends on underscore

# Formal context (objects G, attributes M, relation L)
# is modeled as (list, list, list of pairs).
# I is a lambda implementing L.

module = @fca = {

phiMapping: (g, m, i) ->
  "All M1 from full set M that satisfy I for all G1"
  # complexity: |G|*|M|
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
  # complexity: |G|*|M|
  @phiMapping (@psiMapping b, g, i), m, i

nextClosure: (a, m, l) ->
  "Next closed set of closure L on A ⊆ M."
  # complexity: |M|^2 (reducible to |M|log|M|)
  mr = m
  a = _.clone(a)
  for m1, i in m
    mr = _.rest mr
    j = a.indexOf m1
    if j > -1
      # remove m1 from a
      a.splice j, 1
    else
      b = l a.concat [m1]
      # if mr ∩ (B \ A) = ∅ return B
      if (_.intersection(mr, _.difference(b, a))).length is 0
        return b
  return null

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

autoexplore: (e, m, i) ->
  "Derive implications L from a complete set of examples E"
  l = []
  a = []
  while a
    ajj = @mClosure a, m, e, i
    unless _.isEqual(_.object(a, a), _.object(ajj, ajj))
      l.push [a, _.difference(ajj, a)]
    a = @nextClosure a, m, @ruleBasedClosure l
  l

}
