'use strict';

var getBudgetLevelData = Class.extend({
  init: function() {
    this.data = null;
    this.dataUrl = $('body').data('bubbles-data');
  },
  getData: function(callback) {
    d3.json(this.dataUrl, function(error, data) {
      if (error) throw error;

      this.data = data;

      window.budgetLevels = this.data;

      if (callback) callback();
    }.bind(this));
  }
});
