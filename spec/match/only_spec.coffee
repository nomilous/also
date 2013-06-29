require('nez').realize 'Only', (Only, test, context, should) -> 

    context 'if match', (it) -> 

        it 'runs the function only if argument matches', (done) -> 

            RAN        = false
            object     = property: 100
            ifMatch    = if: match: property: 10

            Only( ifMatch, (obj) -> RAN = true )( property: 11 )

            RAN.should.equal false
            test done
