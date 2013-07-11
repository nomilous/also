require('nez').realize 'Async', (Async, test, context, should) -> 

    context 'Preparator type', (it) ->


        it 'cannot be Function', (done) -> 

            preparator = ->

            try 
                object = {
                    function: Async preparator, (args) -> 
                }

            catch error
                error.should.match /requires Preparator as object/
                test done


        it 'cannot be Array', (done) -> 

            preparator = []

            try 
                object = {
                    function: Async preparator, (args) -> 
                }

            catch error
                error.should.match /requires Preparator as object/
                test done

        it 'cannot be Number', (done) -> 

            preparator = 1

            try 
                object = {
                    function: Async preparator, (args) -> 
                }

            catch error
                error.should.match /requires Preparator as object/
                test done 

        it 'cannot be String', (done) -> 

            preparator = 'str'

            try 
                object = {
                    function: Async preparator, (args) -> 
                }

            catch error
                error.should.match /requires Preparator as object/
                test done

            
        it 'must be object (Hash)', (done) -> 

            preparator = {}

            object = {
                function: Async preparator, (args) -> test done
            }

            object.function()


    context 'promise', (it) -> 

        it 'returns a promise', (done) -> 

            should.exist (Async {}, -> )().then
            #should.exist fn().then
            test done


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

                (result) -> result.should.equal 'RESULT'; test done
                (error) ->

            )

        it 'provides result from beforeEach and afterAll through status', (done) -> 

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
                    test done

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
                test done



    context 'Preparator.beforeAll()', (it) ->


        it 'is called', (done) -> 

            preparator = 

                beforeAll: -> test done

            object = {
                function: Async preparator, (args) -> test done
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

                (arg) -> 

                    #
                    # this was delayed
                    #

                    RUN = true
                    arg.should.equal 'ARG'
                    test done

            #
            # call and verify the delay
            #

            fn('ARG')

            setTimeout(
                -> RUN.should.equal false
                100
            )

            setTimeout(
                -> RUN.should.equal true
                200
            )

        it 'is run only once, beforeAll calls to decoratedFn', (done) ->

            cn = before: 0, during: 0
            fn = Async

                beforeAll: (done) -> cn.before++; done()
                -> 
                    cn.before.should.equal 1 # already
                    cn.during++

            fn()
            fn()
            fn()
            fn()
            fn()
            
            setTimeout(
                -> 
                    cn.should.eql before: 1, during: 5
                    test done

                100
            )
            

        it 'allows beforeAll to indicate failure into error handler', (done) -> 

            fn = Async 

                beforeAll: (done) -> done( new Error 'beforeAll failed' )
                error: (error) -> 
                    error.should.match /beforeAll failed/
                    test done
                -> console.log 'SHOULD NOT RUN'

            fn()


        it 'provides context into beforeAll as arg2', (done) -> 

            fn = Async

                 beforeAll: (done, context) -> 

                    context.first.push 'ALWAYS ARG ONE'
                    done()

                 (arg1, arg2) -> 

                    arg1.should.equal 'ALWAYS ARG ONE'
                    arg2.should.equal 'another arg'
                    test done

            fn('another arg')

    context 'Preparator.beforeEach()', (it) -> 

        it 'is called', (done) -> 

            fn = Async

                beforeEach: -> test done
                ->

            fn()


        it 'suspends call to decoratedFn till done()', (done) -> 

            RUN = false

            fn  = Async

                beforeEach: (done) -> 

                    setTimeout done, 150

                (arg) -> 

                    RUN = true
                    test done

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
                    test done

                100
            )


    context 'Preparator.afterEach()', (it) ->

        it 'runs after the call to decoratedFn', (done) ->

            RAN_ALREADY = false

            Async

                afterEach: -> 

                    RAN_ALREADY.should.equal true
                    test done

                (done) -> 

                    RAN_ALREADY = true
                    done()

            .apply null


        it 'runs after each call', (done) -> 

            count  = undefined
            counts = []

            fn = Async

                beforeAll: (done) -> 

                    count = 10
                    done()

                afterEach: (done) -> 

                    counts.push count
                    test done

                (done) -> 

                    count++
                    done()


            fn().then -> fn().then -> fn().then -> 

                counts.should.eql [11,12,13]
                test done


