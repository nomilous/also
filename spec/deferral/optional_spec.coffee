should           = require 'should'
OptionalDeferral = require '../../lib/deferral/optional'

describe 'OptionalDeferral', -> 

    it 'returns a function', (done) ->

        OptionalDeferral(->).should.be.an.instanceof Function 
        done()


    it 'expects a function as last arg', (done) -> 

        try OptionalDeferral {}, 1
        catch error

            error.should.match /expected function as last arg/
            done()


    it 'calling the returned function calls the function at last arg', (done) -> 

        run = OptionalDeferral done
        run()

    it 'returns a promise', (done) -> 

        run = OptionalDeferral -> 
        run().then.should.be.an.instanceof Function
        done()


    it 'passes existing args into fn', (done) -> 

        run = OptionalDeferral 

            if: -> 
            (args...) -> 

                args.should.eql [1,2,3]
                done()

        run 1, 2, 3


    context 'opts.resolver', -> 

        it 'defines arg signature match for resolver injection', (done) -> 

            run = OptionalDeferral 

                resolver: 'resolve'
                (arg, resolve) -> 

                    arg.should.equal 'ARG'
                    resolve 'RESULT'

            run('ARG').then (result) -> 

                result.should.equal 'RESULT'
                done()

        it 'auto resolves AFTER running the fn if no arg matched as resolver', (done) -> 

            RUN = false
            run = OptionalDeferral 

                resolver: 'done'
                (arg1, resolver) -> 

                    RUN = true

            run( 'ARG1' ).then -> 

                RUN.should.equal true
                done()

        
        it 'appends resolve, reject and notify as properties onto resolver', (done) ->

            UPDATES = []

            run = OptionalDeferral 

                resolver: 'matchArg'
                (arg, matchArg) -> 

                    #
                    # for continuity
                    #

                    should.exist matchArg.resolve
                    should.exist matchArg.reject
                    should.exist matchArg.notify

                    #
                    # for use as resolver: (done) -> done()
                    #

                    matchArg.should.equal matchArg.resolve

                    
                    setTimeout (->

                        matchArg.notify 'UPDATE 1'

                    ), 10
                    setTimeout (->

                        matchArg.notify 'UPDATE 2'

                    ), 20
                    setTimeout (->

                        matchArg.reject new Error 'error'

                    ), 30

            run().then( 

                (result) -> 
                (error)  -> 

                    error.should.match /error/
                    UPDATES.should.eql ['UPDATE 1', 'UPDATE 2']
                    done()

                (notify) -> UPDATES.push notify

            )


        it 'defaults the function call on `this` context', (done) -> 

            class TestThatItWoksOnClasses
                constructor: (@property) ->
                promise: OptionalDeferral resolver: 'defer', (arg, defer) -> 

                    defer.resolve @property + ' ' + arg


            test = new TestThatItWoksOnClasses 'VALUE'
            promise = test.promise 'ARG'
            promise.then (result) ->

                result.should.equal 'VALUE ARG'
                done()


        it 'can specify null as alternative object context', (done) -> 

            obj = new Object

                property: 'VALUE'
                promise: OptionalDeferral 

                    resolver: 'defer'
                    context: null

                    (arg, defer) -> 

                        #
                        # context was set to null / global
                        #

                        defer.resolve @process.title

            obj.promise().then (result) -> 

                result.should.equal 'node'
                done()

        it 'can specify another object as context', (done) -> 

            obj1 = new Object 
                property: 'A'

            obj2 = new Object 
                property: 'B'
                promise: OptionalDeferral 

                    resolver: 'defer'
                    context: obj1

                    (defer) -> 

                        #
                        # @property refers to value at instance: obj1
                        #

                        defer.resolve @property


            obj2.promise().then (result) -> 

                result.should.equal 'A'
                done()


        context 'can specify a timeout', -> 

            it 'timeout, by default, rejects the promise'

            it 'timeout can resolve the promise instead'

            it 'timeout notifies on the promise'




    