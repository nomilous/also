require('nez').realize 'Also', (also, test, context) -> 

    
    context 'inject.async', (it) -> 

        {async} = also.inject

        it 'supports beforeEach, beforeAll and afterEach', (done) -> 
    
            preparator = 

                parallel: false

                beforeAll: (done, context) -> 

                    #console.log 'BEFORE_ALL with pending calls', context.queue.elements.length
                    done()

                beforeEach: (done, context) -> 

                    #
                    # inject resolver as last arg
                    #
                    # context.last[0] = context.defer.resolve
                    #console.log 'beforeEach with pending calls', context.queue.remaining
                    context.last[1] = context.defer.resolve
                    done()

                afterEach: (done, context) -> 

                    #console.log 'afterEach with remaining calls', context.queue.length
                    done()
                    

                afterAll: (done, context) -> 

                    #console.log context.queue.elements
                    #console.log 'AFTER_ALL with remaining calls', context.queue.remaining
                    done()


            #
            # does not work with classes
            #
            # class Thing
            #     constructor: (@title, @numbers = []) -> 
            #     function: async( preparator, (num, undef, done) => 
            #         console.log @title, 'runs function with num:', num
            #         @numbers.push num
            #         done()
            #     )
            # 

            thing = {
                numbers: []
                function: async preparator, (num, undef, done) -> 
                    thing.numbers.push num
                    done()
            }

            
            thing.function( 1 )
            thing.function( 2 )
            thing.function( 3 )
            thing.function( 4 )
            thing.function( 5 )
            thing.function( 6 )
            thing.function( 7 )
            thing.function( 8 )
            thing.function( 9 )
            thing.function( 10 ).then -> 

                thing.numbers.should.eql [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ]

            thing.function( 11 )
            thing.function( 12 )
            thing.function( 13 )
            thing.function( 14 )
            thing.function( 15 )
            thing.function( 16 )
            thing.function( 17 )
            thing.function( 18 )
            thing.function( 19 )
            thing.function( 20 ).then -> 

                #console.log thing.numbers
                thing.numbers.should.eql [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 ]
                test done


        it 'times out', (done) -> 

            fn = async 
                parallel: false
                timeout: 100
                error: (error, context) -> 
                    #console.log error
                    # console.log 
                    #     error: error 
                    #     element: context.queue.elements[context.queue.current]
                notify: (update, context) -> 
                    update.type.should.equal 'timeout'
                    test done
                        
                (done) -> 

            fn()

        it 'preparator as optional', (done) -> 

            fn = async (done) -> done 1
            fn().then (result) -> 
                result.should.equal 1
                test done

        it 'ducks', (done) -> 

            {sync, async} = require( '../lib/also' ).inject

            ducks     = 0
            ducklings = 0
            quark     = sync 
  
                beforeAll:  -> ducks++
                beforeEach: -> ducklings++

                -> 

                    ducks: ducks
                    ducklings: ducklings

            (quark quark quark quark quark quark quark()).should.eql 

                ducks: 1
                ducklings: 7

            test done
