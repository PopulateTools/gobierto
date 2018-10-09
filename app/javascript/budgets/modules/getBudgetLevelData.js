import * as d3 from 'd3'

export class getBudgetLevelData {
  constructor() {
    this.data = null;
    this.dataUrl = $('body').data('bubbles-data');
  }

  getData(callback) {
    d3.json(this.dataUrl, function(error, data) {
      if (error) throw error;

      this.data = data;

      window.budgetLevels = this.data;

      if (callback) callback();
    }.bind(this));
  }
}
