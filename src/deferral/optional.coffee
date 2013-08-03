module.exports = (args...) -> 

    fn = args[-1..][0]

    unless typeof fn == 'function' 

        throw new Error 'expected function as last arg'

    ->