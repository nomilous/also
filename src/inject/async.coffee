argsOf   = require('../util').argsOf 
Defer    = require('when').defer
sequence = require 'when/sequence'

module.exports = (Preparator, decoratedFn) -> 
    
    seq  = 0
    _id  = seq

    if typeof Preparator == 'function' and typeof decoratedFn == 'undefined'

        decoratedFn = Preparator
        Preparator = {} 

    if typeof Preparator != 'object' or Preparator instanceof Array

        throw new Error 'also.inject.async(Preparator, decoratedFn) requires Preparator as object'

    Preparator.parallel      = true  unless Preparator.parallel?
    Preparator.context       = this  unless Preparator.context?
    Preparator.onError

    do (

        context = -> 
        beforeAllDone = false 

    ) -> 

        context.signature  = argsOf decoratedFn
        queue              = []   
        calls              = []
        running            = false

        queueRemainingLength = -> 
            length = 0
            if Preparator.parallel
                for item in queue
                    length++ unless item.done
            else
                for call in calls
                    length++
            length


        errorHandler = (defer, error) -> 

            return defer.reject error unless typeof Preparator.onError is 'function'

            #
            # onError handler can be defined to avoid rejection on error
            # 
            # * this allows an async error handler to suspend flow of 
            #   control while the error is being handled
            # 
            # * it is up to the handler to resolve/reject the deferral
            #

            done = (result) -> 


                return defer.reject result if result instanceof Error
                return defer.resolve result

            Preparator.onError done, context, error


        beforeAll = -> 

            defer = Defer()
            return defer.resolve() if beforeAllDone
            return defer.resolve() unless typeof Preparator.beforeAll is 'function'
            beforeAllDone = true

            #
            # call the defined beforeAll()
            # 
            # * arg1 as resolver/rejector (depending on result)
            # * arg2 as context
            # 

            done = (result) ->

                if result instanceof Error

                    return errorHandler defer, result

                return defer.resolve result

            Preparator.beforeAll done, context
            return defer.promise




        Object.defineProperty context, 'args',      
            enumerable: true
            get: -> 
                try queue[_id].args

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
                try queue[_id].defer

         Object.defineProperty context, 'first', 
            enumerable: true
            get: -> 
                try queue[_id].first

        Object.defineProperty context, 'last', 
            enumerable: true
            get: -> 
                try queue[_id].last


        Object.defineProperty context, 'queue', 
            enumerable: true
            get: -> 
                remaining: queueRemainingLength()
                elements: queue
                current: _id

        Object.defineProperty context, 'current',
            enumerable: true
            get: -> queue[_id]


        Object.defineProperty context, 'skip',
            enumerable: true
            get: -> -> queue[_id].skip = true


        return ->

            finished = Defer()

            fn = (finished, args) ->

                id   = seq++
                inject = []
                inject.push arg for arg in args

                resolver = (result) ->

                    _id = id
                    return queue[id].defer.reject result if result instanceof Error
                    finished.notify result: result
                    return queue[id].defer.resolve result

                queue[id] = 
                    done:      false
                    defer:     Defer()
                    altDefer:  false
                    first:     []
                    last:      []
                    args:      inject
              

                beforeEach = -> 

                    defer = Defer()
                    return defer.resolve() unless typeof Preparator.beforeEach is 'function'

                    done = (result) ->

                        finished.notify beforeEach: result

                        if result instanceof Error

                            return errorHandler defer, result
                            
                        return defer.resolve result

                    _id = id
                    Preparator.beforeEach done, context
                    return defer.promise


                callDecoratedFn = -> 

                    _id = id
                    element = queue[id]
                    return element.defer.resolve() if element.skip

                    process.nextTick -> 

                        try 

                            if element.altDefer

                                decoratedFn.apply Preparator.context, element.first.concat( inject ).concat element.last

                            else 

                                decoratedFn.apply Preparator.context, [ resolver ].concat element.first.concat( inject ).concat element.last

                        catch error

                            errorHandler element.defer, error


                    return element.defer.promise


                afterEach = -> 

                    _id   = id
                    defer = Defer()
                    return defer.resolve() unless typeof Preparator.afterEach is 'function'

                    done = (result) ->

                        finished.notify afterEach: result

                        if result instanceof Error

                             return errorHandler defer, result

                        return defer.resolve result

                    
                    Preparator.afterEach done, context
                    return defer.promise


                afterAll = -> 

                    _id   = id
                    defer = Defer()
                    queue[id].done = true

                    return defer.resolve() unless queueRemainingLength() == 0
                    unless typeof Preparator.afterAll is 'function'

                        #
                        # reset queue
                        #

                        queue.length = 0
                        return defer.resolve() 


                    done = (result) ->
                        _id = -1
                        queue.length = 0

                        if result instanceof Error

                            return errorHandler defer, result

                        return defer.resolve result
                    
                    _id = -1
                    Preparator.afterAll done, context
                    return defer.promise

                sequence([

                    beforeAll
                    beforeEach
                    callDecoratedFn
                    afterEach
                    afterAll

                ]).then(

                    (results) -> 

                        # [0] beforeAll result
                        # [1] beforeEach result
                        finished.resolve results[2]
                        # [3] afterEach result

                    (error)  -> finished.reject error
                    (status) -> finished.notify status

                )

                return finished.promise



            unless Preparator.parallel

                #
                # calls to decoratedFn should run in sequence
                # (each pended until the previous completes)
                # 

                calls.push 

                    function:  fn
                    finished:  finished
                    arguments: arguments

                run = -> 

                    running = true
                    call = calls.shift() 

                    unless call? 

                        running = false
                        return

                    call.function( call.finished, call.arguments ).then(

                        #
                        # recurse on promise resolved 
                        #

                        -> run()
                        -> run()
                    )

                run() unless running

                return finished.promise


            #
            # calls to decoratedFn run in parallel
            #

            return fn finished, arguments if Preparator.parallel

            
