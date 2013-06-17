require('nez').realize 'Async', (Async, test, context, should) -> 

    context 'unit', (it) ->


        it 'throws on Preparator as Function', (done) -> 

            preparator = ->

            try 
                object = {
                    function: Async preparator, (args) -> 
                }

            catch error
                error.should.match /requires Preparator as object/
                test done


        it 'throws on Preparator as Array', (done) -> 

            preparator = []

            try 
                object = {
                    function: Async preparator, (args) -> 
                }

            catch error
                error.should.match /requires Preparator as object/
                test done

        it 'throws on Preparator as Number', (done) -> 

            preparator = 1

            try 
                object = {
                    function: Async preparator, (args) -> 
                }

            catch error
                error.should.match /requires Preparator as object/
                test done 

        it 'throws on Preparator as String', (done) -> 

            preparator = 'str'

            try 
                object = {
                    function: Async preparator, (args) -> 
                }

            catch error
                error.should.match /requires Preparator as object/
                test done

            
        it 'accepts Preparator as object (Hash)', (done) -> 

            preparator = {}

            object = {
                function: Async preparator, (args) -> test done
            }

            object.function()


        it 'calls asyncronous beforeAll', (done) -> 

            preparator = 

                beforeAll: -> test done

            object = {
                function: Async preparator, (args) -> test done
            }

            object.function()


        it 'does not call the function until beforeAll calls done()', (done) -> 

            RUN = false

            fn  = Async

                beforeAll: (done) -> 

                    #
                    # delay beforeAll
                    #

                    setTimeout done, 150

                (arg) -> 

                    #
                    # this was delayed
                    #

                    RUN = true
                    arg.should.equal 'ARG'
                    test done

            #
            # call and verify the delay
            #

            fn('ARG')

            setTimeout(
                -> RUN.should.equal false
                100
            )


        it 'allows beforeAll to indicate failure into error handler', (done) -> 

            fn = Async 

                beforeAll: (done) -> done( new Error 'beforeAll failed' )
                error: (error) -> 
                    error.should.match /beforeAll failed/
                    test done
                -> console.log 'SHOULD NOT RUN'

            fn()


        it 'provides context into beforeAll as arg2', (done) -> 

            fn = Async

                 beforeAll: (done, context) -> 

                    context.first.push 'ALWAYS ARG ONE'
                    done()

                 (arg1, arg2) -> 

                    arg1.should.equal 'ALWAYS ARG ONE'
                    arg2.should.equal 'ARG TWO'
                    test done

            fn('ARG TWO')

