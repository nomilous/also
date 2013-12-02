#
# Exported utility decorators
# ===========================
# 


localExports = {

    validate: {}
    inject:   {}

    # 
    # proxiing some functionality from when 
    # for convenience
    # 

    deferred: {}
    sequence: {}
    pipeline: {}
    parallel: {}

    enclose:  {}
    schedule: {}
    match:    {}
    util:     {}
    root:     {}

}

nodeExport = (ontoObject) -> 

    Object.defineProperty( 

        ontoObject, 
        submoduleName, 
        enumerable: true, 
        value: require "./#{ submoduleName }" 

    ) for submoduleName of localExports

    return ontoObject


Also = (args...) -> 
    
    #
    # Also( exporter, ..., moduleFactoryFn )
    # ----------------------------
    # 
    # ### moduleFactoryFn
    # 
    # A function that is expected to return a module definition. It will be called immediately
    # and provided with a context root.
    # 

    [ exporter, futureArgs... , moduleFactoryFn ] = args

    root = context: {}

    nodeExport root

    for objectName of (definitions = moduleFactoryFn root)

        exporter[objectName] = definitions[objectName]


module.exports = nodeExport Also
