argsOf = require('../util').argsOf 

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

module.exports = (signatureFn, fn) -> ->

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
