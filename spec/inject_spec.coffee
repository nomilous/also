should = require 'should'
util   = require '../lib/util'
{sync, async} = require '../lib/inject'

describe 'Inject', -> 

    it 'exports', (done) -> 

        sync.should.be.an.instanceof Function
        async.should.be.an.instanceof Function
        done()


    context 'injection decorator', -> 

        it 'wraps a function into another which injects arguments into it', (done) -> 

            decoratedFunction = sync [1,2,3], (one, two, three, four) -> 

                one.should.equal   1
                two.should.equal   2
                three.should.equal 3
                four.should.equal  'FOUR'
                done()

            decoratedFunction( 'FOUR' )


    context 'Preparator', -> 

        it 'is the first arg passed to the decorator', (done) -> 

            preparator        = {}
            decoratedFunction = sync preparator, -> done()
            decoratedFunction()


        it 'can be a arg name mapping function', (done) -> 

            preparator = (argNames) -> 

                argNames.should.eql [ 'first', 'second' ]

                #
                # returned array injects
                #
                
                argNames.push 'third'
                return argNames

            decoratedFunction = sync preparator, (first, second) -> 

                arguments.should.eql { 

                    '0': 'first' 
                    '1': 'second'
                    '2': 'third'
                    '3': 'fourth'

                }
                done()

            decoratedFunction 'fourth'

