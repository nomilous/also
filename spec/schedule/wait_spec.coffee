should = require 'should'
Wait   = require '../../lib/schedule/wait'

describe 'Wait', -> 

    it 'runs a function', (done) -> 

        Wait( -> done() )()


    it 'accepts a test to determine if it should run the function', (done) -> 

        fn = Wait 
            until: -> true
            -> done()
        
        fn()


    it 'keeps trying test until it passes', (done) -> 

        READY = false
        DONE  = false
        fn    = Wait 

            until: -> READY
            -> DONE = true

        fn()
        DONE.should.equal false

        READY = true
        setTimeout (->

            DONE.should.equal true
            done()

        ), 20


    it 'accepts an retry interval for the test', (done) -> 

        READY = false
        DONE  = false
        fn    = Wait 

            until: -> READY
            retry: 100
            -> DONE = true

        fn()
        DONE.should.equal false

        READY = true
        setTimeout (->

            DONE.should.equal true
            done()

        ), 200



        

