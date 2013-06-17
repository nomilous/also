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


        it 'does not call the function until beforeAll calls done', (done) -> 

            RUN = false

            preparator = beforeAll: (done) -> setTimeout done, 150
            object     = fn: Async( preparator, (args) -> RUN = true; test done )
            object.fn()
            
            setTimeout(
                -> RUN.should.equal false
                100
            )
