relation = (g1, m1) ->
  {
    even:
      (x) -> x % 2 == 0
    odd:
      (x) -> x % 2 == 1
    prime:
      (x) ->
        switch
          when x < 2 then false
          when x < 4 then true
          when x % 2 == 0 then false
          when x < 9 then true
          else
            for i in [5..Math.floor(Math.sqrt(x))] by 6
              if x % i == 0 or x % (i+2) == 0
                return false
            true
  }[m1](g1)

g = [1, 2, 3, 4, 5]
m = ["even", "odd", "prime"]

test "phi-psi-mapping", ->
  console.log fca.phiMapping([2], m, relation)
  deepEqual fca.phiMapping([2],              m, relation), ["even", "prime"]
  deepEqual fca.psiMapping(["odd", "prime"], g, relation), [3, 5]
  deepEqual fca.gClosure([1],             g, m, relation), [1, 3, 5]
  deepEqual fca.mClosure(["even", "odd"], m, g, relation), ["even", "odd", "prime"]

test "rule-based-closure", ->
  deepEqual fca.ruleBasedClosure([])([1]), [1]
  deepEqual fca.ruleBasedClosure([[[1], [2]]])([1]), [1, 2]

test "next-closure", ->
  a = []
  a = fca.nextClosure$ a, m, (b)->fca.mClosure b, m, g, relation
  deepEqual a, ["even"]
  a = m
  a = fca.nextClosure$ a, m, (b)->fca.mClosure b, m, g, relation
  deepEqual a, ["even"]
