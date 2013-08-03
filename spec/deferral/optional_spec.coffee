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

    it 'runs opts.then after calling the function', (done) -> 

        run = OptionalDeferral 

            if: -> true
            then: -> done()
            -> 

        run()


    