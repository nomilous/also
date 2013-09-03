`npm install also`

### Version 0.0.8 (unstable)

also
====

An accumulating set of function decorators. <br />

Function decorators?: [Coffeescript Ristretto](https://leanpub.com/coffeescript-ristretto)


Examples
--------

### synchronous example with ducks


```coffee

{inject} = require 'also'

ducklings = 0
ducks   = 0
quark = inject.sync 

    beforeAll:  -> ducks++
    beforeEach: -> ducklings++

    -> 

        ducks: ducks
        ducklings: ducklings
        


console.log quark quark quark quark quark quark quark()

# => { ducks: 1, ducklings: 7 }


```


### synchronous example with node modules


```coffee

nodeModules = (names) -> require name for name in names 
        
start = inject.sync nodeModules, (crypto, zlib, net) -> 

    #
    # ...
    # 

start()

```

### asynchronous example 

none. see [spec](https://github.com/nomilous/also/blob/master/spec/inject/async_spec.coffee)

todo
----

* combine with Notice (hub) and run as daemon (script server for worker/drone farm)

