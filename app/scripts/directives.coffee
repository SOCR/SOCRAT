'use strict'

### Directives ###

# register the module with Angular
angular.module('app.directives', [
  # require the 'app.service' module
  'app.services'
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
          # once the promise is resolved
          args.promise.then ->
            _change(args.success)
            setTimeout ->
              elem.html('')
              elem.css 'display','none'
            ,duration

    scope.$on 'app:push notification', scope.update

