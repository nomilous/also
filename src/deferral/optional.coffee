module.exports = (args...) -> 
    
    opts = args[0]
    fn   = args[-1..][0]
    
    throw new Error 'expected function as last arg' unless typeof fn == 'function' 

    -> 

        defers = if typeof opts.if == 'function' then opts.if()
        fn()
