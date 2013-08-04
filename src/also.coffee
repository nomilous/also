# 
# !!Experimental!!
# ================
#

Also = (args...) -> 
    
    #
    # Also( ..., moduleFactoryFn )
    # ----------------------------
    # 
    # ### moduleFactoryFn
    # 
    # A function that is expected to return a module definition. It will be called immediately
    # and provided a context root.
    # 

    [ futureArgs... , moduleFactoryFn ] = args

    moduleFactoryFn context: {}

#
# Exported utility decorators
# ===========================
#

Object.defineProperty Also, exported, enumerable: true, value: require "./#{ exported }" for exported in [

    #
    # Also.validate.*
    # ---------------
    # 
    # Validation decorators.
    #
    # TODO
    # 

    'validate'

    #
    # Also.inject.*
    # -------------
    # 
    # Injection decorators. 
    #
    # TODO
    # 

    'inject'

    #
    # Also.deferral.*
    # ---------------
    # 
    # Deferral decorators.
    # 
    # TODO
    #

    'deferral'

    #
    # TODO
    #

    'schedule'
    'match'
    'util'

]


module.exports = Also

# module.exports =
#     util:     require './util'
#     match:    require './match'
#     inject:   require './inject'
#     schedule: require './schedule'
#     deferral: require './deferral'
#     validate: require './validate'

