#
# Exported utility decorators
# ===========================
# 


localExports = {

    validate: {}
    inject:   {}
    deferral: {}
    schedule: {}
    match:    {}
    util:     {}

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
    # and provided a context root.
    # 

    [ exporter, futureArgs... , moduleFactoryFn ] = args

    root = context: {}

    if process? and process.title == 'node' then nodeExport root

    for objectName of (definitions = moduleFactoryFn root)

        exporter[objectName] = definitions[objectName]



if process? and process.title == 'node' then module.exports = nodeExport Also
