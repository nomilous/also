{defer} = require 'when'

module.exports = (args...) -> 
    
    opts = args[0]
    fn   = args[-1..][0]

    throw new Error 'expected function as last arg' unless typeof fn == 'function' 

    -> 

        defers = opts.if() if typeof opts.if == 'function'
        
        if defers 

            deferral = defer()
            newArgs = [deferral.resolve]
            newArgs.push arg for arg in arguments
            fn.apply this, newArgs
            return deferral.promise

        fn.apply this, arguments
        
