'use strict'

### Directives ###

# register the module with Angular
angular.module('app_directives', [
  # require the 'app.service' module
  'app_services'
])

.directive('appVersion', [
  'version'

(version) ->

  (scope, elm, attrs) ->
    elm.text(version)
])

.directive 'notification', ->
  restrict: 'E'
  transclude:true
  template: '<div></div>'

  # replace:true
  controller:($scope)->

  link:(scope,elem,attr)->

    scope.update = (evt,args)->
      #args should contain
      # initialMsg:
      # type
      # promise object
      # finalMsg:
      # type
      # duration
      _change = (obj)->
        elem.removeClass().addClass('alert')
        elem.addClass obj.type
        elem.css('display','block')
        .css('z-index','9999')
        .css('position','fixed')
        elem.html obj.msg

      if args?
        duration = args.duration || 3000
        if (f = args.final)?
          _change(f)
          setTimeout ->
            elem.html ''
            elem.css 'display','none'
          ,duration
          return false
        if (i = args.initial)?
          _change(i)
          successCallback = ->
            _change(args.success)
            setTimeout ->
              elem.html('')
              elem.css 'display','none'
            ,duration
          failureCallback = ->
            _change(args.failure)
            setTimeout ->
              elem.html('')
              elem.css 'display','none'
            ,duration
          # once the promise is resolved
          args.promise.then successCallback, failureCallback

    scope.$on 'app:push notification', scope.update

.directive 'message', ->
  restrict:'EA'
  transclude:true
  template:'<div></div>'

  controller:($scope)->


  link:(scope,elem,attr)->

    scope.update = (evt,args)->
      if args?.msg?
        elem.addClass 'alert'
        elem.addClass args.type
        elem.html args.msg
        for o in args.options
          elem.html '<button>'+o.text+'</button>'
          scope.$broadcast o.msg, o.data
        
        elem.css 'display','block'
        elem.css 'z-index','9999'
        elem.css 'position','fixed'

    scope.$on 'app:push message',scope.update
