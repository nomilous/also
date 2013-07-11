argsOf   = require('../util').argsOf 
Defer    = require('when').defer
sequence = require 'when/sequence'

module.exports = (Preparator, decoratedFn) -> 

    seq = 0
    _id = seq

    if typeof Preparator != 'object' or Preparator instanceof Array

        throw new Error 'also.inject.async(Preparator, decoratedFn) requires Preparator as object'

    do (

        context = -> 
        beforeAllDone = false

    ) -> 

        context.signature  = argsOf decoratedFn
        queue              = []

        debug = -> 
            console.log 'queue length:', ( ->

                #
                # possible usage as afterAll hook??
                #

                length = 0
                for it in queue
                    length++ unless it.done
                length
            )() 

        beforeAll = -> 

            #
            # TODO: done once part can be factored out as also.once(fn) decorator
            # 

            debug()

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


        Object.defineProperty context, 'args',      
            enumerable: true
            get: -> 
                queue[_id].args

        Object.defineProperty context, 'defer', 
            enumerable: true
            get: -> 
                #
                # getting the defer property activates 
                # alternate deferral injectinon, 
                # 
                # done fn will no longer be injected as 
                # arg1 into the decoratedFn
                #
                queue[_id].altDefer = true
                queue[_id].defer

         Object.defineProperty context, 'first', 
            enumerable: true
            get: -> 
                queue[_id].first

        Object.defineProperty context, 'last', 
            enumerable: true
            get: -> 
                queue[_id].last


        return ->  

            #
            # insert external arguments into the pending injection array
            # 
            # * these will be prepended with whatever is placed into
            #   context.first (array) by the beforeAll/Each
            # 
            # * also append to, from context.last (array)
            # 

            id   = seq++
            args = []
            args.push arg for arg in arguments

            queue[id] = 
                done:      false
                defer:     Defer()
                altDefer:  false
                first:     []
                last:      []
                args:      args

            finished  = Defer()

            beforeEach = -> 

                defer = Defer()
                return defer.resolve() unless (

                    Preparator.beforeEach? and 
                    typeof Preparator.beforeEach is 'function'   

                )

                done = (result) ->
                    _id = id
                    finished.notify beforeEach: result
                    return defer.reject result if result instanceof Error
                    return defer.resolve result

                _id = id
                Preparator.beforeEach done, context
                return defer.promise


            callDecoratedFn = -> 

                _id = id
                if queue[id].altDefer

                    decoratedFn.apply null, queue[id].first.concat( args ).concat queue[id].last

                else

                    decoratedFn.apply null, [ (result) ->

                        finished.notify result: result
                        return queue[id].defer.reject result if result instanceof Error
                        return queue[id].defer.resolve result

                    ].concat queue[id].first.concat( args ).concat queue[id].last

                return queue[id].defer.promise


            afterEach = -> 

                defer = Defer()
                return defer.resolve() unless (

                    Preparator.afterEach? and 
                    typeof Preparator.afterEach is 'function'

                )

                done = (result) ->
                    _id = id
                    queue[id].done = true
                    finished.notify afterEach: result
                    debug()
                    return defer.reject result if result instanceof Error
                    return defer.resolve result

                _id = id
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

            return finished.promise


