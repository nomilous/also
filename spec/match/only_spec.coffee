require('nez').realize 'Only', (Only, test, context, should) -> 

    context 'if matchAll', (it) -> 

        it 'does not run the function if arg1 does not matchAll', (done) -> 

            RAN     = false
            object = property1: 'value1', property2: 'NO'
            match  = matchAll: propert1: 'value1', property2: 'value2'

            Only.if( match, (obj) -> RAN = true )( object )

            RAN.should.equal false
            test done


        it 'runs the function if arg1 does matchAll', (done) -> 

            RAN    = false
            object = property1: 'value1', property2: 'value2'

            fn     = Only.if matchAll: { property1: 'value1' }, (obj) -> RAN = true
            fn( object )

            RAN.should.equal true
            test done


        it 'allows matching from an array', (done) -> 

            ATE   = false
            lunch = 

                eat: Only.if

                    matchAll: sound: ['moo', 'cluck', 'oink']
                    
                    (meat) -> ATE = true


            lunch.eat sound: 'chirrp'
            ATE.should.equal false

            lunch.eat sound: 'moo'
            ATE.should.equal true

            test done



