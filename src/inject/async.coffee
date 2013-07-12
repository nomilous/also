argsOf   = require('../util').argsOf 
Defer    = require('when').defer
sequence = require 'when/sequence'

module.exports = (Preparator, decoratedFn) -> 
    
    seq  = 0
    _id  = seq

    if typeof Preparator != 'object' or Preparator instanceof Array

        throw new Error 'also.inject.async(Preparator, decoratedFn) requires Preparator as object'

    Preparator.parallel = true unless Preparator.parallel?

    do (

        context = -> 
        beforeAllDone = false

    ) -> 

        context.signature  = argsOf decoratedFn
        queue              = []   
        console.log 'TODO: reset queue (nothing is clearing this out, done flag is being set)'
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

            #
            # TODO: done once part can be factored out as also.once(fn) decorator
            # 

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


        afterAll = -> 

            defer = Defer()
            return defer.resolve() unless typeof Preparator.afterAll is 'function'

            done = (result) ->
                _id = -1
                return defer.reject result if result instanceof Error
                return defer.resolve result
            
            _id = -1
            Preparator.afterAll done, context
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
        


        return ->

            finished = Defer()

            fn = (finished, args) ->

                id   = seq++
                inject = []
                inject.push arg for arg in args

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

                        decoratedFn.apply null, [ (result) ->

                            finished.notify result: result
                            return queue[id].defer.reject result if result instanceof Error
                            return queue[id].defer.resolve result

                        ].concat queue[id].first.concat( inject ).concat queue[id].last

                    return queue[id].defer.promise


                afterEach = -> 

                    _id   = id
                    defer = Defer()
                    
                    unless typeof Preparator.afterEach is 'function'

                        queue[id].done = true
                        return afterAll() if queueLength() == 0
                        return defer.resolve()

                    done = (result) ->
                        _id = id
                        queue[id].done = true
                        finished.notify afterEach: result
                        if result instanceof Error
                            defer.reject result 
                        else
                            defer.resolve result
                        afterAll() if queueLength() == 0
                    
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

            
