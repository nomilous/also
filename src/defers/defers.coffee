{defer} = require 'when'

module.exports = (fn) -> (args...) -> 

    doing = defer()

    try 

        fn.apply this, [doing].concat args
    
    catch error
        
        doing.reject error

    doing.promise
