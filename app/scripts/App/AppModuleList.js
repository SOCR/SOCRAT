// Generated by CoffeeScript 1.12.2
(function() {
  'use strict';
  var AppModuleList, Module;

  Module = require('scripts/BaseClasses/BaseModule.coffee');


  /*
   * @name AppModuleList
   * @desc Class for listing of all modules that exist in the app by category
   */

  module.exports = AppModuleList = (function() {
    function AppModuleList() {}

    AppModuleList.prototype.system = ['ui.router', 'ui.router.compat', 'ui.bootstrap', 'ngCookies', 'ngResource', 'ngSanitize', 'app_controllers', 'app_directives', 'app_filters', 'app_services', 'app_core', 'app_mediator', 'frapontillo.bootstrap-switch'];

    AppModuleList.prototype.analysis = [
      require('scripts/Database/Database.module.coffee'), require('scripts/analysis/Datalib/Datalib.module.coffee'), require('scripts/analysis/GetData/GetData.module.coffee'), require('scripts/analysis/DataWrangler/DataWrangler.module.coffee'), require('scripts/analysis/charts/Charts.module.coffee'), {
        Tools: [require('scripts/analysis/tools/Cluster/Cluster.module.coffee'), require('scripts/analysis/tools/Reliability/Reliability.module.coffee'), require('scripts/analysis/tools/MyModule/MyModule.module.coffee')]
      }
    ];

    AppModuleList.prototype.getAll = function() {
      return {
        system: this.system,
        analysis: this.analysis,
        tools: this.tools
      };
    };

    AppModuleList.prototype.getAnalysisModules = function() {
      return this.analysis;
    };

    AppModuleList.prototype.listAnalysisModules = function() {
      var i, k, len, m, modules, ref, v;
      modules = [];
      ref = this.analysis;
      for (i = 0, len = ref.length; i < len; i++) {
        m = ref[i];
        m = m instanceof Module ? [m.id] : ((function() {
          var results;
          results = [];
          for (k in m) {
            v = m[k];
            results.push(v.map(function(e) {
              return e.id;
            }));
          }
          return results;
        })())[0];
        modules = modules.concat(m);
      }
      return modules;
    };

    AppModuleList.prototype.listAll = function() {
      console.log(this.system);
      return this.system.concat(this.listAnalysisModules());
    };

    return AppModuleList;

  })();

}).call(this);

//# sourceMappingURL=AppModuleList.js.map
