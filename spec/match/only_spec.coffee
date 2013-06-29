require('nez').realize 'Only', (Only, test, context, should) -> 

    context 'if match', (it) -> 

        it 'does not run the function if arg1 does not match', (done) -> 

            RAN        = false
            object     = property: 100
            ifMatch    = if: match: property: 10

            Only( ifMatch, (obj) -> RAN = true )( property: 11 )

            RAN.should.equal false
            test done


        it 'runs the function if arg1 does match', (done) -> 

            RAN    = false
            object = property: 'value'
            
            fn     = Only if: match: { property: 'value' }, (obj) -> RAN = true
            fn( object )

            RAN.should.equal true
            test done

