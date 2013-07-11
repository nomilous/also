require('nez').realize 'Also', (also, test, context) -> 

    
    context 'inject.async', (it) -> 

        it 'supports beforeEach, beforeAll and afterEach', (done) -> 
    
            {async} = also.inject

            preparator = 

                beforeAll: (done, context) -> 

                    console.log 'beforeAll with pending calls', context.queue.length
                    done()

                beforeEach: (done, context) -> 

                    #
                    # inject resolver as last arg
                    #
                    # context.last[0] = context.defer.resolve
                    context.last[1] = context.defer.resolve
                    done()

                afterEach: (done, context) -> 

                    done()
                    console.log 'afterEach with remaining calls', context.queue.length



            class Thing

                constructor: (@name) -> 

                function: async( preparator, (count, undef, done) => 

                    console.log @name, 'runs function with count:', count
                    done()

                )

            thing = new Thing 'NAME'
            
            thing.function( 1 )
            thing.function( 2 )
            thing.function( 3 )
            thing.function( 4 )
            thing.function( 5 )
            thing.function( 6 )
            thing.function( 7 )
            thing.function( 8 )
            thing.function( 9 )
            thing.function( 10 )
            thing.function( 11 )
            thing.function( 12 )
            thing.function( 13 )
            thing.function( 14 )
            thing.function( 15 )
            thing.function( 16 )
            thing.function( 17 )
            thing.function( 18 )
            thing.function( 19 )
            thing.function( 20 )


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
