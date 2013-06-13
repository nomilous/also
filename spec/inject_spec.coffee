require('nez').realize 'Inject', (Inject, test, it) -> 

    it 'exports async and sync', (done) -> 

        Inject.async.should.be.an.instanceof Function
        Inject.async.should.be.an.instanceof Function
        test done

