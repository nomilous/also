require('nez').realize 'Injectors', (Injectors, test, context) -> 

    context 'flat( singatureFn, fn )', (it) -> 

        it 'injects arguments via flat callback', (done) -> 

            decoratedFn = Injectors.flat(

                (signature) -> 

                    signature.should.eql ['arg1', 'arg2', 'arg3']
                    signature

                (arg1, arg2, arg3) -> 

                    arguments.should.eql 

                        '0': 'arg1'
                        '1': 'arg2'
                        '2': 'arg3'

                    test done

            )

            decoratedFn()

