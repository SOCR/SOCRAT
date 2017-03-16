// Generated by CoffeeScript 1.12.2
(function() {
  'use strict';
  var BaseModuleInitService, MyModuleInitService,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  BaseModuleInitService = require('scripts/BaseClasses/BaseModuleInitService.coffee');

  module.exports = MyModuleInitService = (function(superClass) {
    extend(MyModuleInitService, superClass);

    function MyModuleInitService() {
      return MyModuleInitService.__super__.constructor.apply(this, arguments);
    }

    MyModuleInitService.inject('app_analysis_mymodule_msgService');

    MyModuleInitService.prototype.initialize = function() {
      this.msgService = this.app_analysis_mymodule_msgService;
      return this.setMsgList();
    };

    return MyModuleInitService;

  })(BaseModuleInitService);

}).call(this);

//# sourceMappingURL=MyModuleInit.service.js.map
