argsOf         = require('./util').argsOf 

module.exports = 

    
    #
    # inject.flat signatureFn, (arg,uments) ->
    # -------------------------------------------
    # 
    # * First calls signatureFn with the arg,ument 
    #   of the second function.
    # 
    # * Then the second function is called with the
    #   returns of signatureFn injected as the args
    # 

    flat: (signatureFn, fn) -> ->

        fn.apply null, signatureFn argsOf fn

