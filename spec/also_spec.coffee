should = require 'should'

describe 'Also', -> 

    context 'inject.sync', -> 

        it 'ducks', (done) -> 

            {sync} = require( '../lib/also' ).inject

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

            done()
