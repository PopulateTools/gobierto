import { Class, d3 } from 'shared'
import { SimpleCard } from '../visualizations/vis_card_simple.js'

export var BudgetByInhabitantCard = Class.extend({
  init: function(divClass, city_id) {
    this.container = divClass;
    this.tbiToken = window.populateData.token;
    this.url = window.populateData.endpoint + '/datasets/ds-presupuestos-municipales-total.json?sort_desc_by=date&with_metadata=true&limit=5&filter_by_municipality_id=' + city_id;
  },
  getData: function() {
    var data = d3.json(this.url)
      .header('authorization', 'Bearer ' + this.tbiToken)

    d3.queue()
      .defer(data.get)
      .await(function (error, jsonData) {
        if (error) throw error;

        var value = jsonData.data[0].value_per_inhabitant;

        new SimpleCard(this.container, jsonData, value, 'budget_by_inhabitant', 'value_per_inhabitant');
      }.bind(this));
  },
  render: function() {
    this.getData();
  }
});
