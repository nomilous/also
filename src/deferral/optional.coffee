{defer}  = require 'when'
{argsOf} = require '../util'

module.exports = (Preparator, decoratedFn) -> 

    #
    # Preparator
    # ----------
    # 
    # * resolver - specify argument signature name to inject resolver into
    # * context  - the object context to call the decoratedFn on
    # * timeout  - if set, the deferral is rejected if not resolved in time
    # 
    # decoratedFn
    # -----------
    # 
    # A function to surround in an optional deferral and inject 
    # resolvability into
    #
    
    Preparator         ||= {}
    Preparator.timeout ||= 0
    decoratedFn        ||= Preparator

    throw new Error 'expected function as last arg' unless typeof decoratedFn == 'function'
    if Preparator.resolver? then argPosition = argsOf( decoratedFn ).indexOf Preparator.resolver

    -> 

        deferral = defer()
        Preparator.context = if typeof Preparator.context == 'undefined' then this else Preparator.context

        if Preparator.resolver?

            if argPosition >= 0

                #
                # for continuity, the full promise interface 
                # is available on the resolver
                #

                unless Preparator.timeout == 0 

                    timeout = setTimeout (->

                        deferral.notify event: 'timeout'
                        return deferral.resolve() if Preparator.resolveOnTimeout
                        deferral.reject new Error 'timeout'

                    ), Preparator.timeout

                resolver = (result) -> 

                    clearTimeout timeout if timeout?
                    deferral.resolve result

                reject = (error) -> 

                    clearTimeout timeout if timeout?
                    deferral.reject error

                resolver.resolve    = resolver
                resolver.reject     = reject
                resolver.notify     = deferral.notify

                newArgs  = []
                newArgs.push arg for arg in arguments
                newArgs[ argPosition ] = resolver
                decoratedFn.apply Preparator.context, newArgs

            else

                decoratedFn.apply Preparator.context, arguments
                deferral.resolve()
                
            return deferral.promise


        decoratedFn.apply Preparator.context, arguments
        deferral.resolve()
        deferral.promise
        
