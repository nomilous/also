{defers} = require '../../lib/also'
should   = require 'should'

describe 'defers', -> 

    it 'injects a promise into a function', (done) ->


        fn = defers (promise, arg) ->

            should.exist promise.resolve
            should.exist promise.reject
            should.exist promise.notify
            arg.should.equal 'ANOTHER ARGUMENT'
            done()

        fn('ANOTHER ARGUMENT')


    it 'the promise resolution functions normally', (done) -> 

        fn = defers (promise, arg) ->

            promise.resolve arg + arg + arg + 1


        fn( 77777777777 ).then( 
            (resolved) -> 
                resolved.should.equal 233333333332
                done()

            (rejected) -> 
            (notifies) -> 
        )

    it 'the promise rejection functions normally', (done) -> 

        fn = defers ({resolve, reject}, arg) ->

            reject new Error 'oh dear,'


        fn( 233333333332 ).then( 
            (resolved) -> 
            (rejected) -> 
                rejected.should.be.an.instanceof Error
                rejected.should.match /oh dear/
                done()

            (notifies) -> 
        )


    it 'the promise notifier functions normally', (done) -> 

        fn = defers ({resolve, notify}, arg1) ->

            setTimeout (-> notify 'almost done...'  ), 50
            setTimeout (-> notify 'nearly there...' ), 80
            setTimeout (-> resolve  arg1            ), 100


        messageThatAccumulated = []
        fn( 'ARG1' ).then( 
            (resolved) -> 

                messageThatAccumulated.should.eql [
                    'almost done...'
                    'nearly there...'
                ]
                resolved.should.equal 'ARG1'
                done()

            (rejected) -> 
            (notifies) -> messageThatAccumulated.push notifies
        )


    it 'rejects with uncaught exceptions', (done) -> 

        fn = defers -> 

            throw new Error 'fail'

        fn().then(
            ->
            (error) -> error.message.should.equal 'fail'; done()
            ->
        )

