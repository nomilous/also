{lstatSync} = require 'fs'
{dirname}   = require 'path'

module.exports = root = (parent = module.parent) -> 

    #
    # recurse to the root script in the module tree 
    #

    return root parent.parent if parent.parent?
    # console.log require.cache[  process.argv[1]  ]
    # 


    for path in parent.paths

        try
            
            if lstatSync( path ).isDirectory()

                home = dirname path

                # continue unless parent.filename.indexOf( home ) == 0

                return {

                    #
                    # home - refers to the installed location 
                    #        of the repo clone from where the
                    #        process is running
                    # 
                    #        ( hopefully always... )
                    # 
                    #

                    home: home

                }
