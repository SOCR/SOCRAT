'use strict';

var App;

App = angular.module('app', ['ngCookies', 'ngResource', 'app.controllers', 'app.directives', 'app.filters', 'app.services']);

App.config([
  '$routeProvider', '$locationProvider', function($routeProvider, $locationProvider, config) {
    $routeProvider.when('/todo', {
      templateUrl: 'partials/todo.html'
    }).when('/home', {
      templateUrl: 'partials/nav/home.html'
    }).when('/guide', {
      templateUrl: 'partials/nav/guide-me.html'
    }).when('/contact', {
      templateUrl: 'partials/nav/contact.html'
    }).when('/raw-data', {
      templateUrl: 'partials/analysis/raw-data/main.html'
    }).when('/derived-data', {
      templateUrl: 'partials/analysis/derived-data/main.html'
    }).otherwise({
      redirectTo: '/home'
    });
    return $locationProvider.html5Mode(false);
  }
]);
'use strict';

/* Controllers
*/

angular.module('app.controllers', []).controller('AppCtrl', [
  '$scope', '$location', '$resource', '$rootScope', function($scope, $location, $resource, $rootScope) {
    $scope.$location = $location;
    $scope.$watch('$location.path()', function(path) {
      return $scope.activeNavId = path || '/';
    });
    return $scope.getClass = function(id) {
      if ($scope.activeNavId.substring(0, id.length) === id) {
        return 'active';
      } else {
        return '';
      }
    };
  }
]).controller('subMenuCtrl', [
  '$scope', function($scope) {
    $scope.state = "show";
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
]).controller('MyCtrl2', [
  '$scope', function($scope) {
    return $scope;
  }
]).controller('TodoCtrl', [
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
