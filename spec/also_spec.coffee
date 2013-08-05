should = require 'should'
Also   = require '../lib/also'

describe 'Also', -> 

    it 'calls the supplied moduleFactoryFn with a contextRoot', (done) -> 

        Also exports, {}, (root) -> 

            root.context.should.be.an.instanceof Object
            done()


    it 'exports objects from the result of the call to moduleFactoryFn', (done) -> 

        class SpecificallyDifferentNameOfClass

            constructor: ->

        class Another

            constructor: -> 


        Also exports, {}, (root) -> 

            ClassName: SpecificallyDifferentNameOfClass
            AnotherClass: Another


        #
        # require THIS file
        #

        {ClassName, AnotherClass} = require __filename


        test1 = new ClassName
        test2 = new AnotherClass
        test1.should.be.an.instanceof SpecificallyDifferentNameOfClass
        test2.should.be.an.instanceof Another
        done()


    it 'provides convenience access to local submodules into moduleFactoryFn', (done) -> 

        Also exports, {}, (root) -> 

            {async} = root.inject
            async.should.equal require '../lib/inject/async'
            done()
