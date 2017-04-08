// Generated by CoffeeScript 1.12.2
(function() {
  'use strict';
  var BaseService, DataWranglerWrangler,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  BaseService = require('scripts/BaseClasses/BaseService.coffee');


  /*
    @name: app_analysis_dataWrangler_wrangler
    @type: service
    @desc: starts wrangler
   */

  module.exports = DataWranglerWrangler = (function(superClass) {
    extend(DataWranglerWrangler, superClass);

    function DataWranglerWrangler() {
      return DataWranglerWrangler.__super__.constructor.apply(this, arguments);
    }

    DataWranglerWrangler.inject('$q', '$timeout', '$stateParams', '$rootScope', 'app_analysis_dataWrangler_msgService', 'app_analysis_dataWrangler_dataService', 'app_analysis_dataWrangler_dataAdaptor');

    DataWranglerWrangler.prototype.initialize = function() {
      this.msgManager = this.app_analysis_dataWrangler_msgService;
      this.dataService = this.app_analysis_dataWrangler_dataService;
      this.dataAdaptor = this.app_analysis_dataWrangler_dataAdaptor;
      this.DATA_TYPES = this.msgManager.getSupportedDataTypes();
      this.initial_transforms = [];
      this.table = [];
      this.csvData = [];
      this.dv = require('datavore');
      return this.dw = require('data-wrangler');
    };

    DataWranglerWrangler.prototype.init = function() {
      var data;
      return data = this.dataService.getData().then((function(_this) {
        return function(data) {
          if (data.dataFrame.dataType === _this.DATA_TYPES.FLAT) {
            _this.csvData = _this.dataAdaptor.toCsvString(data.dataFrame);
            return true;
          } else {
            return false;
          }
        };
      })(this));
    };

    DataWranglerWrangler.prototype.start = function(viewContainers) {
      return this.table = this.wrangle(viewContainers);
    };

    DataWranglerWrangler.prototype.wrangle = function(viewContainers) {
      var table;
      table = this.dv.table(this.csvData);
      this.initial_transforms = this.dw.raw_inference(this.csvData).transforms;
      this.dw.wrangler({
        table: table,
        initial_transforms: this.initial_transforms,
        tableContainer: viewContainers.tableContainer,
        transformContainer: viewContainers.transformContainer,
        previewContainer: viewContainers.previewContainer,
        dashboardContainer: viewContainers.dashboardContainer
      });
      return table;
    };

    DataWranglerWrangler.prototype.saveDataToDb = function(data, deferred) {
      var msgEnding;
      msgEnding = data.dataType === this.DATA_TYPES.FLAT ? ' as 2D data table' : ' as hierarchical object';
      this.msgManager.broadcast('app:push notification', {
        initial: {
          msg: 'Data is being saved in the database...',
          type: 'alert-info'
        },
        success: {
          msg: 'Successfully loaded data into database' + msgEnding,
          type: 'alert-success'
        },
        failure: {
          msg: 'Error in Database',
          type: 'alert-error'
        },
        promise: deferred.promise
      });
      console.log(data);
      return this.dataService.saveData(this.dataService.saveDataMsg, function() {
        return console.log('wrangled data saved to db');
      }, data, deferred);
    };

    DataWranglerWrangler.prototype.saveData = function() {
      clearTimeout(this.timer);
      this.deferred = this.$q.defer();
      this.data = this.dataAdaptor.toDataFrame(this.table);
      this.timer = this.$timeout(((function(_this) {
        return function(data, deferred) {
          return _this.saveDataToDb(data, deferred);
        };
      })(this))(this.data, this.deferred), 1000);
      return true;
    };

    return DataWranglerWrangler;

  })(BaseService);

}).call(this);

//# sourceMappingURL=DataWranglerWrangler.service.js.map
