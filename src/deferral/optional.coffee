{defer}  = require 'when'
{argsOf} = require '../util'

module.exports = (Preparator, decoratedFn) -> 

    #
    # Preparator
    # ----------
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
    
    Preparator   ||= {}
    decoratedFn  ||= Preparator

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

                resolver = deferral.resolve
                resolver.resolve    = resolver
                resolver.reject     = deferral.reject
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
        
