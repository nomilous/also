require('nez').realize 'Wait', (Wait, test, it) -> 

    it 'runs a function', (done) -> 

        Wait( -> test done)()


    it 'accepts a test to determine if it should run the function', (done) -> 

        fn = Wait 
            until: -> true
            -> test done
        
        fn()

        

