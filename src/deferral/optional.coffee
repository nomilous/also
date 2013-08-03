{defer} = require 'when'

module.exports = (args...) -> 
    
    opts = args[0]
    fn   = args[-1..][0]

    throw new Error 'expected function as last arg' unless typeof fn == 'function' 

    -> 

        defers = opts.if() if typeof opts.if == 'function'
        
        if defers 

            deferral = defer()
            fn deferral.resolve
            return deferral.promise

        fn()
        
