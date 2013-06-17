argsOf = require('../util').argsOf 
Defer  = require('when').defer

module.exports = (Preparator, decoratedFn) -> 

    if typeof Preparator != 'object' or Preparator instanceof Array

        throw new Error 'also.inject.async(Preparator, decoratedFn) requires Preparator as object'


    do (

        context    = -> 
        beforeAll  = Defer()

    ) -> 

        context.signature  = argsOf decoratedFn
        context.first      = []
        context.last       = []

        if Preparator.beforeAll? and typeof Preparator.beforeAll is 'function'

            Preparator.beforeAll( 

                #
                # arg1 to beforeAll() resolves or rejects according to
                # whether the result is an error 
                #

                (result) ->

                    return beforeAll.reject result if result instanceof Error
                    return beforeAll.resolve result

                #
                # arg2 is context
                #

                context

            )


        else 

            #
            # resolve directly - no beforeAll() defined
            #

            beforeAll.resolve()

        return ->  

            context.inject = []

            Preparator.beforeEach context if Preparator.beforeEach? 

            context.inject.push arg for arg in arguments

            beforeAll.promise.then(

                resolved = ->

                    result = decoratedFn.apply null, context.first.concat( context.inject ).concat context.last
                    Preparator.afterEach context, result if Preparator.afterEach?
                    return result

                rejected = (error) -> 

                    Preparator.error error if Preparator.error instanceof Function

            )

