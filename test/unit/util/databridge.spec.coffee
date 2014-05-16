   describe "app_utils module", ->

           #variables.

               beforeEach ->
                   module "app_utils"

                                   describe "databridge service", ->

                                               it "first unit test case", ->
                                                               inject (app_utils_databridge)->
                                                                                   expect(true).toBe(true)


