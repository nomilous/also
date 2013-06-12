argsOf = require('./util').argsOf 

    
# 
# Syncronous Injection
# ====================
# 
# Each call made to the decorated function is first
# passed through the signature function with an 
# array of strings generated from the argument 
# names of the decorated function.
# 
# The returned array from the signature function
# is used to populate the arguments of the call
# to the decorated function.
# 

exports.sync = (signatureFn, fn) -> ->

    context  = undefined
    injected = 

        if typeof signatureFn == 'function'

            #
            # inject the return of signatureFn
            #

            signatureFn argsOf fn

        else if signatureFn instanceof Array

            #
            # arrays are spread across the first 
            # arguments
            #

            signatureFn

        else if signatureFn instanceof Object

            #
            # mark as configured injection
            #

            context = config: signatureFn

        else 

            #
            # number or string
            #

            [signatureFn]

    unless context? 

        #
        # handle unconfigured injection
        # 
        # * append external arguments and call all into fn()
        #

        injected.push arg for arg in arguments

        #
        # inject.sync returns fn result
        #

        return fn.apply null, injected


    #
    # TODO: handle configured sync injection
    #

    fn.apply null, null
        




#
# Asyncronous Injection
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
