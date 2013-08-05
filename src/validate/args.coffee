{argsOf} = require '../util'

module.exports = (args...) -> 

    #
    # splats extract the args
    # and [something interesting](http://learnyousomeerlang.com/starting-out-for-real#list-comprehensions)
    # 

    [remains..., decoratedFn] = args
    [Preparator, remains... ] = remains

    Preparator   ||= {}

    address   = Preparator.$address || ''
    signature = argsOf decoratedFn

    return -> 

        #
        # decoratedFn has been called, validate the args
        # 
        # MESSY: needs work, not my cup of tea...
        # 
        
        missing = ( for argName of Preparator

            continue if argName.match /^\$/ 
            position = signature.indexOf argName
            throw new Error "#{address}(#{signature}) expects #{argName}" unless arguments[position]
            (
                for field of Preparator[argName]
                    continue if field.match /^\$/ 
                    continue if arguments[position][field]?
                    continue if Preparator[argName][field].$required? and not Preparator[argName][field].$required   
                    field 

            ).map( (f) -> "#{argName}.#{f}" ).join ', '

        ).filter( (f) -> [e] = f; e?  ).join ' and '

        if missing then throw new Error "#{address}(#{signature}) expects #{missing}"
        decoratedFn.apply this, arguments
