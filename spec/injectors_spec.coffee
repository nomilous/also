require('nez').realize 'Injectors', (Injectors, test, context) -> 

    context 'flat( singatureFn, fn )', (it) -> 

        it 'injects arguments via flat callback', (done) -> 

            decoratedFn = Injectors.flat (

                (signature) -> 

                    signature.should.eql ['arg1', 'arg2', 'arg3']
                    test done

                (arg1, arg2, arg3) -> 

            )

            decoratedFn()

