'use strict'

# jasmine specs for Sandbox

describe 'Sandbox module', ->

 $injector = angular.injector ['app_sandbox']

 describe 'provides service sandbox', ->
   Sandbox = $injector.get 'Sandbox'

   describe 'constructor', ->

     it 'returns an object', ->
       (expect typeof new Sandbox {}, 'myId').toEqual 'object'
       (expect new Sandbox {}, 'myId').not.toBe(new Sandbox {}, 'myId')

     it 'throws an error if the core was not defined', ->
       (expect -> new Sandbox null, 'an id').toThrow new TypeError "core was not defined"

     it 'throws an error if no id was specified', ->
       (expect -> new Sandbox {}).toThrow new TypeError 'no id was specified'

     it 'throws an error if id is not a string', ->
       (expect -> new Sandbox {},{}).toThrow new TypeError 'id is not a string'

     it 'stores the instance id in "instanceID"', ->
       sandbox = new Sandbox {}, 'myId'
       (expect 'myId').toEqual sandbox.instanceId

     it 'has an empty object if no options were specified', ->
       (expect (new Sandbox {}, 'myId').options).toEqual {}

     it 'stores the option object', ->
       myOpts = { settingOne: 'its boring' }
       (expect (new Sandbox {}, 'myId', myOpts).options).toEqual myOpts
