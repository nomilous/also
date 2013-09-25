module.exports = (superFn, fn) -> (args...) -> 

    superclass = 

        if typeof superFn isnt 'function' then superFn
        else superFn.apply this, args

    instance = fn.apply this, [superclass].concat args

    return instance
