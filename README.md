`npm install also`

### Version 0.0.13 (unstable)

also
====

An accumulating set of function decorators. <br />

Function decorators?: [Coffeescript Ristretto](https://leanpub.com/coffeescript-ristretto)


Examples
--------

### synchronous example with fairy tale


```coffee

Dwarves     = 0
SnowWhites  = 0

{inject} = require 'also'

Hi = Ho = inject.sync

    beforeAll:  -> SnowWhites++
    beforeEach: -> Dwarves++

    -> 

        SnowWhites: SnowWhites, Dwarves: Dwarves



Hi Ho, Hi Ho, Hi Ho Hi Ho, Hi Ho()

# => { SnowWhites: 1, Dwarves: 7 }


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

