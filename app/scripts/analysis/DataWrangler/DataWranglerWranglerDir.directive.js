// Generated by CoffeeScript 1.12.2
(function() {
  'use strict';
  var BaseDirective, DataWranglerWranglerDir,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  require('jquery-ui-layout');

  BaseDirective = require('scripts/BaseClasses/BaseDirective');

  module.exports = DataWranglerWranglerDir = (function(superClass) {
    extend(DataWranglerWranglerDir, superClass);

    function DataWranglerWranglerDir() {
      return DataWranglerWranglerDir.__super__.constructor.apply(this, arguments);
    }

    DataWranglerWranglerDir.inject('app_analysis_dataWrangler_wrangler', 'app_analysis_dataWrangler_msgService', '$timeout');

    DataWranglerWranglerDir.prototype.initialize = function() {
      this.wrangler = this.app_analysis_dataWrangler_wrangler;
      this.msgManager = this.app_analysis_dataWrangler_msgService;
      this.restrict = 'E';
      this.transclude = true;
      this.template = require('partials/analysis/DataWrangler/wrangler.jade')();
      this.replace = true;
      return this.link = (function(_this) {
        return function(scope, elem, attr) {
          var DATA_TYPES;
          scope.purpose = attr.purpose;
          DATA_TYPES = _this.msgManager.getSupportedDataTypes();
          return _this.$timeout(function() {
            var container, dashboardContainer, myLayout, previewContainer, transformContainer;
            if ((scope.mainArea.dataType != null) && scope.mainArea.dataType === DATA_TYPES.FLAT) {
              myLayout = $('#dt_example').layout({
                north: {
                  spacing_open: 0,
                  resizable: false,
                  slidable: false,
                  fxName: 'none'
                },
                south: {
                  spacing_open: 0,
                  resizable: false,
                  slidable: false,
                  fxName: 'none'
                },
                west: {
                  minSize: 310
                }
              });
              container = $('#table');
              previewContainer = $('#preview');
              transformContainer = $('#transformEditor');
              dashboardContainer = $("#wranglerDashboard");
              _this.wrangler.start({
                tableContainer: container,
                transformContainer: transformContainer,
                previewContainer: previewContainer,
                dashboardContainer: dashboardContainer
              });
              $('#table .odd .rowHeader').first().mouseup().mousedown();
              d3.select('div.menu_option.Promote')[0][0].__onmousedown();
              return $('div.suggestion.selected').click();
            }
          });
        };
      })(this);
    };

    return DataWranglerWranglerDir;

  })(BaseDirective);

}).call(this);

//# sourceMappingURL=DataWranglerWranglerDir.directive.js.map
