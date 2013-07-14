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

    Preparator.parallel = true unless Preparator.parallel?

    do (

        context = -> 
        beforeAllDone = false 

    ) -> 

        context.signature  = argsOf decoratedFn
        queue              = []   
        calls              = []
        running            = false

        queueLength = -> 
            length = 0
            if Preparator.parallel
                for item in queue
                    length++ unless item.done
            else
                for call in calls
                    length++
            length


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
  
                return defer.reject result if result instanceof Error
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
                length: queueLength()
                elements: queue
                current: _id


        return ->

            finished = Defer()

            fn = (finished, args) ->

                id   = seq++
                inject = []
                inject.push arg for arg in args

                done = (result) ->

                    _id = id
                    clearTimeout queue[id].timeout if Preparator.timeout?    
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
                
                if Preparator.timeout?
                    queue[id].timeout = setTimeout (->

                        finished.notify 
                            error: 
                                context: context
                                element: queue[id]

                        done new Error 'timeout'

                    ), Preparator.timeout 

                beforeEach = -> 

                    defer = Defer()
                    return defer.resolve() unless typeof Preparator.beforeEach is 'function'

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

                        decoratedFn.apply null, queue[id].first.concat( inject ).concat queue[id].last

                    else

                        decoratedFn.apply null, [ done ].concat queue[id].first.concat( inject ).concat queue[id].last

                    return queue[id].defer.promise


                afterEach = -> 

                    _id   = id
                    defer = Defer()
                    
                    return defer.resolve() unless typeof Preparator.afterEach is 'function'

                    done = (result) ->
                        _id = id
                        finished.notify afterEach: result
                        return defer.reject result if result instanceof Error
                        return defer.resolve result
                    
                    Preparator.afterEach done, context
                    return defer.promise


                afterAll = -> 

                    _id   = id
                    defer = Defer()
                    queue[id].done = true
                    clearTimeout queue[id].timeout if Preparator.timeout?

                    return defer.resolve() unless queueLength() == 0
                    unless typeof Preparator.afterAll is 'function'

                        #
                        # reset queue
                        #

                        queue.length = 0
                        return defer.resolve() 


                    done = (result) ->
                        _id = -1
                        queue.length = 0
                        return defer.reject result if result instanceof Error
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

                    (error) -> 
                        _id = id
                        Preparator.error error, context if Preparator.error instanceof Function
                        finished.reject error

                    finished.notify

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

            
