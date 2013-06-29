matchAll = (matcher, obj) -> 

    shouldCount = 0
    doesCount   = 0
    
    for key of matcher

        shouldCount++

        if matcher[key] instanceof Array

            for value in matcher[key]

                 doesCount++ if obj[key] == value

        else

            doesCount++ if obj[key]? and obj[key] == matcher[key]

        

    shouldCount == doesCount

module.exports = (Preparator, decoratedFn) -> 
    
    -> 

        return unless Preparator.if?
        return unless Preparator.if.matchAll?
        return unless matchAll Preparator.if.matchAll, arguments[0]

        decoratedFn.apply this, arguments
