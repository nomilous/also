also
====

decorators

### 0.0.3 (unstable)


synchronous example with ducks
------------------------------

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


synchronous example with node modules
-------------------------------------

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


asynchronous example with github user
-------------------------------------

```coffee

    gitme = require('also').inject.async

        #
        # beforeAll is run once, and before the
        # function being decorated
        #

        beforeAll: (done, context) -> 

            #
            # signature contains the args of the 
            # function being decorated
            #

            name    = context.signature[0]
            body    = ''
            https   = require 'https'
            options = 

                hostname: 'api.github.com'
                port:     443
                path:     "/users/#{  name  }"
                method:   'GET'
                headers:  'User-Agent': 'Mozilla/5.0'

            req = https.request options, (res) -> 

                res.on 'data', (data) -> body += data.toString()
                res.on 'end', -> 

                    #
                    # elements of context.first will be injected
                    # as args into the function being decorated,
                    # at calltime
                    #

                    context.first.push JSON.parse body
                    done()

            req.end()

        #
        # the function being decorated
        #

        (nomilous) -> 

            console.log nomilous.gravatar_id


    #
    # call it (a few times)
    # 

    gitme()
    gitme()
    gitme()
    gitme()



```
