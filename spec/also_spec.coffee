require('nez').realize 'Also', (also, test, context) -> 

    
    context 'inject.async', (it) -> 

        it 'supports beforeEach, beforeAll and afterEach', (done) -> 
    
            {async} = also.inject

            object = {

                function: async 

                    beforeAll: (done, context) -> 

                        console.log 'beforeAll with pending calls', context.queue.length
                        done()

                    beforeEach: (done, context) -> 

                        context.first[0] = RESOLVE: context.defer.resolve
                        #console.log 'beforeEach'
                        done()

                    afterEach: (done, context) -> 

                        done()
                        console.log 'afterEach with remaining calls', context.queue.length


                    (done, count) -> 

                        console.log 'function', count
                        done.RESOLVE()

            }

            object.function( 1 )
            object.function( 2 )
            object.function( 3 )
            object.function( 4 )
            object.function( 5 )
            object.function( 6 )
            object.function( 7 )
            object.function( 8 )
            object.function( 9 )
            object.function( 10 ).then -> 

                object.function( 11 )
                object.function( 12 )
                object.function( 13 )
                object.function( 14 )
                object.function( 15 )
                object.function( 16 )
                object.function( 17 )
                object.function( 18 )
                object.function( 19 )
                object.function( 20 )


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
