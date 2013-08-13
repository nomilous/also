should = require 'should'
Async  = require '../../lib/inject/async'

context 'Preparator type', ->

    it 'cannot be Function', (done) -> 

        preparator = ->

        try 
            object = {
                function: Async preparator, (args) -> 
            }

        catch error

            error.should.match /requires Preparator as object/
            done()


    it 'cannot be Array', (done) -> 

        preparator = []

        try 
            object = {
                function: Async preparator, (args) -> 
            }

        catch error
            error.should.match /requires Preparator as object/
            done()

    it 'cannot be Number', (done) -> 

        preparator = 1

        try 
            object = {
                function: Async preparator, (args) -> 
            }

        catch error
            error.should.match /requires Preparator as object/
            done()

    it 'cannot be String', (done) -> 

        preparator = 'str'

        try 
            object = {
                function: Async preparator, (args) -> 
            }

        catch error
            error.should.match /requires Preparator as object/
            done()

        
    it 'preparator is optional', (done) -> 

        object = {
            function: Async (args) -> done()
        }

        object.function()


context 'promise', -> 

    it 'returns a promise', (done) -> 

        should.exist (Async -> )().then
        done()


    it 'defaults passing the promise resolver / rejector as arg1', (done) -> 

        #
        # this is still up in the air re "interface" design
        #

        fn1 = Async {}, (done) -> done new Error('ERROR')
        
        fn2 = Async {}, (done) -> done 'RESULT'


        fn1().then(

            (result) ->
            (error) -> error.should.match /ERROR/

        )

        fn2().then(

            (result) -> result.should.equal 'RESULT'; done()
            (error) ->

        )

    it 'provides result from beforeEach and afterEach through status', (done) -> 

        RESULTS = []
        fn = Async 

            beforeEach: (done) -> done 'BEFORE_EACH_RESULT'
            afterEach:  (done) -> done 'AFTER_EACH_RESULT'
            (done) -> done 'FN_RESULT'

        fn().then(

            (result) -> 

                RESULTS.should.eql [

                    { beforeEach: 'BEFORE_EACH_RESULT' }
                    { result: 'FN_RESULT' }
                    { afterEach: 'AFTER_EACH_RESULT' }

                ]
                done()

            (error)  -> 
            (notify) -> RESULTS.push notify
        )


    it 'provides access to the deferral for alternative injection', (done) -> 

        fn = Async

            beforeEach: (done, context) -> 

                #
                # set alternative to the default injection of resolver as arg1
                #

                defer = context.defer
                context.last[0] = defer.resolve
                done()

            (arg1, arg2, resolve) -> 

                resolve 'RESULT: ' + arg1 + arg2


        fn( 'A', 'B' ).then (result) -> 

            result.should.equal 'RESULT: AB'
            done()



context 'Preparator.beforeAll()', ->


    it 'is called', (done) -> 

        preparator = 

            beforeAll: -> done()

        object = {
            function: Async preparator, (args) -> done()
        }

        object.function()


    it 'suspends call to decoratedFn till done()', (done) -> 

        RUN = false

        fn  = Async

            beforeAll: (done) -> 

                #
                # delay in beforeAll
                #

                setTimeout done, 150

            (done, arg) -> 

                #
                # this was delayed
                #

                RUN = true
                #arg.should.equal 'ARG'
                done()

        #
        # call and verify the delay
        #

        fn('ARG')

        setTimeout(
            -> RUN.should.equal false
            100
        )

        setTimeout(
            -> 
                RUN.should.equal true
                done()
            200
        )

    it 'is run only once, beforeAll calls to decoratedFn', (done) ->

        cn = before: 0, during: 0
        fn = Async

            beforeAll: (done) -> 
                cn.before++
                done()
            beforeEach: (done, inject) -> 
                inject.args[0] = inject.defer.resolve
                done()
            (done) -> 
                cn.before.should.equal 1 # already
                cn.during++
                done()

        fn()
        fn()
        fn()
        fn()
        fn().then ->
        
            cn.should.eql before: 1, during: 5
            done()
        

    it 'allows beforeAll to indicate failure into error handler', (done) -> 

        fn = Async 

            beforeAll: (done) -> done( new Error 'beforeAll failed' )
            onError: (error) -> 
                error.should.match /beforeAll failed/
                done()
            -> console.log 'SHOULD NOT RUN'

        fn()


    it 'provides context into beforeAll as arg2', (done) -> 

        fn = Async

             beforeAll: (done, context) -> 

                context.first.push 'ALWAYS ARG ONE'
                done()

             (done, arg1, arg2) -> 

                arg1.should.equal 'ALWAYS ARG ONE'
                arg2.should.equal 'another arg'
                done()

        fn('another arg').then -> done()

context 'Preparator.beforeEach()', -> 

    it 'is called', (done) -> 

        fn = Async

            beforeEach: -> done()
            ->

        fn()


    it 'suspends call to decoratedFn till done()', (done) -> 

        RUN = false

        fn  = Async

            beforeEach: (done) -> 

                setTimeout done, 150

            (arg) -> 

                RUN = true
                done()

        fn('ARG')

        setTimeout(
            -> RUN.should.equal false
            100
        )

        setTimeout(
            -> RUN.should.equal true
            200
        )

    it 'is run once beforeEach call to decoratedFn', (done) -> 

        cn = before: 0, during: 0
        fn = Async

            beforeEach: (done) -> 

                cn.before++
                done()

            -> 
                cn.during++

        fn()
        fn()
        fn()
        fn()
        fn()

        setTimeout(
            -> 
                cn.should.eql before: 5, during: 5
                done()

            100
        )


context 'Preparator.afterEach()', ->

    it 'runs after the call to decoratedFn', (done) ->

        RAN_ALREADY = false

        Async

            afterEach: -> 

                RAN_ALREADY.should.equal true
                done()

            (done) -> 

                RAN_ALREADY = true
                done()

        .apply null


    it 'runs after each call', (done) -> 

        count  = 0

        fn = Async

            afterEach: (done) -> 

                count++
                done()

            (done) -> 

                done()


        fn()
        fn()
        fn().then -> 

            count.should.equal 3
            done()


context 'Preparator.parallel', -> 

    it 'can be set to false to run calls in sequence', (done) -> 

        #
        # the tricky bit...
        #

        RAN = []

        fn  = Async

            parallel: false

            beforeEach: (done, context) -> 

                # console.log BEFORE: 
                #     queue: context.queue.length
                #     args: context.args
                done()

            afterEach: (done, context) -> 

                # console.log AFTER: 
                #     queue: context.queue.length
                #     args: context.args
                done()

            (done, num) -> 

                RAN.push num
                done()

        fn( 1 ).then -> RAN.should.eql [1]
        fn( 2 ).then -> RAN.should.eql [1,2]
        fn( 3 ).then -> RAN.should.eql [1,2,3]
        fn( 4 ).then -> RAN.should.eql [1,2,3,4]
        fn( 5 ).then -> 
            #console.log RAN
            done()

context 'Preparator.afterAll', -> 

    it 'runs after all with parallel true', (done) -> 

        RAN   = []
        COUNT = 0

        fn  = Async

            afterEach: (done) -> done()

            afterAll: (done) -> 

                RAN.should.eql [ 1, 2, 3, 4, 5 ]
                COUNT++
                done()

            (done, num) -> 

                RAN.push num
                done()

        fn 1
        fn 2
        fn 3
        fn( 4 ).then -> 

            COUNT.should.equal 1
            done()

        fn 5

    it 'runs after all with parallel false', (done) -> 

        RAN   = []
        COUNT = 0

        fn  = Async

            parallel: false

            afterAll: (done) -> 

                RAN.should.eql [ 1, 2, 3, 4, 5 ]
                COUNT++
                done()

            (done, num) -> 

                RAN.push num
                done()

        fn 1
        fn 2
        fn 3
        fn( 4 ).then -> COUNT.should.equal 0
        fn( 5 ).then -> 

            COUNT.should.equal 1
            # console.log COUNT
            # console.log RAN
            done()

    it 'supports beforeEach, beforeAll and afterEach', (done) -> 

        preparator = 

            parallel: false

            beforeAll: (done, context) -> 

                #console.log 'BEFORE_ALL with pending calls', context.queue.elements.length
                done()

            beforeEach: (done, context) -> 

                #
                # inject resolver as last arg
                #
                # context.last[0] = context.defer.resolve
                #console.log 'beforeEach with pending calls', context.queue.remaining
                context.last[1] = context.defer.resolve
                done()

            afterEach: (done, context) -> 

                #console.log 'afterEach with remaining calls', context.queue.length
                done()
                

            afterAll: (done, context) -> 

                #console.log context.queue.elements
                #console.log 'AFTER_ALL with remaining calls', context.queue.remaining
                done()


        #
        # does not work with classes
        #
        # class Thing
        #     constructor: (@title, @numbers = []) -> 
        #     function: async( preparator, (num, undef, done) => 
        #         console.log @title, 'runs function with num:', num
        #         @numbers.push num
        #         done()
        #     )
        # 

        thing = {
            numbers: []
            function: Async preparator, (num, undef, done) -> 
                thing.numbers.push num
                done()
        }

        
        thing.function( 1 )
        thing.function( 2 )
        thing.function( 3 )
        thing.function( 4 )
        thing.function( 5 )
        thing.function( 6 )
        thing.function( 7 )
        thing.function( 8 )
        thing.function( 9 )
        thing.function( 10 ).then -> 

            thing.numbers.should.eql [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ]

        thing.function( 11 )
        thing.function( 12 )
        thing.function( 13 )
        thing.function( 14 )
        thing.function( 15 )
        thing.function( 16 )
        thing.function( 17 )
        thing.function( 18 )
        thing.function( 19 )
        thing.function( 20 ).then -> 

            #console.log thing.numbers
            thing.numbers.should.eql [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 ]
            done()

