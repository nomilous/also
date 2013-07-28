### Version 0.0.4 (unstable)

`npm install also`

also
====

An accumulating set of function decorators. <br />

Function decorators?: [Coffeescript Ristretto](https://leanpub.com/coffeescript-ristretto)


Examples
--------

### synchronous example with ducks


```coffee

{sync, async} = require( 'also' ).inject

ducks     = 0
ducklings = 0
quark     = sync 

    beforeEach: -> ducklings++
    beforeAll:  -> ducks++

    -> 

        ducklings: ducklings
        ducks: ducks
        


quark quark quark quark quark quark quark()

# => { ducks: 1, ducklings: 7 }


```


### synchronous example with node modules


```coffee

nodeModules = (names) -> 
    for name in names 
        require name

start = sync nodeModules, (crypto, zlib, net) -> 

    #
    # ...
    # 

start()

```

todo
----

* combine with Notice (hub) and run as daemon (script server for drone farm)

