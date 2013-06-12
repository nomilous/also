argsOf = require('./util').argsOf 

    
# 
# Synchronous Injection
# =====================
# 
# * Each call made to the decoratedFn is first passed through a synchronous preparation 
#   process to assign / augment the arguments it will be called with.
# 


exports.sync = (Preparator, decoratedFn) -> 

    do (

        context    = preparator: Preparator
        configured = false

    ) -> 

        #
        # * A `context` is enclosed onto the decorator scope to enable carrying a common 
        #   state store shared across all calls that may be made to the `decoratedFn`.
        # 
        #
                                    #
                                    # Assuming `Preparator` was a config Object
                                    # -----------------------------------------
                                    #  
                                    # * Make the call to beforeAll()
                                    # 
                                    # * This call, being in the factory component of the
                                    #   decorator, only happens once.
                                    # 
        try                         # 

            context.preparator.beforeAll()


        #
        # * A function is returned. (It pretends to be the `decoratedFn`)
        # 
        # TODO
        # ----
        # 
        # * Consider taking the context out the back door. 
        #   (  As a property of this returned function  )
        # 

        return ->  

                        # 
            injected =  # * `injected` is an array that is used to assemble the arguments 
                        #   to be passed to the `decoratedFn` when called.
                        #
             

                if typeof Preparator == 'function'

                        # 
                        # * For the case of `Preparator` as a function, `injected` is 
                        #   assigned the return value of a call to `Preparator()` with
                        #   an array of argument names extracted from the definition 
                        #   of the `decoratedFn`
                        #
                        # 

                    Preparator argsOf decoratedFn


                else if Preparator instanceof Array

                        #
                        # * For the case of `Preparator` as an Array, `injected` is 
                        #   assigned that array. 
                        # 

                    Preparator


                else if Preparator instanceof Object

                        #
                        # * For the case of `Preparator` as an Object, `injected` is
                        #   assigned an empty array.
                        # 

                    configured = true
                    []


                else 

                        #
                        # * For the case of `Preparator` as a basic number or string, 
                        #   it becomes the only element (so far), to be injected. 
                        #

                    [Preparator]



            unless configured

                #
                # Handle unconfigured injection
                # -----------------------------
                # 
                # * External arguments, from calls to the `decoratedFn` are appended into
                #   the injection array.
                #

                injected.push arg for arg in arguments

                #
                # * And a call is made to the `decoratedFn` with the `injected` array 
                #   applied as argumnets. 
                # 
                # 
                #       argumnet |noun| ~ like a dream catcher, aften found
                #                         shortly after a why { ;;; } block
                # 
                #                       ~ incompatable with how {  } blocks
                #

                return decoratedFn.apply null, injected

                # 
                # TODO 
                # ----
                # 
                # * null? 
                # * Perhaps external object (this) can be maintaind. 
                # * Because personally: 
                # 
                # 
                #                 
                #          ... i get mildly annoyed when my This
                # 
                #                   gets Thosed,
                # 
                #                        before i could That it! ...
                # 
                #                                     - nomilous
                # 
                #
                # 
                # * Maybe it already is? 'These' still confuze me... 
                # 

                

           

            #
            # Handle configured sync injection
            #

            decoratedFn.apply null, null
            


#
# Asynchronous Injection
# ---------------------
# 
# The signature function will be called with a node
# style (error, result) callback.
# 
# This allows the result of an asyncronous callback
# to populate the injection.
# 

exports.async = (signatureFn, fn) -> ->

    context   = undefined
    original  = 
        for arg in arguments
            arg
    
    if typeof signatureFn == 'function'

        #
        # inject into fn() via async call to signatureFn
        #

        signatureFn argsOf(fn)[1..], (error, result) -> 

            fn.apply null, [error].concat( result ).concat original


    else if signatureFn instanceof Array

        #
        # arrays are spread across the first 
        # arguments
        #

        fn.apply null, signatureFn.concat original

    else if signatureFn instanceof Object

        #
        # mark as configured injection
        #

        context = config: signatureFn

    else 

        #
        # a string or number
        #

        fn.apply null, [signatureFn].concat original
    

    unless context?

        #
        # TODO: decide what inject.async returns
        #

        return

    #
    # TODO: handle configured async injection
    #

    fn.apply null, null
