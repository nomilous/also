module.exports = 

    
    #
    # injectors.flat singatureFn, (arg,uments) ->
    # -------------------------------------------
    # 
    # * First calls signatureFn with the arg,ument 
    #   of the second function.
    # 
    # * Then the second function is called with the
    #   returns of signatureFn injected as the args
    # 

    flat: (singatureFn, fn) -> ->

