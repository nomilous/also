uuid = require 'node-uuid'

module.exports = 

    argsOf: (fn) -> 

        try fn.toString().match( 

            /function\s*\((.*)\)/ 

        )[1].replace(

            /\s/g,''

        ).split(',').filter( (arg) -> 

            true unless arg == ''

        )

        catch error

            []

    uuid: uuid.v1
