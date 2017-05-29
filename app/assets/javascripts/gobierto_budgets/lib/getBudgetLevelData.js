'use strict';

var getBudgetLevelData = Class.extend({
  init: function() {
    this.data = null;
  },
  getData: function(callback) {
    d3.json('/data.json', function(error, data) {
      if (error) throw error;

      this.data = data;

      window.budgetLevels = this.data;

      if (callback) callback();
    }.bind(this));
  }
});
