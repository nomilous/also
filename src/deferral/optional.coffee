{defer}  = require 'when'
{argsOf} = require '../util'

module.exports = (opts, fn) -> 

    #
    # opts
    # ----
    # 
    # * resolver - specify argument signature name to inject resolver into
    # * fn       - function to inject resolver into
    # 
    #
    
    opts ||= {}
    fn   ||= opts

    throw new Error 'expected function as last arg' unless typeof fn == 'function' 

    -> 

        deferral = defer()

        if opts.resolver?

            resolverPosition = argsOf(fn).indexOf opts.resolver

            if resolverPosition >= 0

                newArgs  = []
                newArgs.push arg for arg in arguments

                deferral.resolve.notify     = deferral.notify
                deferral.resolve.reject     = deferral.reject
                newArgs[ resolverPosition ] = deferral.resolve

                fn.apply this, newArgs

            else

                fn.apply this, arguments
                deferral.resolve()
                
            return deferral.promise


        fn.apply this, arguments
        deferral.resolve()
        deferral.promise
        
