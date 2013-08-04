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

                unless Preparator.timeout == 0 

                    timeout = setTimeout (-> 

                        #
                        #
                        #
                        #
                        #
                        #    How to terminate the possibly still inprogress 'flow of execution'
                        #    that is taking more time than this assigned timeout has allowed ?
                        #    ------------------------------------------------------------------
                        # 
                        #
                        #    Because often, when something timed out, it seems logical to try 
                        #    again. Doing so leads to there now being two in progress, the first 
                        #    of which has only "apparently" timed out.
                        #             
                        #    The problem 'of the first calling back after the timeout', is solved
                        #    by a compliant promises implementation... 
                        # 
                        #    But only for as long as the promise remains THE ONLY interface 
                        #    between the 'asynchronized' process and the calling system. 
                        # 
                        #    With javascript, one can be easily tempted to use the closure's
                        #    accessable superscope from within the 'asynchronized' process to 
                        #    modify state in the caller before ever the promise is resolved.
                        # 
                        # 
                        #
                        #
                        #

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

                #
                # for continuity, the full promise interface 
                # is available on the resolver
                #

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
        
