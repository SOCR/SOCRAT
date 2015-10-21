###
  @dependencies : (Angularjs-nvd3-directive)[http://cmaurer.github.io/angularjs-nvd3-directives/]
  @author: Selvam Palanimalai
###

chartsView = angular.module 'app_analysis_chartsView', ['nvd3ChartDirectives']

###
  @description: Constructor for this module.
  @type: factory
###
chartsView.factory 'app_analysis_chartsView_manager', [
  () ->
    _sb = null

    _msgList =
      outgoing: ['get table']
      incoming: ['take table']
      scope: ['chartsView']

    _setSb = (sb) ->
      _sb = sb

    _getSb = () ->
      _sb

    _getMsgList = () ->
      _msgList

    getSb: _getSb
    setSb: _setSb
    getMsgList: _getMsgList
]

###
  @description: Constructor for this module.
  @type: factory
###
chartsView.factory('app_analysis_chartsView_constructor', [
  'app_analysis_chartsView_manager'
  (manager) ->
    (sb) ->
      manager.setSb sb unless !sb?
      _msgList = manager.getMsgList()

      init: (opt) ->
        console.log 'chartsView init invoked'

      destroy: () ->

      msgList: _msgList
])

###
  @description: All default values specific to charts module.
  @type: constant
###
chartsView.constant 'app_analysis_chartsView_defaults',
  defaultPlot: 'line'
  plots:
    'line':
      disabled:false
      label:'Line'
    'bar':
      disabled:false
      label:'Bar'
    'cumulativeLine':
      disabled:false
      label:'Cumulative Line'
    'stackedArea':
      disabled:false
      label:'Stacked Area'

###
  @description: Get list of variables from db.
  @type: factory
###
chartsView.factory 'app_analysis_chartsView_variables',[
  ()->
    _list = null
    get:->
      _list
    set:(id)->
      # TODO: get list from db for the id [projectId:forkId]
      _list = ['A','B','C','D']
]


###
  @type:controller
###
chartsView.controller('chartsSidebarCtrl',[
  '$scope'
  '$stateParams'
  '$rootScope'
  'app_analysis_chartsView_defaults'
  'app_analysis_chartsView_variables'
  ($scope,$stateParams,$rootScope,defaults,variables)->

    $scope.plots = defaults.plots
    $scope.currentPlot = defaults.defaultPlot

    #set the fork name
    #TODO : Cross check with projectMngr module,
    # if the projectid and forkid exist.
    if (_c = $stateParams).projectId? or _c.forkId?
      $scope.currentFork = $stateParams.projectId+':'+$stateParams.forkId

    console.log "ChartsSidebar CTRL"
    #NOTE: since all plots that socr supports [as of now] are only 1 or 2
    # dimensionals, there are only 2 variable dropdowns.

    # get all chartable variables in the CURRENT fork.
    # datasets, analysis output, time.
    # call db get the list of variables. then save it in defaults.
    variables.set(_c.projectId+':'+_c.forkId)
    $scope.variables = variables.get()

    #watch forkname for change.
    $scope.$watch 'currentFork', (newVal,oldVal)->
      # redirect page

    # watch xVariable, yVariable, plotType for change.
    # send broadcast message to update chart.
    $scope.$watch 'currentPlot', (newVal,oldVal)->
      $rootScope.$broadcast 'chartsMainCtrl:update currentPlot',
        newVal
    $scope.$watch 'xVariable', (newVal,oldVal)->
      if newVal isnt undefined and  newVal isnt oldVal
        alert newVal
        $rootScope.$broadcast 'chartsMainCtrl:update variable',
          type:'xVariable'
          value:newVal
    $scope.$watch 'yVariable', (newVal,oldVal)->
      if newVal isnt undefined and  newVal isnt oldVal
        alert newVal
        $rootScope.$broadcast 'chartsMainCtrl:update variable',
          type:'yVariable'
          value:newVal

])

###
  @type:controller
###
chartsView.controller('chartsMainCtrl' ,[
  '$q'
  '$scope'
  'app_analysis_chartsView_defaults'
  'app_analysis_chartsView_variables'
  'app_analysis_chartsView_manager'
  ($q,$scope,defaults,variables,manager)->

    sb = manager.getSb()

    #directive config.
    $scope.width = 900
    $scope.height = 400
    #make db call.

    #plot type changed in sidebar.
    $scope.$on 'chartsMainCtrl:update currentPlot', (args...)->
      for k, v of defaults.plots
        if v.label is args[1]
          $scope.currentPlot = k

    $scope.$on 'chartsMainCtrl:update variable',(args...)->
      for d in variables.get()
        if d is args[1].value
          # edit the values in the #scope.data depending on the xvariable.
          console.log 'changed variable '+args[1].type+' to '+args[1].value
          newKey = args[1].value

      #create promise object
      deferred = $q.defer()
      console.log "deferred",deferred
      #make db call.
      sb.publish
        msg:'get table',
        data:{data:['charts_test_db',newKey],promise:deferred}
        msgScope:['chartsView']

      console.log "promise object:",deferred.promise
      #onsucess, update $scope.data
      deferred.promise.then ((key)->
        (data)->
          window.data = data
          #update the plot with data.
          console.log data
          $scope.data.push
            key:newKey
            values:data
      )(newKey)
    #default value.
    $scope.currentPlot = 'none'
    #plotData
    $scope.data = []
    $scope.data2 = [
      key: 'Series 1'
      values: [
        [1025409600000, 0], [1028088000000, -6.3382185140371],
        [1030766400000, -5.9507873460847], [1033358400000, -11.569146943813],
        [1036040400000, -5.4767332317425], [1038632400000, 0.50794682203014],
        [1041310800000, -5.5310285460542], [1043989200000, -5.7838296963382],
        [1046408400000, -7.3249341615649], [1049086800000, -6.7078630712489],
        [1051675200000, 0.44227126150934], [1054353600000, 7.2481659343222],
        [1056945600000, 9.2512381306992], [1059624000000, 11.341210982529],
        [1062302400000, 14.734820409020], [1064894400000, 12.387148007542],
        [1067576400000, 18.436471461827], [1070168400000, 19.830742266977],
        [1072846800000, 22.643205829887], [1075525200000, 26.743156781239],
        [1078030800000, 29.597478802228], [1080709200000, 30.831697585341],
        [1083297600000, 28.054068024708], [1085976000000, 29.294079423832],
        [1088568000000, 30.269264061274], [1091246400000, 24.934526898906],
        [1093924800000, 24.265982759406], [1096516800000, 27.217794897473],
        [1099195200000, 30.802601992077], [1101790800000, 36.331003758254],
        [1104469200000, 43.142498700060], [1107147600000, 40.558263931958],
        [1109566800000, 42.543622385800], [1112245200000, 41.683584710331],
        [1114833600000, 36.375367302328], [1117512000000, 40.719688980730],
        [1120104000000, 43.897963036919], [1122782400000, 49.797033975368],
        [1125460800000, 47.085993935989], [1128052800000, 46.601972859745],
        [1130734800000, 41.567784572762], [1133326800000, 47.296923737245],
        [1136005200000, 47.642969612080], [1138683600000, 50.781515820954],
        [1141102800000, 52.600229204305], [1143781200000, 55.599684490628],
        [1146369600000, 57.920388436633], [1149048000000, 53.503593218971],
        [1151640000000, 53.522973979964], [1154318400000, 49.846822298548],
        [1156996800000, 54.721341614650], [1159588800000, 58.186236223191],
        [1162270800000, 63.908065540997], [1164862800000, 69.767285129367],
        [1167541200000, 72.534013373592], [1170219600000, 77.991819436573],
        [1172638800000, 78.143584404990], [1175313600000, 83.702398665233],
        [1177905600000, 91.140859312418], [1180584000000, 98.590960607028],
        [1183176000000, 96.245634754228], [1185854400000, 92.326364432615],
        [1188532800000, 97.068765332230], [1191124800000, 105.81025556260],
        [1193803200000, 114.38348777791], [1196398800000, 103.59604949810],
        [1199077200000, 101.72488429307], [1201755600000, 89.840147735028],
        [1204261200000, 86.963597532664], [1206936000000, 84.075505208491],
        [1209528000000, 93.170105645831], [1212206400000, 103.62838083121],
        [1214798400000, 87.458241365091], [1217476800000, 85.808374141319],
        [1220155200000, 93.158054469193], [1222747200000, 65.973252382360],
        [1225425600000, 44.580686638224], [1228021200000, 36.418977140128],
        [1230699600000, 38.727678144761], [1233378000000, 36.692674173387],
        [1235797200000, 30.033022809480], [1238472000000, 36.707532162718],
        [1241064000000, 52.191457688389], [1243742400000, 56.357883979735],
        [1246334400000, 57.629002180305], [1249012800000, 66.650985790166],
        [1251691200000, 70.839243432186], [1254283200000, 78.731998491499],
        [1256961600000, 72.375528540349], [1259557200000, 81.738387881630],
        [1262235600000, 87.539792394232], [1264914000000, 84.320762662273],
        [1267333200000, 90.621278391889], [1270008000000, 102.47144881651],
        [1272600000000, 102.79320353429], [1275278400000, 90.529736050479],
        [1277870400000, 76.580859994531], [1280548800000, 86.548979376972],
        [1283227200000, 81.879653334089], [1285819200000, 101.72550015956]]
    ]

    $scope.xFunction = ->
      (d)->
        d[0]
    $scope.yFunction = ->
      (d)->
        d[1]
])
