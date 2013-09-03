should = require 'should'
Sync  = require '../../lib/inject/sync'


describe 'Sync', -> 

    
    context 'Preparator as a Number', -> 
        it 'is passed directly through as arg1', (done) -> 
            fn = Sync 1, (one) -> 
                one.should.equal 1
                done()
            fn()


    context 'Preparator as a String', -> 
        it 'is passed directly through as arg1', (done) -> 
            fn = Sync 'string', (s) -> 
                s.should.equal 'string'
                done()
            fn()


    context 'Preparator as Array', ->   
        it 'is passed direcly as arg1..N', (done) -> 
            fn = Sync [1,2,'three'], (one, two, three) ->           
                arguments.should.eql {
                    '0': 1
                    '1': 2
                    '2': 'three'
                    '3': 'FOUR'
                }
                done()  
            fn('FOUR') 


    context 'Preparator as Function', -> 

        it 'allows mapping arguments', (done) -> 

            decoratedFn = Sync(

                #
                # first function maps arguments,
                # 
                # reutrned array is injected 
                # into second function
                #

                (signature) -> signature

                (arg1, arg2, arg3) -> 

                    arguments.should.eql 

                        '0': 'arg1'
                        '1': 'arg2'
                        '2': 'arg3'

                    done()

            )
            decoratedFn()


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

                ), (one, two, rea, son) -> 
                    one.should.equal    'one'
                    two.should.equal    'two'
                    (rea + son).should.equal 'Puncture'
                    done()
            }
            Token.flywheel 'Pun', 'cture'


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
                    ok()
            }
            Jungle.frog()


    context 'Preparator as object', -> 


        it 'appropriately calls beforeAll and beforeEach', -> 

            Dwarves     = 0
            SnowWhites  = 0

            Hi = Ho = Sync

                beforeAll:  -> SnowWhites++
                beforeEach: -> Dwarves++

                -> 

                    SnowWhites: SnowWhites, Dwarves: Dwarves

            

            console.log Hi Ho, Hi Ho, Hi Ho Hi Ho, Hi Ho()

            # ducks     = 0
            # ducklings = 0
            # quark     = Sync(

            #     #
            #     # before the decorated function
            #     #
            #     beforeAll:  -> ducks++
            #     beforeEach: -> ducklings++

            #     #
            #     # the decorated function
            #     #
            #     ->
            #         ducks.should.equal 1  
            #         if ducklings > 7 then done() # 8th()

            # )

            # quark quark quark quark quark quark quark quark()




        it 'passes context to the befores and afters', (done) -> 

            preparator = 

                beforeAll:  (context) -> context.should.be.an.instanceof Function
                beforeEach: (context) -> context.signature.should.eql ['arg1', 'arg2', 'arg3']
                afterEach:  (context) -> context.first.should.eql []

            Sync( preparator, (arg1, arg2, arg3) -> ) done()



        it 'allows injection preparation in the befores', (done) -> 

            Sync( 

                beforeAll:  (context) -> context.first.push  'ARG1'
                beforeEach: (context) -> context.inject.push 'ARG2'
                afterEach:  (context) -> done()

                -> 

                    arguments.should.eql 

                        '0': 'ARG1'
                        '1': 'ARG2'
                        '2': 'ELEPHANT'
                        '3': 7


            ) 'ELEPHANT', 7


        it 'can append to injected args', (done) -> 

            Sync

                beforeAll: (context) -> context.last.push 'end'

                (the, end) -> 

                    end.should.equal 'end', (the end)
        


            .apply null, [ -> done() ]


