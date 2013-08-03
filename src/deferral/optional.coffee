{defer}  = require 'when'
{argsOf} = require '../util'

module.exports = (opts, decoratedFn) -> 

    #
    # opts
    # ----
    # 
    # * resolver - specify argument signature name to inject resolver into
    # 
    # decoratedFn
    # -----------
    # 
    # A function to surround in an optional deferral and inject 
    # resolvability into
    #
    
    opts        ||= {}
    decoratedFn ||= opts

    throw new Error 'expected function as last arg' unless typeof decoratedFn == 'function' 

    -> 

        deferral = defer()

        if opts.resolver?

            argPosition = argsOf( decoratedFn ).indexOf opts.resolver

            if argPosition >= 0

                #
                # for continuity, the full promise interface 
                # is available on the resolver
                #

                resolver = deferral.resolve
                resolver.resolve    = resolver
                resolver.reject     = deferral.reject
                resolver.notify     = deferral.notify

                newArgs  = []
                newArgs.push arg for arg in arguments
                newArgs[ argPosition ] = resolver
                decoratedFn.apply this, newArgs

            else

                decoratedFn.apply this, arguments
                deferral.resolve()
                
            return deferral.promise


        decoratedFn.apply this, arguments
        deferral.resolve()
        deferral.promise
        
