argsOf = require('./util').argsOf 

    
# 
# Syncronous Injection
# --------------------
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

    fn.apply null, signatureFn argsOf fn

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

    
    signatureFn argsOf(fn)[1..], (error, result) -> 

        fn.apply null, [error].concat result




