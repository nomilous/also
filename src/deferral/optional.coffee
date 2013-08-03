{defer}  = require 'when'
{argsOf} = require '../util'

module.exports = (opts, decoratedFn) -> 

    #
    # opts
    # ----
    # 
    # * resolver - specify argument signature name to inject resolver into
    # * context  - the object context to call the decoratedFn on
    # 
    # decoratedFn
    # -----------
    # 
    # A function to surround in an optional deferral and inject 
    # resolvability into
    #
    
    opts         ||= {}
    decoratedFn  ||= opts

    throw new Error 'expected function as last arg' unless typeof decoratedFn == 'function' 

    -> 

        deferral = defer()
        opts.context = if typeof opts.context == 'undefined' then this else opts.context


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
                decoratedFn.apply opts.context, newArgs

            else

                decoratedFn.apply opts.context, arguments
                deferral.resolve()
                
            return deferral.promise


        decoratedFn.apply opts.context, arguments
        deferral.resolve()
        deferral.promise
        
