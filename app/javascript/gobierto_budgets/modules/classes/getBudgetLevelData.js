import * as d3 from 'd3'
import { Card } from './card.js'

export class getBudgetLevelData extends Card {
  constructor() {
    super()

    this.data = null;
    this.dataUrl = $('body').data('bubbles-data');
  }

  getData(callback) {
    if (this.dataUrl) {      
      d3.json(this.dataUrl, function(error, data) {
        if (error) throw error;

        this.data = data;

        window.budgetLevels = this.data;

        if (callback) callback();
      }.bind(this));
    }
  }
}
