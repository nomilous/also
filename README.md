also
====

decorators

### 0.0.1 (unstable)


vague example
-------------

with ducks


```coffee

{sync, async} = require( 'also' ).inject


ducks     = 0
ducklings = 0

quark     = sync 

    beforeAll:  -> ducks++
    beforeEach: -> ducklings++

    -> 

        ducks: ducks
        ducklings: ducklings


quark quark quark quark quark quark quark()

#
# => { ducks: 1, ducklings: 7 }
#

```

