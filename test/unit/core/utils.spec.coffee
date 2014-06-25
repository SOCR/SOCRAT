'use strict'

# jasmine specs for utils

describe 'utils module', ->

  $injector = angular.injector ['app_utils']

  describe 'provides service utils', ->

    utils = $injector.get 'utils'

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

    describe 'runSeries function', ->

      it 'should run an array of functions', () ->
        cb1 = (next) ->
          next null, 'one', false
        cb2 = (next) ->
          next null, 'two'
        cb3 = (next) ->
          next null, 'three'

        utils.runSeries [cb1, cb2, cb3], (err, res) ->
          (expect err?).toEqual false
          (expect res).toEqual [['one', false],'two', 'three']

      it 'should not break if the array is empty or not defined', () ->
        utils.runSeries [], (err, res) =>
          (expect err?).toBe false
          utils.runSeries undefined, (err, res) ->
            (expect err?).toBe false

      it "shouldn't stop on errors if the 'force' option is 'true'", (done) ->
        cb1 = (next) -> next null, 'one', 2
        cb2 = (next) -> thisMethodDoesNotExist()
        cb3 = (next) -> next null, 'three'
        cb4 = (next) -> next (new Error 'fake'), 'four'
        fini = (err, res) ->
          (expect err?).toEqual true
          (expect res).toEqual [['one', 2], undefined, 'three', undefined]
          done()
        utils.runSeries [cb1, cb2, cb3, cb4], fini, true

    describe 'runWaterfall function', ->

      it 'should run an array of functions and passes the results', (done) ->
        cb1 = (next) -> next null, 'one', 2
        cb2 = (a, b, next) ->
          (expect a).toEqual 'one'
          (expect b).toEqual 2
          setTimeout (-> next null, 3), 0
        cb3 = (d, next) ->
          (expect d).toEqual 3
          next null, 'finished :-)', 'yeah'
        utils.runWaterfall [cb1, cb2, cb3], (err, res1, res2) ->
          (expect err?).toBe false
          (expect res1).toEqual 'finished :-)'
          (expect res2).toEqual 'yeah'
          done()

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

