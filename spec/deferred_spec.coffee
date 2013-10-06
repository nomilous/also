deferred = require '../lib/deferred'
should   = require 'should'

describe 'defers', -> 

    it 'injects a deferral at arg1 and returns the promise', -> 

        fn = deferred (action) -> action.resolve 'result'
        fn().then (result) -> result.should.equal 'result'

    it 'notifies', (done) -> 

        fn = deferred ({notify}) -> notify 1
        fn().then(
            ->
            ->
            (one) -> 
                one.should.equal 1
                done()
        )

    it 'notifies in a pipeline', (done) -> 

        pipeline = require 'when/pipeline'
        N = []
        pipeline([

            deferred ({resolve, notify}) -> 
                process.nextTick -> 
                    notify 1
                    process.nextTick -> 
                        resolve()

            deferred ({resolve, notify}) -> 
                process.nextTick -> 
                    notify 2
                    process.nextTick -> 
                        resolve()

        ]).then(

            -> 
                N.should.eql [1, 2]
                done()
            ->
            (n) -> N.push n 
        )

    it 'notifies in a pipeline natively', (done) -> 

        pipeline = require 'when/pipeline'
        defer    = require('when').defer

        N = []

        pipeline([

            -> 
                d = defer()
                process.nextTick -> 
                    d.notify 1
                    process.nextTick -> 
                        d.resolve()
                d.promise
            ->
                d = defer()
                process.nextTick -> 
                    d.notify 2
                    process.nextTick -> 
                        d.resolve()
                d.promise

            deferred ({resolve, notify}) -> 
                process.nextTick -> 
                    notify 3
                    process.nextTick -> 
                        resolve()

        ]).then(
            -> 
                N.should.eql [1, 2, 3]
                done()
            ->
            (n) -> N.push n 
        )
