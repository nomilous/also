argsOf   = require('../util').argsOf 
Defer    = require('when').defer
sequence = require 'when/sequence'

module.exports = (Preparator, decoratedFn) -> 

    if typeof Preparator != 'object' or Preparator instanceof Array

        throw new Error 'also.inject.async(Preparator, decoratedFn) requires Preparator as object'


    do (

        context = -> 
        done    = {
            beforeAll:  false
        }

    ) -> 

        context.signature  = argsOf decoratedFn
        context.first      = []
        context.last       = []

        beforeAll = -> 

            #
            # TODO: can be factored out as also.once(fn) decorator
            # 

            defer = Defer()
            return defer.resolve() if done.beforeAll
            unless Preparator.beforeAll? and typeof Preparator.beforeAll is 'function'

                #
                # resolve directly - no beforeAll() defined
                #

                done.beforeAll = true
                return defer.resolve()

            #
            # call the defined beforeAll()
            # 
            # * arg1 as resolver/rejector (depending on result)
            # * arg2 as context
            # 

            Preparator.beforeAll( 

                (result) ->

                    done.beforeAll = true
                    return defer.reject result if result instanceof Error
                    return defer.resolve result

                context

            )

            return defer.promise


        return ->  

            #
            # insert external arguments into the pending injection array
            # 
            # * these will be prepended with whatever is placed into
            #   context.first (array) by the beforeAll/Each
            # 
            # * also append to, from context.last (array)
            # 

            context.inject = []
            context.inject.push arg for arg in arguments

            beforeEach = -> 

                defer = Defer()
                unless Preparator.beforeEach? and typeof Preparator.beforeEach is 'function'

                    return defer.resolve()

                Preparator.beforeEach( 

                    (result) ->

                        return defer.reject result if result instanceof Error
                        return defer.resolve result

                    context

                )

                return defer.promise


            sequence([

                beforeAll
                beforeEach

            ]).then(

                resolved = -> 

                    decoratedFn.apply null, context.first.concat( context.inject ).concat context.last
                    Preparator.afterEach context, result if Preparator.afterEach?

                rejected = (error) -> 

                    Preparator.error error if Preparator.error instanceof Function

            )


