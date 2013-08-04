module.exports = (args...) -> 

    [remains..., decoratedFn] = args

    return -> 

        decoratedFn.apply this, arguments

