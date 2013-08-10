should   = require 'should'
Validate = require '../../lib/validate'

describe 'Validate.args', -> 

    it 'returs a function', (done) -> 

        Validate.args().should.be.an.instanceof Function
        done()


    it 'calling the returned function call the function passed as last arg', (done) -> 

        returnedFunction = Validate.args (arg1, arg2) -> 

            arg1.should.equal 1
            arg2.should.equal 2
            done()

        returnedFunction 1, 2


    it 'preserves context and can decorate a constructor', (done) -> 

        class Test

            constructor: Validate.args (@arg1, @arg2) -> 

        test = new Test 1, 2

        test.should.eql 

            arg1: 1
            arg2: 2

        done()


    context 'validate opts type object', -> 

        schema = 
            $address: 'module.class.function'
            name:
                first: {}
                last: {}
                species: $default: 'homo sapiens'
            address: 
                street: {}

                

        class Person

            constructor: Validate.args schema, (@name, @address) -> 


        it 'validates for missing arguments', (done) ->

            try 
            
                new Person

            catch error

                error.should.match /module.class.function\(name,address\) expects name/
                done()


        it 'checks for nested object properties', (done) -> 

            try 
            
                new Person {}, {}

            catch error

                error.should.match /module.class.function\(name,address\) expects name.first, name.last and address.street/
                done()

        it 'defaults', (done) -> 

            name = 
                first: 'Sherlock'
                last:  'Holmes'

            address = 
                street: ''

            p = new Person name, address

            p.name.species.should.equal 'homo sapiens'

            # 
            # perhaps it should not modify the origin
            # 
            # should.not.exist name.species
            # 

            done()

