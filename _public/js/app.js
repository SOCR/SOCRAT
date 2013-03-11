'use strict';

var App;

App = angular.module('app', ['ngCookies', 'ngResource', 'app.controllers', 'app.directives', 'app.filters', 'app.services', 'app.core', 'ngSanitize']);

App.config([
  '$routeProvider', '$locationProvider', function($routeProvider, $locationProvider, config) {
    $routeProvider.when('/home', {
      templateUrl: 'partials/nav/home.html'
    }).when('/guide', {
      templateUrl: 'partials/nav/guide-me.html'
    }).when('/contact', {
      templateUrl: 'partials/nav/contact.html'
    }).when('/welcome', {
      templateUrl: 'partials/welcome.html'
    }).when('/raw-data', {
      templateUrl: 'partials/analysis/raw-data/main.html'
    }).when('/derived-data', {
      templateUrl: 'partials/analysis/derived-data/main.html'
    }).otherwise({
      redirectTo: '/welcome'
    });
    return $locationProvider.html5Mode(false);
  }
]);

App.value("username", "keshavr7");
'use strict';

/* Controllers
*/

angular.module('app.controllers', ['app.core']).controller('AppCtrl', [
  '$scope', '$location', '$resource', '$rootScope', 'pubSub', function($scope, $location, $resource, $rootScope, pubSub) {
    var updateUsername;
    $scope.$location = $location;
    $scope.username = "Guest";
    $scope.$watch('$location.path()', function(path) {
      return $scope.activeNavId = path || '/';
    });
    $scope.getClass = function(id) {
      if ($scope.activeNavId.substring(0, id.length) === id) {
        return 'active';
      } else {
        return '';
      }
    };
    updateUsername = function(event, data) {
      return $scope.username = data;
    };
    return pubSub.subscribe("username changed", updateUsername);
  }
]).controller('subMenuCtrl', [
  '$scope', 'pubSub', function($scope, pubSub) {
    var updateMsg;
    $scope.message = "Enter your name....";
    $scope.messageReceived = "";
    $scope.state = "show";
    $scope.sendMsg = function() {
      console.log(this.token);
      pubSub.publish("username changed", $scope.message);
      console.log("published successfully");
      return null;
    };
    $scope.unsubMsg = function() {
      console.log("unsubscribe initiated");
      pubSub.unsubscribe($scope.token);
      return null;
    };
    updateMsg = function(event, msg) {
      $scope.messageReceived = msg;
      console.log("message received successfully through pub/sub");
      return null;
    };
    $scope.token = pubSub.subscribe("username changed", updateMsg);
    $scope.view = function() {
      if ($scope.state === "show") {
        return true;
      } else {
        return false;
      }
    };
    $scope.toggle = function() {
      if ($scope.state === "hidden") {
        return $scope.state = "show";
      } else {
        return $scope.state = "hidden";
      }
    };
    return $scope.getClass = function() {
      if ($scope.state === "hidden") {
        return "span1";
      } else {
        return "span4";
      }
    };
  }
]).controller('welcomeCtrl', ['$scope', function($scope) {}]).controller('TodoCtrl', [
  '$scope', function($scope) {
    $scope.todos = [
      {
        text: "learn angular",
        done: true
      }, {
        text: "build an angular app",
        done: false
      }
    ];
    $scope.addTodo = function() {
      $scope.todos.push({
        text: $scope.todoText,
        done: false
      });
      return $scope.todoText = "";
    };
    $scope.remaining = function() {
      var count;
      count = 0;
      angular.forEach($scope.todos, function(todo) {
        return count += (todo.done ? 0 : 1);
      });
      return count;
    };
    return $scope.archive = function() {
      var oldTodos;
      oldTodos = $scope.todos;
      $scope.todos = [];
      return angular.forEach(oldTodos, function(todo) {
        if (!todo.done) {
          return $scope.todos.push(todo);
        }
      });
    };
  }
]);
'use strict';

var core;

core = angular.module('app.core', ['app.services']).service("pubSub", function() {
  var _channelList, _lastUID, _publish, _subscribe, _unsubscribe;
  _channelList = {};
  _lastUID = 14;
  _publish = function(channel, data) {
    var i, j, subscribers;
    if (_channelList.hasOwnProperty(channel)) {
      subscribers = _channelList[channel];
      i = 0;
      j = subscribers.length;
      while (i < j) {
        try {
          subscribers[i].func(channel, data);
        } catch (e) {
          throw e;
        }
        i++;
      }
    } else {
      _channelList[channel] = [];
    }
    return console.log(subscribers);
  };
  _subscribe = function(channel, cb) {
    if (!_channelList.hasOwnProperty(channel)) {
      _channelList[channel] = [];
    }
    _channelList[channel].push({
      token: ++_lastUID,
      func: cb
    });
    console.log("successfully subscribed");
    console.log(_channelList);
    return _lastUID;
  };
  _unsubscribe = function(token) {
    var i, j, m;
    for (m in _channelList) {
      if (_channelList.hasOwnProperty(m)) {
        i = 0;
        j = _channelList[m].length;
        while (i < j) {
          if (_channelList[m][i].token === token) {
            _channelList[m].splice(i, 1);
            console.log("successfully unsubscribed");
            return token;
          }
          i++;
        }
      }
    }
  };
  return {
    publish: _publish,
    subscribe: _subscribe,
    unsubscribe: _unsubscribe
  };
});
'use strict';


'use strict';

/* Directives
*/

angular.module('app.directives', ['app.services']).directive('appVersion', [
  'version', function(version) {
    return function(scope, elm, attrs) {
      return elm.text(version);
    };
  }
]);
'use strict';

/* Filters
*/

angular.module('app.filters', []).filter('interpolate', [
  'version', function(version) {
    return function(text) {
      return String(text).replace(/\%VERSION\%/mg, version);
    };
  }
]);
'use strict';

/* Sevices
*/

angular.module('app.services', []).factory('version', function() {
  return "0.1";
});
