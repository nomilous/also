require('nez').realize 'Also', (also, test, context) -> 

    
    context 'inject.async', (it) -> 

        it 'supports beforeEach, beforeAll and afterEach', (done) -> 
    
            {async} = also.inject

            object = {

                function: async 

                    beforeAll: (done) -> 

                        console.log 'beforeAll'
                        done()

                    beforeEach: (done, inject) -> 

                        inject.first[0] = RESOLVE: inject.defer.resolve
                        console.log 'beforeEach'
                        done()

                    afterEach: (done) -> 

                        console.log 'afterEach'
                        done()


                    (done, count, last) -> 

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
