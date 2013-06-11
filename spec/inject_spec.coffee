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



        it 'enables interesting things', (done) -> ->


            gitUser = (args, callback) -> 

                body    = ''
                https   = require 'https'
                options = 

                    hostname: 'api.github.com'
                    port:     443
                    path:     "/users/#{  args[0]  }"
                    method:   'GET'
                    headers:  'User-Agent': 'Mozilla/5.0'
  
                req = https.request options, (res) -> 

                    res.on 'data', (data) -> body += data.toString()
                    res.on 'end', -> callback null, JSON.parse body

                req.end()



            January = {

                odometer: inject.async gitUser, (error, nomilous) -> 

                    nomilous.location.should.equal ''
                    test done

            }

            January.odometer()

