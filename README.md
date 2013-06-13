also
====

decorators

### 0.0.1 (unstable)


vague example with ducks
------------------------

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


vague example with node modules
-------------------------------

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
