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

    it 'resolves the promise with returned result of the function', (done) -> 

        run = OptionalDeferral -> 'RETURNED VALUE'
        run().then (result) -> 
            result.should.equal 'RETURNED VALUE'
            done()


    it 'passes existing args into fn', (done) -> 

        run = OptionalDeferral 

            if: -> 
            (args...) -> 

                args.should.eql [1,2,3]
                args.map (n) -> ++n

        run( 1, 2, 3 ).then (result) -> 

            result.should.eql [ 2, 3, 4 ] 
            done()


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

        
        it 'appends reject and notify as properties onto resolver', (done) ->

            UPDATES = []

            run = OptionalDeferral 

                resolver: 'matchArg'
                (arg, matchArg) -> 

                    arg.should.equal 'ARG'
                    
                    setTimeout (->

                        matchArg.notify 'UPDATE 1'

                    ), 10
                    setTimeout (->

                        matchArg.notify 'UPDATE 2'

                    ), 20
                    setTimeout (->

                        matchArg.reject new Error 'error'

                    ), 30

            run('ARG').then( 

                (result) -> 
                (error)  -> 

                    error.should.match /error/
                    UPDATES.should.eql ['UPDATE 1', 'UPDATE 2']
                    done()

                (notify) -> UPDATES.push notify

            )









    