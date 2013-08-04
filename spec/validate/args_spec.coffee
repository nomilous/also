should   = require 'should'
Validate = require '../../lib/validate'

describe 'Validate.args', -> 

    it 'returs a function', (done) -> 

        Validate.args().should.be.an.instanceof Function
        done()


    it 'calling the returned function call the function passed as last arg', (done) -> 

        returnedFunction = Validate.args (arg1, arg2) -> 

            arg1.should.equal 1
            arg2.should.equal 2
            done()

        returnedFunction 1, 2


    it 'preserves context and can decorate a constructor', (done) -> 

        class Test

            constructor: Validate.args (@arg1, @arg2) -> 

        test = new Test 1, 2

        test.should.eql 

            arg1: 1
            arg2: 2

        done()

