"use strict"

describe "getData", ->
# ##
#  Creating empty modules which the app.getData is dependent on i.e.
#  ngGrid and ui.bootstrap.
# ##
  angular.module "ngGrid",[]
  angular.module "ui.bootstrap",[]

# Create mock module and overriding services
  angular.module('app_mocks_get_data', [])

    .service 'app_analysis_getData_manager',['sb',(sb)->
      getSb:()->
        sb
    ]
    .service 'sb', ->
      @events = []
      @publish = (event) =>
          console.log 'mock pubSub: published'
          console.log event
          console.log @events[0]?.listener
          result = (item.listener(item.msg) for item in @events when item.msg is event.msg)
      @subscribe = (event) =>
        @events.push event
        console.log 'mock pubSub: subscribed'
        console.log @events
      @unsubscribe = ->
      publish: @publish
      subscribe: @subscribe
      unsubscribe: @unsubscribe
    .service "$stateParams", ->
      projectId:'manhattan'
      forkId:'evil'

  beforeEach ->
    module "app_analysis_getData"
    module "app_mocks_get_data"

  describe "showState", ->
####
#  ShowState is service for similar to accordion. For keeping only value as true
#  at all times.
####
    it "should return false if input obj is not defined.", ->
      inject (showState)->
        ss = new showStateService()
        expect(Object.keys(ss).length).toBe(0)

    it "should create showState object to supplied scope.", ->
      inject (showState,$rootScope)->
        scope = $rootScope.$new()
        ss = new showStateService(["div1","div2"],scope)
        expect(scope.showStateService).toBeDefined()
        expect(typeof scope.showStateService).toEqual("object")
        expect(Object.keys(scope.showStateService).length).toEqual(2)

    it "sets supplied showState[index] to false, and everything else to true.", ->
      inject (showState,$rootScope) ->
        scope = $rootScope.$new()
        ss = new showStateService ["div1","div2"],scope
        ss.set("div1")
        expect(scope.showStateService["div1"]).toBeFalsy()
        expect(scope.showStateService["div2"]).toBeTruthy()


  describe "app_analysis_getData_jsonParser", ->
    beforeEach inject ($injector) ->
      $httpBackend = $injector.get('$httpBackend')
      $httpBackend.expect("JSONP","test.json")
      .respond('[{"page":1,"pages":13038,"per_page":"1","total":13038}]')

    it "should return false if input is empty", ->

    it "should return object when worldbank url is passed", ->
      inject (app_analysis_getData_jsonParser) ->
        opts =
          url:"test.json"
          type:"worldBank"
        obj = app_analysis_getData_jsonParser opts
        #returns a promise object


  describe "app_analysis_getData_inputCache", ->
    beforeEach ->
    it "should return false if input data is empty", ->
      inject (app_analysis_getData_inputCache) ->
        expect(app_analysis_getData_inputCache.set null).toBeFalsy()
        expect(app_analysis_getData_inputCache.set []).toBeTruthy()
        expect(app_analysis_getData_inputCache.set [1,2,4]).toBeTruthy()

    it "should publish message if data not updated within 4 seconds of first update", ()->
      inject ($timeout,sb,app_analysis_getData_inputCache) ->
        foo =
          cb : ->
        spyOn(foo,"cb")
        sb.subscribe
          msg:'handsontable updated'
          listener:foo.cb
          msgScope:['getData']
        app_analysis_getData_inputCache.set [1,2,3]
        $timeout.flush()
        expect(foo.cb).toHaveBeenCalled()

    #it "should reset timer if data updated within 4 seconds", ->
      #inject ($stateParams,app_analysis_getData_inputCache) ->
        #expect(app_analysis_getData_inputCache.set null).toBeFalsy()
        #expect(app_analysis_getData_inputCache.set []).toBeFalsy()
