require('nez').realize 'Util', (util, test, context) -> 

    context 'argsOf', (it) ->

        it 'returns the args of a basic function', (done) -> 

            util.argsOf( () -> ).should.eql []
            util.argsOf( (test, ing) -> ).should.eql ['test', 'ing']
            test done


        it 'ignores nested function', (done) -> 

            util.argsOf(

                -> (ignore, these) -> 

            ).should.eql []
            test done


        it 'ignores non function brackets', (done) ->

            util.argsOf(

                (1;'two')

            ).should.eql []
            test done