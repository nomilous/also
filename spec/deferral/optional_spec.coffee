should           = require 'should'
OptionalDeferral = require '../../lib/deferral/optional'

describe 'OptionalDeferral', -> 

    it 'optionally injects a resolver into arg1', (done) ->

        OptionalDeferral()
        done()
        