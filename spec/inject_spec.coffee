require('nez').realize 'Inject', (inject, test, context) -> 

    context 'sync( signatureFn, fn )', (it) -> 

        it 'injects arguments via flat callback', (done) -> 

            decoratedFn = inject.sync(

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

            sync   = inject.sync
            loader = (args) -> 
                for arg in args
                    require arg
            
            Jungle = { 

                frog: sync loader, (crypto, zlib, net) -> 

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

                flywheel: inject.sync ( 

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


    context 'async( signatureFn, fn )', (it) -> 

        it 'enables asyncronous injection', (good) -> 


            loader = (args, callback) -> 
                callback null, ( for arg in args
                    require arg )
                  

            Noontide = {

                orb: inject.async loader, (error, os, fs) ->

                    os.should.equal require 'os' 
                    fs.should.equal require 'fs'
                    test good

            }

            Noontide.orb()


        it 'preserves original arguments', (done) -> 

            Quintessential = {

                iota: inject.async ( 

                    (args, cb) -> cb null, args[..1]

                ), (error, one, two, smidgeon) -> 

                    smidgeon.should.equal 0.000001
                    test done

            }

            Quintessential.iota 0.000001
