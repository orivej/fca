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

fca.on 'add-rule', (from, to) ->
  document.write "New rule: #{from} → #{to}\n"

fca.on 'add-example', (e1) ->
  document.write "New example: #{e1}\n"

fca.explore [], m, relation,
  parse: parseInt
