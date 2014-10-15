### utils.importer Module ###

# Importer proterties
# Any file/data import feature should be here.
# getData module should use module for all its functions.

# TODO: move jsonParser factory from getData -> utils.importer

utils = angular.module 'app.utils.importer',['app.utils.toolkit']

####
#  Every module is supposed have a factory method
#  by its name. For example, "app.charts" module will
#  have "charts" factory method.
#
#  This method helps in module initialization.
#  init() and destroy() methods should be present in
#  returned object.
####
utils.factory('app.utils.importer',[
  'app.utils.importerEventMngr'
  (evtMngr)->
    (sb)->
      msgList = evtMngr.getMsgList()
      evtMngr.setSb sb unless !sb?
      init: (opt)->
        console.log '%c importer init called','color: orange'
        evtMngr.listenToIncomeEvents()
      
      destroy: ()->

      msgList:msgList
])

####
# Every module will have a MODULE_NAMEEventMngr() service
# which provides messaging with core
####
utils.service('app.utils.importerEventMngr', [
  'app.utils.importer.csvUpload'
  'app.utils.importer.sb'
  (csvUpload,utilsSb) ->
    sb = null
    msgList =
      outcome: ['save table']
      income:
        'upload csv':
          method: csvUpload
          outcome: 'save table'
      scope: ['app.utils.importer']

    eventManager = (msg, data) ->
      try
        _data = msgList.income[msg].method.apply null,data
      catch e
        #handle error
        console.log '%c'+e.message,'color:red'
        console.log e.stack

      console.log '%c Marker','color:blue'
      # sb.publish
      #   msg: msgList.outcome[0]
      #   data: _data
      #   msgScope: msgList.scope

    setSb: (_sb) ->
      return false if _sb is undefined
      sb = _sb
      utilsSb.set _sb

    getMsgList: () ->
      msgList

    listenToIncomeEvents: () ->
      for msg in msgList.income
        console.log 'subscribed for ' + msg
        sb.subscribe
          msg: msg
          listener: eventManager
          msgScope: msgList.scope
          context: console
])

# Sanbox service
# @returns : {object}
# @description: getter and setter methods to sandbox.
# Can be set only ONCE by calling set()

utils.service('app.utils.importer.sb', ->
  _sb = {}
  get:->
    _sb
  set:(sb)->
    return false if sb is undefined
    _sb = sb
    Object.freeze _sb
)

utils.factory 'app.utils.importer.csvUpload', [
  '$q'
  'app.utils.toolkit.toCSV'
  'app.utils.importer.sb'
  ($q,toCSV,utilsSb)->
    (opts)->
      return false if !opts?
      return false if !opts.projectId?
      # default to comma seperated values (CSV)
      sep = opts.seperator || ','
      deferred = $q.defer()
      cb = (data)->
        options = []
        #pass the deferred object to db along with message
        options.deferred = deferred
        # data object should follow this schema
        # use opts.columnName
        # colA = ["a","a","b","b","c"]
        # colB = [0,1,2,3,4]
        # colC = [12,3,42,4]
        # table = [
        #   {name:"A", values:colA, type:"nominal"}
        #   {name:"B", values:colB, type:"numeric"}
        options.data = data
        options.projectId = opts.projectId
        #fallback to the default fork (or should it send an error??)
        options.forkId = opts.forkId || 'default'
        #sent msg to database
        utilsSb.get().publish
          msg:'save table'
          data: options
          msgScope:['database']
        deferred.promise.then (opt)->
          if opt.success
            opts.deferred.resolve 'successfully saved!', data
          if opt.failure
            opts.deferred.reject 'Database had an issue while saving CSV data'
      if opts.url?
        csv = $http.get(
          opts.url
          )
        .success((data,status)->
            cb(data)
          )
        .error((data,status)->
            #tell UI that error occurred
          )
      else
        csv = toCSV opts.data
        cb(csv)
        #return the promise the object
      deferred.promise
]

utils.factory 'app.utils.importer.jsonUpload', ->


