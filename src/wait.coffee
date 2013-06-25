wait = (Preparator, decoratedFn) -> 

    if typeof Preparator == 'function' and not decoratedFn?

        decoratedFn = Preparator

    unless Preparator.until?

        #
        # no until(), call immediately
        #

        return -> decoratedFn.apply this, arguments 

    -> 

        #
        # until is already true
        #

        if Preparator.until() == true
            
            return decoratedFn.apply this, arguments 





module.exports = wait

