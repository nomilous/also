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

                        console.log 'beforeEach'
                        done()

                    afterEach: (done) -> 

                        console.log 'afterEach'
                        done()


                    (done, count) -> 

                        console.log 'function', count
                        done()

            }

            object.function( 1 ).then ->
                
                object.function 2

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
