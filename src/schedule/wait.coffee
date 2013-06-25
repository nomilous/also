#
# TODO: timeout: 
#

wait = (Preparator, decoratedFn) -> 

    if typeof Preparator == 'function' and not decoratedFn?

        decoratedFn = Preparator

    unless Preparator.until?

        #
        # no until(), call immediately
        #

        return -> decoratedFn.apply this, arguments 

    -> 

        if Preparator.until() == true

            #
            # until is already true
            #
            
            return decoratedFn.apply this, arguments 


        interval = setInterval ( ->

            try if Preparator.until() == true

                clearInterval interval
                decoratedFn.apply this, arguments

            catch error

                clearInterval interval

        ), Preparator.retry || 10

module.exports = wait

