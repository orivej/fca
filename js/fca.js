// Generated by IcedCoffeeScript 1.7.1-a
(function() {
  var module;

  module = this.fca = {
    phiMapping: function(g, m, i) {
      "All M1 from full set M that satisfy I for all G1";
      return _.filter(m, function(m1) {
        return _.every(g, function(g1) {
          return i(g1, m1);
        });
      });
    },
    psiMapping: function(m, g, i) {
      "All G1 from full set G that satisfy I for all M1";
      return this.phiMapping(m, g, function(m1, g1) {
        return i(g1, m1);
      });
    },
    gClosure: function(a, g, m, i) {
      "Closure from A ⊆ G onto G";
      return this.psiMapping(this.phiMapping(a, m, i), g, i);
    },
    mClosure: function(b, m, g, i) {
      "Closure from B ⊆ M onto M";
      return this.phiMapping(this.psiMapping(b, g, i), m, i);
    },
    nextClosure: function(a, m, l) {
      "Next closed set of closure L on A ⊆ M.";
      var b, i, j, m1, mr, _i, _len;
      mr = m;
      a = _.clone(a);
      for (i = _i = 0, _len = m.length; _i < _len; i = ++_i) {
        m1 = m[i];
        mr = _.rest(mr);
        j = a.indexOf(m1);
        if (j > -1) {
          a.splice(j, 1);
        } else {
          b = l(a.concat([m1]));
          if ((_.intersection(mr, _.difference(b, a))).length === 0) {
            return b;
          }
        }
      }
      return null;
    },
    ruleBasedClosure: function(rules) {
      return function(b) {
        var changed, p, q, _i, _len, _ref;
        changed = true;
        while (changed) {
          changed = false;
          for (_i = 0, _len = rules.length; _i < _len; _i++) {
            _ref = rules[_i], p = _ref[0], q = _ref[1];
            if (_.difference(p, b).length === 0 && _.difference(q, b).length !== 0) {
              b = _.union(b, q);
              changed = true;
            }
          }
        }
        return b;
      };
    },
    autoexplore: function(e, m, i) {
      "Derive implications L from a complete set of examples E";
      var a, ajj, l;
      l = [];
      a = [];
      while (a) {
        ajj = this.mClosure(a, m, e, i);
        if (!_.isEqual(_.object(a, a), _.object(ajj, ajj))) {
          l.push([a, _.difference(ajj, a)]);
        }
        a = this.nextClosure(a, m, this.ruleBasedClosure(l));
      }
      return l;
    }
  };

}).call(this);
