argsOf = require('../util').argsOf 
Defer  = require('when').defer

module.exports = (Preparator, decoratedFn) -> 

    if typeof Preparator != 'object' or Preparator instanceof Array

        throw new Error 'also.inject.async(Preparator, decoratedFn) requires Preparator as object'


    do (

        context    = -> 
        configured = false

    ) -> 

        context.signature  = argsOf decoratedFn
        context.first      = []
        context.last       = []

        beforeAll = Defer()

        if Preparator.beforeAll?

            Preparator.beforeAll beforeAll.resolve

        return ->  

            context.inject = []

            Preparator.beforeEach context if Preparator.beforeEach? 

            context.inject.push arg for arg in arguments

            beforeAll.promise.then(

                success = ->


                    result = decoratedFn.apply null, context.first.concat( context.inject ).concat context.last
                    Preparator.afterEach context, result if Preparator.afterEach?
                    return result

            )

