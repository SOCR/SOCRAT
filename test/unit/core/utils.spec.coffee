'use strict'

# jasmine specs for utils

describe 'utils module', ->

  $injector = angular.injector ['app.utils']

  describe 'provides service utils', ->

    utils = $injector.get 'utils'

    describe 'getArgumentNames function', ->

      it 'should return an array of argument names', ->
        fn = (a, b, c, d) ->
        (expect utils.getArgumentNames fn).toEqual ['a', 'b', 'c', 'd']
        (expect utils.getArgumentNames ->).toEqual []

      it 'shouldn\' tbreak if the function is not defined', ->
        (expect utils.getArgumentNames undefined).toEqual []

    describe 'clone function', ->

      it 'should return a clone of array', ->
        arr = ['a', 'b', 'c', 'd']
        (expect utils.clone arr).toEqual arr

      it 'returns a clone of object', ->
        obj = name: 'object', id: 1
        (expect utils.clone obj).toEqual obj

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
