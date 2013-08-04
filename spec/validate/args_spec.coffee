should   = require 'should'
Validate = require '../../lib/validate'

describe 'Validate.args', -> 

    it 'returs a function', (done) -> 

        Validate.args().should.be.an.instanceof Function
        done()