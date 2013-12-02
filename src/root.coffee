{lstatSync} = require 'fs'
{dirname}   = require 'path'

module.exports = root = (parent = module.parent) -> 

    #
    # recurse to the root script in the module tree 
    #

    return root parent.parent if parent.parent?
    # console.log require.cache[  process.argv[1]  ]
    # 


    #
    # first match on root module's reversed paths array 
    # that is a node_modules directory and is present is 
    # the node_modules of the process ""home""
    #

    paths  = parent.paths
    length = paths.length

    while path = paths[ --length ]

        if path.match /node_modules$/

            try 

                if lstatSync( path ).isDirectory()

                    return {

                        #
                        # home - refers to the installed location 
                        #        of the repo clone from where the
                        #        process is running
                        # 
                        #        ( hopefully always... )
                        # 
                        #

                        home: dirname path

                    }
