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


    it 'calling the returned function calls arg1.if if provided', (done) -> 

        run = OptionalDeferral 

            if: -> done()
            -> 

        run()

    it 'passes existing args into fn', (done) -> 

        run = OptionalDeferral 

            if: -> 
            (args...) -> 

                args.should.eql [1,2,3]
                done()

        run 1, 2, 3


    it '(if opts.if() is true) creates a deferral, passes the resolver into arg1 and returns the promise', (done) -> 

        run = OptionalDeferral 

            if: -> true
            (resolve) -> resolve 'RESULT'

        run().then (result) -> 

            result.should.equal 'RESULT'
            done()

    it 'appends args after resolver if deferred', (done) -> 

        run = OptionalDeferral 

            if: -> true
            (resolver, args...) -> resolver args.map (n) -> ++n
                
        run( 1, 2, 3 ).then (result) -> 

            result.should.eql [ 2, 3, 4 ]
            done()




    