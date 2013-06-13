require('nez').realize 'Sync', (Sync, test, context) -> 

    context 'unit', (it) -> 

        it 'injects arguments via flat callback', (done) -> 

            decoratedFn = Sync(

                (signature) -> signature

                (arg1, arg2, arg3) -> 

                    arguments.should.eql 

                        '0': 'arg1'
                        '1': 'arg2'
                        '2': 'arg3'

                    test done

            )

            decoratedFn()


        it 'enables interesting things', (ok) -> 

            loader = (args) -> 
                for arg in args
                    require arg
            
            Jungle = { 

                frog: Sync loader, (crypto, zlib, net) -> 

                    sum = crypto.createHash 'sha1'
                    sum.update 'amicus curiae'
                    sum.digest 'hex'
                    sum.should.not.equal '085908f6599e7bd7b4e358a1f06aa61f3569e450'
                    zlib.should.equal require 'zlib'
                    net.should.equal require 'net'

                    test ok

            }

            Jungle.frog()


        it 'preserves existing arguments', (done) -> 

            Token = {

                flywheel: Sync ( 

                    #
                    # map only the first 2 args
                    # 
                    # reason being allowed to pass in from
                    # the outside
                    #

                    (args) -> args[..1] 

                ), (one, two, reason) -> 

                    one.should.equal    'one'
                    two.should.equal    'two'

                    reason.should.equal 'Puncture'
                    test done

            }

            Token.flywheel 'Puncture'

        it 'passes numbers straight through', (done) -> 

            (
                Sync 1, (one) -> 
                    one.should.equal 1
                    test done

            )()

        it 'passes strings straight through', (done) -> 

            (
                Sync '1', (one) -> 
                    one.should.equal '1'
                    test done

            )()

        it 'spreads arrays across first args', (done) -> 

            (
                Sync [1,2,'three'], (one, two, three) -> 
                    
                    arguments.should.eql {

                        '0': 1
                        '1': 2
                        '2': 'three'
                        '3': 'FOUR'

                    }

                    test done

            )('FOUR')


        it 'accepts a config object instead of function', (done) -> 

            Oscillation = {

                tarp: Sync {}, ->

                    test done

            }

            Oscillation.tarp()




    context 'Preparator (decorator config)', (it) -> 


        it 'appropriately calls beforeAll and beforeEach', (passed) -> 

            ducks     = 0
            ducklings = 0
            quark     = Sync(

                #
                # before the decorated function
                #
                beforeAll:  -> ducks++
                beforeEach: -> ducklings++

                #
                # the decorated function
                #
                ->
                    ducks.should.equal 1  
                    if ducklings > 7 then test passed # 8th()

            )

            quark quark quark quark quark quark quark quark()


