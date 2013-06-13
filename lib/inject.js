// Generated by CoffeeScript 1.4.0
var argsOf;

argsOf = require('./util').argsOf;

exports.sync = function(Preparator, decoratedFn) {
  return (function(context, configured) {
    try {
      context.preparator.beforeAll();
    } catch (_error) {}
    return function() {
      var arg, injected, _i, _len;
      injected = typeof Preparator === 'function' ? Preparator(argsOf(decoratedFn)) : Preparator instanceof Array ? Preparator : Preparator instanceof Object ? (configured = true, []) : [Preparator];
      if (!configured) {
        for (_i = 0, _len = arguments.length; _i < _len; _i++) {
          arg = arguments[_i];
          injected.push(arg);
        }
        return decoratedFn.apply(null, injected);
      }
      try {
        context.preparator.beforeEach();
      } catch (_error) {}
      return decoratedFn.apply(null, null);
    };
  })({
    preparator: Preparator
  }, false);
};

exports.async = function(signatureFn, fn) {
  return function() {
    var arg, context, original;
    context = void 0;
    original = (function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = arguments.length; _i < _len; _i++) {
        arg = arguments[_i];
        _results.push(arg);
      }
      return _results;
    }).apply(this, arguments);
    if (typeof signatureFn === 'function') {
      signatureFn(argsOf(fn).slice(1), function(error, result) {
        return fn.apply(null, [error].concat(result).concat(original));
      });
    } else if (signatureFn instanceof Array) {
      fn.apply(null, signatureFn.concat(original));
    } else if (signatureFn instanceof Object) {
      context = {
        config: signatureFn
      };
    } else {
      fn.apply(null, [signatureFn].concat(original));
    }
    if (context == null) {
      return;
    }
    return fn.apply(null, null);
  };
};