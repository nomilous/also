should = require 'should'
Also   = require '../lib/also'

describe 'Also', -> 

    it 'calls the supplied moduleFactoryFn with a contextRoot', (done) -> 

        Also '', {}, (root) -> 

            root.context.should.be.an.instanceof Object
            done()

    it 'returns the result of the call to moduleFactoryFn', (done) -> 

        {ClassName} = Also '', {}, (root) -> 

            ClassName: class ClassName

                constructor: (@property) -> 

        (new ClassName 'VALUE').property.should.equal 'VALUE'
        done()
