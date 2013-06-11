module.exports = 

    argsOf: (fn) -> 

        try fn.toString().match( 

            /function\s*\((.*)\)/ 

        )[1].replace(

            /\s/,''

        ).split(',').filter( (arg) -> 

            true unless arg == ''

        )

        catch error

            []

