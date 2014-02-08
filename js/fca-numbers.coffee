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

m = ["even", "odd", "prime"]

alert fca.explore [], m, relation,
  parse: parseInt
