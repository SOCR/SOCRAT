'use strict'

# jasmine specs for utils

describe 'utils module', ->

  $injector = angular.injector ['app_utils']

  describe 'provides service utils', ->

    utils = $injector.get 'utils'

    describe "runParallel", ->

      it "runs an array of functions", (done) ->

        foo =
          cb1: ->
          cb2: ->
          cb3: ->

        spyOn foo, 'cb1'
        spyOn foo, 'cb2'
        spyOn foo, 'cb3'

        cb1 = (next) ->
          (expect foo.cb1).not.toHaveBeenCalled()
          (expect foo.cb2).not.toHaveBeenCalled()
          (expect foo.cb3).not.toHaveBeenCalled()
          setTimeout (->
            (expect foo.cb1).not.toHaveBeenCalled()
            (expect foo.cb2).toHaveBeenCalled()
            (expect foo.cb3).toHaveBeenCalled()
            foo.cb1()
            next null, "one", false
          ), 30

        cb2 = (next) ->
          (expect foo.cb1).not.toHaveBeenCalled()
          (expect foo.cb2).not.toHaveBeenCalled()
          (expect foo.cb3).not.toHaveBeenCalled()
          setTimeout (->
            (expect foo.cb1).not.toHaveBeenCalled()
            (expect foo.cb2).not.toHaveBeenCalled()
            (expect foo.cb3).toHaveBeenCalled()
            foo.cb2()
            next null, "two"
          ), 0

        cb3 = (next) ->
          (expect foo.cb1).not.toHaveBeenCalled()
          (expect foo.cb2).not.toHaveBeenCalled()
          (expect foo.cb3).not.toHaveBeenCalled()
          foo.cb3()
          next null, "three"

        (expect utils.runParallel).toBeDefined()
        utils.runParallel [cb1, cb2, cb3], (err, res) ->
          (expect err).toBeNull()
          (expect res[0]).toEqual ["one", false]
          (expect res[1]).toEqual "two"
          (expect res[2]).toEqual "three"
          done()

      it "does not break if the array is empty or not defined", (done) ->
        utils.runParallel [], (err, res) =>
          (expect err?).toBeFalsy()
          utils.runParallel undefined, (err, res) ->
            (expect err?).toBeFalsy()
            done()

      it "doesn't stop on errors if the 'force' option is 'true'", (done) ->
        cb1 = (next) -> next null, "one", 2
        cb2 = (next) -> thisMethodDoesNotExist()
        cb3 = (next) -> next null, "three"
        cb4 = (next) -> next (new Error "fake"), "four"
        fini = (err, res) ->
          (expect err).toBeDefined()
          (expect res[0]).toEqual ["one", 2]
          (expect res[1]).not.toBeDefined()
          (expect res[2]).toEqual "three"
          (expect res[3]).not.toBeDefined()
          done()
        utils.runParallel [cb1, cb2, cb3, cb4], fini, true

    describe "runSeries", ->

      it "runs an array of functions", (done) ->

        foo =
          cb1: ->
          cb2: ->
          cb3: ->

        spyOn foo, 'cb1'
        spyOn foo, 'cb2'
        spyOn foo, 'cb3'

        cb1 = (next) ->
          (expect foo.cb1).not.toHaveBeenCalled()
          (expect foo.cb2).not.toHaveBeenCalled()
          (expect foo.cb3).not.toHaveBeenCalled()
          setTimeout (->
            (expect foo.cb1).not.toHaveBeenCalled()
            (expect foo.cb2).not.toHaveBeenCalled()
            (expect foo.cb3).not.toHaveBeenCalled()
            foo.cb1()
            next null, "one", false
          ), 30

        cb2 = (next) ->
          (expect foo.cb1).toHaveBeenCalled()
          (expect foo.cb2).not.toHaveBeenCalled()
          (expect foo.cb3).not.toHaveBeenCalled()
          setTimeout (->
            (expect foo.cb1).toHaveBeenCalled()
            (expect foo.cb2).not.toHaveBeenCalled()
            (expect foo.cb3).not.toHaveBeenCalled()
            foo.cb2()
            next null, "two"
          ), 0

        cb3 = (next) ->
          (expect foo.cb1).toHaveBeenCalled()
          (expect foo.cb2).toHaveBeenCalled()
          (expect foo.cb3).not.toHaveBeenCalled()
          foo.cb3()
          next null, "three"

        (expect utils.runSeries).toBeDefined()
        utils.runSeries [cb1, cb2, cb3], (err, res) ->
          (expect err).toBeNull()
          (expect res.hasOwnProperty '-1').toBeFalsy()
          (expect res[0]).toEqual ["one", false]
          (expect res[1]).toEqual "two"
          (expect res[2]).toEqual "three"
          done()

      it "does not break if the array is empty or not defined", (done) ->
        utils.runSeries [], (err, res) =>
          (expect err).toBeNull()
          utils.runSeries undefined, (err, res) ->
            (expect err).toBeNull()
            done()

      it "stops on errors", (done) ->
        cb1 = (next) -> next null, "one", 2
        cb2 = (next) -> thisMethodDoesNotExist()
        cb3 = (next) -> next null, "three"
        fini = (err, res) ->
          (expect err).toBeDefined()
          (expect res[0]).toEqual ["one", 2]
          (expect res[1]).not.toBeDefined()
          (expect res[2]).not.toBeDefined()
          done()
        utils.runSeries [cb1, cb2, cb3], fini

      it "doesn't stop on errors if the 'force' option is 'true'", (done) ->
        cb1 = (next) -> next null, "one", 2
        cb2 = (next) -> thisMethodDoesNotExist()
        cb3 = (next) -> next null, "three"
        cb4 = (next) -> next (new Error "fake"), "four"
        fini = (err, res) ->
          (expect err).toBeDefined()
          (expect res[0]).toEqual ["one", 2]
          (expect res[1]).not.toBeDefined()
          (expect res[2]).toEqual "three"
          (expect res[3]).not.toBeDefined()
          done()
        utils.runSeries [cb1, cb2, cb3, cb4], fini, true

    describe "runWaterfall", ->

      it "runs an array of functions and passes the results", (done) ->
        cb1 = (next) -> next null, "one", 2
        cb2 = (a, b, next) ->
          (expect a).toEqual "one"
          (expect b).toEqual 2
          setTimeout (-> next null, 3), 0
        cb3 = (d, next) ->
          (expect d).toEqual 3
          next null, "two", "three"
        utils.runWaterfall [cb1, cb2, cb3], (err, res1, res2) ->
          (expect err).toBeNull()
          (expect res1).toEqual "two"
          (expect res2).toEqual "three"
          done()

    describe 'getArgumentNames function', ->

      it 'should return an array of argument names', ->
        fn = (a, b, c, d) ->
        (expect utils.getArgumentNames fn).toEqual ['a', 'b', 'c', 'd']
        (expect utils.getArgumentNames ->).toEqual []

      it 'shouldn\' tbreak if the function is not defined', ->
        (expect utils.getArgumentNames undefined).toEqual []

    describe 'installFromTo function', ->

      it 'copies all properties of first object to second', ->
        obj1 = name: 'object', id: 1
        obj2 = ownProperty: 'prop'
        utils.installFromTo obj1, obj2
        (expect Object.keys(obj2).length).toEqual 3
        (expect obj2.name).toBeDefined()
        (expect obj2.id).toBeDefined()

    describe 'getGuid function', ->

      it 'should return unique id every time', ->
        (expect utils.getGuid()).not.toEqual(utils.getGuid())

    describe 'doForAll function', ->

      it 'runs a functions for each argument within an array ', (done) ->
        result = []
        fn = (arg, next) -> result.push arg; next()

        utils.doForAll ['a', 2, false], fn, (err) ->
          (expect err?).toBe false
          (expect result).toEqual ['a', 2, false]
          done()

      it 'does not break if the array is empty or not defined', () ->
        fn = (arg, next) -> next()
        utils.doForAll [], fn, (err) =>
          (expect err?).toBe false
          utils.doForAll undefined, fn, (err) ->
            (expect err?).toBe false