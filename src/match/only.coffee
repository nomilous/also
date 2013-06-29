matchAll = (matcher, obj) -> 

    shouldCount = 0
    doesCount   = 0
    
    for key of matcher

        doesCount++ if obj[key]? and obj[key] == matcher[key]
        shouldCount++

    shouldCount == doesCount

module.exports = (Preparator, decoratedFn) -> 
    
    -> 

        return unless Preparator.if?
        return unless Preparator.if.matchAll?
        return unless matchAll Preparator.if.matchAll, arguments[0]

        decoratedFn.apply this, arguments
