require('nez').realize 'Async', (Async, test, context, should) -> 

    context 'unit', (it) ->

        it 'enables asyncronous injection', (good) -> 

            loader = (args, callback) -> 
                callback null, ( for arg in args
                    require arg )
                  

            Noontide = {

                orb: Async loader, (error, os, fs) ->

                    os.should.equal require 'os' 
                    fs.should.equal require 'fs'
                    test good

            }

            Noontide.orb()


        it 'preserves original arguments', (done) -> 

            Quintessential = {

                iota: Async ( 

                    (args, cb) -> cb null, args[..1]

                ), (error, c, G, planckLength) -> 

                    planckLength.should.equal '1.61619926 × 10-35 meters'
                    test done

            }

            Quintessential.iota '1.61619926 × 10-35 meters'


        it 'accepts a config object instead of function', (done) -> 

            Perimeter = {

                sorbet: Async {




                }, ->

                    throw 'pending config'

            }

            Perimeter.sorbet()

        it 'spreads arrays across first args', (done) -> 

            (
                Async [1,2,'three'], (one, two, three) -> 
                    
                    arguments.should.eql {

                        '0': 1
                        '1': 2
                        '2': 'three'
                        '3': 'FOUR'

                    }

                    test done

            )('FOUR')


        it 'passes numbers straight through', (done) -> 

            (
                Async 1, (one) -> 
                    one.should.equal 1
                    test done

            )()

        it 'passes strings straight through', (done) -> 

            (
                Async '1', (one, moo) -> 
                    one.should.equal '1'
                    moo.should.equal 'moo'
                    test done

            )('moo')
