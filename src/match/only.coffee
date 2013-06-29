match = -> 
    
    console.log match: arguments
    false

module.exports = (Preparator, decoratedFn) -> 
    
    -> 

        return unless Preparator.if?
        return unless Preparator.if.match?
        return unless match Preparator.if.match, arguments

        decoratedFn.apply self, arguments
