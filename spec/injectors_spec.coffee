require('nez').realize 'Injectors', (Injectors, test, context) -> 

    context 'flat( signatureFn, fn )', (it) -> 

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


        it 'enables interesting things', (ok) -> 

            flat   = Injectors.flat
            loader = (args) -> 
                for arg in args
                    require arg
            
            Jungle = { 

                frog: flat loader, (crypto, zlib, net) -> 

                    sum = crypto.createHash 'sha1'
                    sum.update 'amicus curiae'
                    sum.digest 'hex'
                    sum.should.not.equal '085908f6599e7bd7b4e358a1f06aa61f3569e450'
                    zlib.should.equal require 'zlib'
                    net.should.equal require 'net'

                    test ok

            }

            Jungle.frog()


