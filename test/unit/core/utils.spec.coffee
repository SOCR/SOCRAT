'use strict'

# jasmine specs for utils

describe 'utils module', ->

  $injector = angular.injector ['app.utils']

  describe 'provides service utils', ->

    utils = $injector.get 'utils'

    describe 'getArgumentNames function', ->

      it 'returns an array of argument names', ->
        fn = (a, b, c, d) ->
        (expect utils.getArgumentNames fn).toEqual ['a', 'b', 'c', 'd']
        (expect utils.getArgumentNames ->).toEqual []

      it 'does not break if the function is not defined', ->
        (expect utils.getArgumentNames undefined).toEqual []

    describe 'clone function', ->

      it 'returns a clone of array', ->
        arr = ['a', 'b', 'c', 'd']
        (expect utils.clone arr).toEqual arr

      it 'returns a clone of object', ->
        obj = name: 'object', id: 1
        (expect utils.clone obj).toEqual obj

    describe 'getGuid function', ->

      it 'should return unique id every time', ->
        (expect utils.getGuid()).not.toEqual(utils.getGuid())
