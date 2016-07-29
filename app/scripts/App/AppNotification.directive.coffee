'use strict'

BaseDirective = require 'scripts/BaseClasses/BaseDirective'

module.extend = class AppNotificationDirective extends BaseDirective

  initialize: () ->
    @restrict = 'E'
    @transclude = true
    @template = '<div></div>'
#    @controllerAs = 'notificationCtrl'
#    @controller = (@$scope)->
    @link = (scope, elem, attr) ->

      scope.update = (evt, args) ->
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

dirsMod = angular.module 'app_directives'
AppNotificationDirective.register dirsMod, 'notification'
