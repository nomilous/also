argsOf = require('../util').argsOf 

                                    #
                                    # col37 - (Preparator as Object)
                                    #
    
# 
# Synchronous Injection
# =====================
# 
# * Each call made to the decoratedFn is first passed through a synchronous preparation 
#   process to assign / augment the arguments it will be called with.
# 


module.exports = (Preparator, decoratedFn) -> 

    do (

        #
        # Context
        # ------- 
        # 
        # * A context (as function) is enclosed around the `decoratedFn`
        #

        context    = -> 
        configured = false

    ) -> 

        #
        # * The context has properties.
        #

        context.preparator = Preparator
        context.signature  = argsOf decoratedFn
        context.first      = []
        context.last       = []


        if context.preparator.beforeAll?
            context.preparator.beforeAll context 


        return ->  

                    #
                    # * A function is returned. (It pretends to be the `decoratedFn`)
                    # 
                    # TODO
                    # ----
                    # 
                    # * Consider taking the context out the back door. 
                    #   (  As a property of this returned function  )
                    # 

                                # 
            context.inject =    # * `inject` is an array that is used to assemble the arguments 
                                #   to be passed to the `decoratedFn` when called.
                                #
             

                if typeof context.preparator == 'function'

                        # 
                        # * For the case of `Preparator` as a function, `injected` is 
                        #   assigned the return value of a call to `Preparator()` with
                        #   an array of argument names extracted from the definition 
                        #   of the `decoratedFn`
                        #
                        # 

                    context.preparator context.signature


                else if context.preparator instanceof Array

                        #
                        # * For the case of `Preparator` as an Array, `injected` is 
                        #   assigned that array. 
                        # 

                    context.preparator


                else if context.preparator instanceof Object

                        #
                        # * For the case of `Preparator` as an Object, `injected` is
                        #   assigned an empty array.
                        # 

                    configured = true
                    []


                else 

                        #
                        # * For the case of `Preparator` as a basic number or string, 
                        #   it becomes the only element (so far), to be injected. 
                        #

                    [context.preparator]



            unless configured

                #
                # Handle unconfigured injection
                # -----------------------------
                # 
                # * External arguments, from calls to the `decoratedFn` are appended into
                #   the injection array.
                #

                context.inject.push arg for arg in arguments

                #
                # * And a call is made to the `decoratedFn` with the `injected` array 
                #   applied as argumnets. 
            # 
                # 
                #       argumnet |noun| ~ like a dream catcher, aften found
                #                         shortly after a why { ;;; } block
                # 
                #                       ~ incompatable with how {  } blocks
                #

                return decoratedFn.apply null, context.first.concat context.inject

                # 
                # TODO 
                # ----
                # 
                # * null? 
                # * Perhaps external object (this) can be maintaind. 
                # * Because personally: 
                # 
                # 
                #                 
                #          ... i get mildly annoyed when my This
                # 
                #                   gets Thosed,
                # 
                #                        before i could That it! ...
                # 
                #                                     - nomilous
                # 
                #
                # 
                # * Maybe it already is? 'These' still confuze me... 
                # 


            context.preparator.beforeEach context if context.preparator.beforeEach? 

            context.inject.push arg for arg in arguments

            result = decoratedFn.apply null, context.first.concat( context.inject ).concat context.last

            context.preparator.afterEach context, result if context.preparator.afterEach?

            return result
