module.exports = function anonymous(locals, attrs, escape, rethrow, merge) {
attrs = attrs || jade.attrs; escape = escape || jade.escape; rethrow = rethrow || jade.rethrow; merge = merge || jade.merge;
var buf = [];
with (locals || {}) {
var interp;
var __indent = [];
buf.push('<!DOCTYPE html>\n<html lang="en" ng-app="app">\n  <head>\n    <meta charset="utf-8">\n    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">\n    <meta name="viewport" content="width=device-width" initial-scale="1.0">\n    <meta name="description" content="">\n    <meta name="author" content="">\n    <title ng-bind-template="{{pageTitle}}"></title>\n    <link rel="stylesheet" href="css/app.css"><!--[if lte IE 7]>\n    <script src="http://cdnjs.cloudflare.com/ajax/libs/json2/20110223/json2.js"></script><![endif]--><!--[if lte IE 8]>\n    <script src="//html5shiv.googlecode.com/svn/trunk/html5.js"></script><![endif]-->\n    <script>\n      window.brunch = window.brunch || {};\n      window.brunch[\'auto-reload\'] = {\n        enabled: true\n      };\n    </script>\n    <script src="js/vendor.js"></script>\n    <script src="js/app.js"></script>\n  </head>\n  <body ng-controller="AppCtrl">\n    <div class="wrapper">\n      <div class="navbar navbar-static-top navbar-inverse">\n        <div class="navbar-inner">\n          <div class="container-fluid">\n            <button data-toggle="collapse" data-target=".nav-collapse" class="btn btn-navbar"><span class="icon-bar"></span><span class="icon-bar"></span><span class="icon-bar"></span></button><a href="/" class="brand">SOCR</a>\n            <div class="nav-collapse">\n              <div ng-include="\'partials/nav.html\'"></div>\n              <p class="navbar-text pull-right">Logged in as&nbsp;<a href="#" class="navbar-link">Username</a></p>\n            </div>\n          </div>\n        </div>\n      </div>\n      <!--tooblar navigation for statistical analysis -->\n      <div class="navbar navbar-static-top">\n        <div class="navbar-inner">\n          <div class="container">\n            <button data-toggle="collapse" data-target=".analysis-toolbar" class="btn btn-navbar"><span class="icon-bar"></span><span class="icon-bar"></span><span class="icon-bar"></span></button><a href="/" class="brand">Analysis</a>\n            <div class="nav-collapse analysis-toolbar">\n              <div ng-include="\'partials/analysis-nav.html\'"></div>\n            </div>\n          </div>\n        </div>\n      </div>\n      <!--Main content section-->\n      <div class="main-content container-fluid">\n        <div class="row-fluid">\n          <div ng-include="\'partials/sub-menu.html\'"></div>\n          <div ng-view class="span8"></div>\n        </div>\n      </div>\n      <div class="push"></div>\n    </div>\n    <div ng-include="\'partials/footer.html\'"></div>\n  </body>\n</html>');
}
return buf.join("");
};module.exports = function anonymous(locals, attrs, escape, rethrow, merge) {
attrs = attrs || jade.attrs; escape = escape || jade.escape; rethrow = rethrow || jade.rethrow; merge = merge || jade.merge;
var buf = [];
with (locals || {}) {
var interp;
var __indent = [];
buf.push('\n<!--main navigation template-->\n<ul class="nav">\n  <li ng-class="getClass(\'/raw-data\')"><a ng-href="#/raw-data">Raw Data</a></li>\n  <li ng-class="getClass(\'/derived-data\')"><a ng-href="#/derived-data">Dervied Data</a></li>\n  <li ng-class="getClass(\'/tools\')"><a ng-href="#/tools">Tools</a></li>\n  <li ng-class="getClass(\'/charts\')"><a ng-href="#/charts">Charts</a></li>\n  <li ng-class="getClass(\'/results\')"><a ng-href="#/results">Results</a></li>\n</ul>');
}
return buf.join("");
};module.exports = function anonymous(locals, attrs, escape, rethrow, merge) {
attrs = attrs || jade.attrs; escape = escape || jade.escape; rethrow = rethrow || jade.rethrow; merge = merge || jade.merge;
var buf = [];
with (locals || {}) {
var interp;
var __indent = [];
}
return buf.join("");
};module.exports = function anonymous(locals, attrs, escape, rethrow, merge) {
attrs = attrs || jade.attrs; escape = escape || jade.escape; rethrow = rethrow || jade.rethrow; merge = merge || jade.merge;
var buf = [];
with (locals || {}) {
var interp;
var __indent = [];
}
return buf.join("");
};module.exports = function anonymous(locals, attrs, escape, rethrow, merge) {
attrs = attrs || jade.attrs; escape = escape || jade.escape; rethrow = rethrow || jade.rethrow; merge = merge || jade.merge;
var buf = [];
with (locals || {}) {
var interp;
var __indent = [];
buf.push('\n<input/>');
}
return buf.join("");
};module.exports = function anonymous(locals, attrs, escape, rethrow, merge) {
attrs = attrs || jade.attrs; escape = escape || jade.escape; rethrow = rethrow || jade.rethrow; merge = merge || jade.merge;
var buf = [];
with (locals || {}) {
var interp;
var __indent = [];
buf.push('\n<input/>');
}
return buf.join("");
};module.exports = function anonymous(locals, attrs, escape, rethrow, merge) {
attrs = attrs || jade.attrs; escape = escape || jade.escape; rethrow = rethrow || jade.rethrow; merge = merge || jade.merge;
var buf = [];
with (locals || {}) {
var interp;
var __indent = [];
buf.push('\n<footer class="footer">\n  <div class="container">\n    <p><small><a href="https://github.com/scotch/angular-brunch-seed">angular-brunch-seed | source</a></small></p>\n  </div>\n</footer>');
}
return buf.join("");
};module.exports = function anonymous(locals, attrs, escape, rethrow, merge) {
attrs = attrs || jade.attrs; escape = escape || jade.escape; rethrow = rethrow || jade.rethrow; merge = merge || jade.merge;
var buf = [];
with (locals || {}) {
var interp;
var __indent = [];
buf.push('\n<ul class="nav">\n  <li ng-class="getClass(\'/home\')"><a ng-href="#/home">Home</a></li>\n  <li ng-class="getClass(\'/guide\')"><a ng-href="#/guide">Guide</a></li>\n  <li ng-class="getClass(\'/contact\')"><a ng-href="#/contact">Contact</a></li>\n</ul>');
}
return buf.join("");
};module.exports = function anonymous(locals, attrs, escape, rethrow, merge) {
attrs = attrs || jade.attrs; escape = escape || jade.escape; rethrow = rethrow || jade.rethrow; merge = merge || jade.merge;
var buf = [];
with (locals || {}) {
var interp;
var __indent = [];
buf.push('\n<div class="hero-unit">\n  <h2>Contact Us</h2>\n  <p>We place user at the center while developing the applications. Your feedback are most valuable for us to improve the overall experience. Please drop us a mail @ for suggestions and feedback.</p>\n  <p>The <strong>SOCR One </strong><span>active development team comprises of </span><a href="#">Selvam </a><span>and </span><a href="#">Alexandr </a>\n    <and>is headed by </and><a href="#">Dr.Ivo Dinov .  </a>\n  </p><a href="#" class="btn btn-small"> <i class="icon-github icon-2x"> </i>&nbsp; GitHub </a>&nbsp;<a href="#" class="btn btn-small btn-inverse"> <i class="icon-facebook icon-2x"> </i>&nbsp; Facebook </a>&nbsp;<a href="#" class="btn btn-small btn-primary"> <i class="icon-twitter icon-2x"> </i>&nbsp; Twitter </a>\n</div>');
}
return buf.join("");
};module.exports = function anonymous(locals, attrs, escape, rethrow, merge) {
attrs = attrs || jade.attrs; escape = escape || jade.escape; rethrow = rethrow || jade.rethrow; merge = merge || jade.merge;
var buf = [];
with (locals || {}) {
var interp;
var __indent = [];
buf.push('\n<div class="hero-unit">\n  <h2>Guide</h2>\n  <p>The goal of this project is to design a modern and portable SOCR web-app that demonstrates the concepts of statistical analysis such as resampling, randomization and probabilistic simulation and runs seamlessly across varied devices. The application will be based on HTML5, CSS3 and JavaScript framework</p>\n  <p>There is an extensive guide for you to explore , use and learn from the comprehensive resources of SOCR.</p><a class="btn btn-large btn-primary">Click here</a>\n</div>');
}
return buf.join("");
};module.exports = function anonymous(locals, attrs, escape, rethrow, merge) {
attrs = attrs || jade.attrs; escape = escape || jade.escape; rethrow = rethrow || jade.rethrow; merge = merge || jade.merge;
var buf = [];
with (locals || {}) {
var interp;
var __indent = [];
buf.push('\n<p>home</p>');
}
return buf.join("");
};module.exports = function anonymous(locals, attrs, escape, rethrow, merge) {
attrs = attrs || jade.attrs; escape = escape || jade.escape; rethrow = rethrow || jade.rethrow; merge = merge || jade.merge;
var buf = [];
with (locals || {}) {
var interp;
var __indent = [];
buf.push('\n<div ng-controller="subMenuCtrl">\n  <div ng-class="getClass()" class="sub-menu well"><i ng-click="toggle()" class="icon-circle-arrow-left"></i>\n    <div ng-show="view()">\n      <ul class="nav nav-list unstyled">\n        <li class="nav-header">Project1</li>\n        <li><a>Story 1\n            <button class="btn btn-inverse btn-small">fork</button></a></li>\n        <li class="active"><a>Story 2\n            <button class="btn btn-inverse btn-small">fork</button></a></li>\n        <li class="nav-header">Project 2</li>\n        <li>\n          <button class="btn btn-medium btn-danger">Create New &nbsp;<i class="icon-plus-sign"></i></button>\n        </li>\n      </ul>\n    </div>\n  </div>\n</div>');
}
return buf.join("");
};module.exports = function anonymous(locals, attrs, escape, rethrow, merge) {
attrs = attrs || jade.attrs; escape = escape || jade.escape; rethrow = rethrow || jade.rethrow; merge = merge || jade.merge;
var buf = [];
with (locals || {}) {
var interp;
var __indent = [];
buf.push('\n<div ng-app="ng-app">\n  <h2>Todo</h2>\n  <div ng-controller="TodoCtrl"><span>{{remaining()}} of {{todos.length}} remaining</span> [<a href="" ng-click="archive()">archive</a>]\n    <ul class="unstyled">\n      <li ng-repeat="todo in todos">\n        <label class="checkbox inline">\n          <input type="checkbox" ng-model="todo.done"/><span class="done{{todo.done}}">{{todo.text}}</span>\n        </label>\n      </li>\n    </ul>\n    <form ng-submit="addTodo()" class="form-inline">\n      <p>\n        <input type="text" ng-model="todoText" size="30" placeholder="add new todo here"/>\n        <input type="submit" value="add" class="btn btn-primary"/>\n      </p>\n    </form>\n  </div>\n</div>');
}
return buf.join("");
};