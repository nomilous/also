should = require 'should'
util   = require '../lib/util'

describe 'Util', -> 

    context 'argsOf', ->

        it 'returns the args of a basic function', (done) -> 

            util.argsOf( () -> ).should.eql []
            util.argsOf( (test, ing) -> ).should.eql ['test', 'ing']
            done()


        it 'ignores nested function', (done) -> 

            util.argsOf(

                -> (ignore, these) -> 

            ).should.eql []
            done()


        it 'ignores non function brackets', (done) ->

            util.argsOf(

                (1;'two')

            ).should.eql []
            done()