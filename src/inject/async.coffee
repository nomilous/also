argsOf   = require('../util').argsOf 
Defer    = require('when').defer
sequence = require 'when/sequence'

module.exports = (Preparator, decoratedFn) -> 

    if typeof Preparator != 'object' or Preparator instanceof Array

        throw new Error 'also.inject.async(Preparator, decoratedFn) requires Preparator as object'

    do (

        context = -> 
        beforeAllDone =false

    ) -> 

        context.signature  = argsOf decoratedFn
        context.first      = []
        context.last       = []

        beforeAll = -> 

            #
            # TODO: done once part can be factored out as also.once(fn) decorator
            # 

            defer = Defer()
            return defer.resolve() if beforeAllDone
            return defer.resolve() unless (

                Preparator.beforeAll? and 
                typeof Preparator.beforeAll is 'function'

            )

            beforeAllDone = true

            #
            # call the defined beforeAll()
            # 
            # * arg1 as resolver/rejector (depending on result)
            # * arg2 as context
            # 

            done = (result) ->
  
                return defer.reject result if result instanceof Error
                return defer.resolve result

            Preparator.beforeAll done, context
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

            inject = []
            inject.push arg for arg in arguments

            finished = Defer()

            beforeEach = -> 

                defer = Defer()
                return defer.resolve() unless (

                    Preparator.beforeEach? and 
                    typeof Preparator.beforeEach is 'function'

                )

                done = (result) ->

                    finished.notify beforeEach: result
                    return defer.reject result if result instanceof Error
                    return defer.resolve result

                Preparator.beforeEach done, context
                return defer.promise


            callDecoratedFn = -> 
            
                defer = Defer()

                decoratedFn.apply null, [ (result) ->

                    finished.notify result: result
                    return defer.reject result if result instanceof Error
                    return defer.resolve result

                ].concat context.first.concat( inject ).concat context.last
                return defer.promise


            afterEach = -> 

                defer = Defer()
                return defer.resolve() unless (

                    Preparator.afterEach? and 
                    typeof Preparator.afterEach is 'function'

                )

                done = (result) ->

                    finished.notify afterEach: result
                    return defer.reject result if result instanceof Error
                    return defer.resolve result

                Preparator.afterEach done, context
                return defer.promise

            sequence([

                beforeAll
                beforeEach
                callDecoratedFn
                afterEach

            ]).then(

                (results) -> 

                    # [0] beforeAll result
                    # [1] beforeEach result
                    finished.resolve results[2]
                    # [3] afterEach result

                (error) -> 

                    Preparator.error error if Preparator.error instanceof Function
                    done.reject error

                finished.notify

            )

            finished.promise


        


