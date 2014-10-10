"use strict"

describe "getData", ->
# ##
#  Creating empty modules which the app.getData is dependent on i.e.
#  ngGrid and ui.bootstrap.
# ##
  angular.module "ngGrid",[]
  angular.module "ui.bootstrap",[]

# Create mock module and overriding services
  angular.module('app_mocks', []) 

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
      forkId:12 

  beforeEach ->
    module "app_analysis_getData"
	module "app_mocks"

  describe "showState", ->
####
#  ShowState is service for similar to accordion. For keeping only value as true
#  at all times.
####
    it "should return false if input obj is not defined.", ->
      inject (showState)->
        ss = new showState()
        expect(Object.keys(ss).length).toBe(0)

    it "should create showState object to supplied scope.", ->
      inject (showState,$rootScope)->
        scope = $rootScope.$new()
        ss = new showState(["div1","div2"],scope)
        expect(scope.showState).toBeDefined()
        expect(typeof scope.showState).toEqual("object")
        expect(Object.keys(scope.showState).length).toEqual(2)

    it "sets supplied showState[index] to false, and everything else to true.", ->
      inject (showState,$rootScope) ->
        scope = $rootScope.$new()
        ss = new showState ["div1","div2"],scope
        ss.set("div1")
        expect(scope.showState["div1"]).toBeFalsy()
        expect(scope.showState["div2"]).toBeTruthy()


  describe "jsonParser", ->
    beforeEach inject ($injector) ->
      $httpBackend = $injector.get('$httpBackend')
      $httpBackend.expect("JSONP","test.json")
      .respond('[{"page":1,"pages":13038,"per_page":"1","total":13038}]')

    it "should return false if input is empty", ->

    it "should return object when worldbank url is passed", ->
      inject (jsonParser) ->
        opts =
          url:"test.json"
          type:"worldBank"
        obj = jsonParser opts
        #returns a promise object


  describe "app_analysis_getData_inputCache", ->
    beforeEach ->
      #$stateParams = $injector.get('$stateParams');
    it "should return false if input data is empty", ->
      inject ($stateParams,app_analysis_getData_inputCache) ->
        expect(app_analysis_getData_inputCache.set null).toBeFalsy()
        expect(app_analysis_getData_inputCache.set []).toBeTruthy()
        expect(app_analysis_getData_inputCache.set [1,2,4]).toBeTruthy()

    it "should publish message if data not updated within 4 seconds of first update", ->
      inject (sb,$stateParams,app_analysis_getData_inputCache) ->
        foo =
          cb : ->
        spyOn(foo,"cb")
        sb.subscribe
          msg:'handsontable updated'
          listener:foo
          msgScope:['getData']
        app_analysis_getData_inputCache.set [1,2,3]
        expect(foo.cb).toHaveBeenCalled()

    #it "should reset timer if data updated within 4 seconds", ->
      #inject ($stateParams,app_analysis_getData_inputCache) ->
        #expect(app_analysis_getData_inputCache.set null).toBeFalsy()
        #expect(app_analysis_getData_inputCache.set []).toBeFalsy()
