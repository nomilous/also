argsOf = require('../util').argsOf 

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


        if Preparator.beforeAll?

            Preparator.beforeAll context 

        return ->  

            context.inject = []

            Preparator.beforeEach context if Preparator.beforeEach? 

            context.inject.push arg for arg in arguments

            result = decoratedFn.apply null, context.first.concat( context.inject ).concat context.last

            Preparator.afterEach context, result if Preparator.afterEach?

            return result
