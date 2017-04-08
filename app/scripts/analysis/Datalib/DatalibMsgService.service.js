// Generated by CoffeeScript 1.12.2
(function() {
  'use strict';
  var BaseModuleMessageService, DatalibMsgService,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  BaseModuleMessageService = require('scripts/BaseClasses/BaseModuleMessageService.coffee');

  module.exports = DatalibMsgService = (function(superClass) {
    extend(DatalibMsgService, superClass);

    function DatalibMsgService() {
      return DatalibMsgService.__super__.constructor.apply(this, arguments);
    }

    DatalibMsgService.prototype.msgList = {
      incoming: ['infer type', 'infer all types'],
      outgoing: ['type inferred', 'all types inferred'],
      scope: ['app_analysis_datalib']
    };

    return DatalibMsgService;

  })(BaseModuleMessageService);

}).call(this);

//# sourceMappingURL=DatalibMsgService.service.js.map
