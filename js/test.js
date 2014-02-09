// Generated by IcedCoffeeScript 1.7.1-a
(function() {
  var g, m, relation;

  relation = function(g1, m1) {
    return {
      even: function(x) {
        return x % 2 === 0;
      },
      odd: function(x) {
        return x % 2 === 1;
      },
      prime: function(x) {
        var i, _i, _ref;
        switch (false) {
          case !(x < 2):
            return false;
          case !(x < 4):
            return true;
          case x % 2 !== 0:
            return false;
          case !(x < 9):
            return true;
          default:
            for (i = _i = 5, _ref = Math.floor(Math.sqrt(x)); _i <= _ref; i = _i += 6) {
              if (x % i === 0 || x % (i + 2) === 0) {
                return false;
              }
            }
            return true;
        }
      }
    }[m1](g1);
  };

  g = [1, 2, 3, 4, 5];

  m = ["even", "odd", "prime"];

  test("phi-psi-mapping", function() {
    console.log(fca.phiMapping([2], m, relation));
    deepEqual(fca.phiMapping([2], m, relation), ["even", "prime"]);
    deepEqual(fca.psiMapping(["odd", "prime"], g, relation), [3, 5]);
    deepEqual(fca.gClosure([1], g, m, relation), [1, 3, 5]);
    return deepEqual(fca.mClosure(["even", "odd"], m, g, relation), ["even", "odd", "prime"]);
  });

  test("rule-based-closure", function() {
    deepEqual(fca.ruleBasedClosure([])([1]), [1]);
    return deepEqual(fca.ruleBasedClosure([[[1], [2]]])([1]), [1, 2]);
  });

  test("next-closure", function() {
    var a;
    a = fca.nextClosure([], m, function(b) {
      return fca.mClosure(b, m, g, relation);
    });
    deepEqual(a, ["even"]);
    a = fca.nextClosure(m, m, function(b) {
      return fca.mClosure(b, m, g, relation);
    });
    return equal(a, null);
  });

}).call(this);
