require('nez').realize 'Also', (also, test, it) -> 

    # async = also.inject.async

    # it 'works', (done) -> 

    #     gitme = async

    #         #
    #         # beforeAll is run once, and before the
    #         # function being decorated
    #         #

    #         beforeAll: (done, context) -> 

    #             #
    #             # signature contains the args of the 
    #             # function being decorated
    #             #

    #             name    = context.signature[0]
    #             body    = ''
    #             https   = require 'https'
    #             options = 

    #                 hostname: 'api.github.com'
    #                 port:     443
    #                 path:     "/users/#{  name  }"
    #                 method:   'GET'
    #                 headers:  'User-Agent': 'Mozilla/5.0'

    #             req = https.request options, (res) -> 

    #                 res.on 'data', (data) -> body += data.toString()
    #                 res.on 'end', -> 

    #                     #
    #                     # elements of context.first will be injected
    #                     # as args into the feunction being decorated
    #                     #

    #                     context.first.push JSON.parse body
    #                     done()

    #             req.end()

    #         #
    #         # the function being decorated
    #         #

    #         (nomilous) -> 

    #             console.log nomilous.gravatar_id


    #     #
    #     # call it
    #     # 

    #     gitme()
    #     gitme()
    #     gitme()
    #     gitme()




    # 