import { Class, d3 } from 'shared'
import { SimpleCard } from '../visualizations/vis_card_simple.js'

export var PopulationCard = Class.extend({
  init: function(divClass, city_id) {
    this.container = divClass;
    this.tbiToken = window.populateData.token;
    this.popUrl = window.populateData.endpoint + '/datasets/ds-poblacion-municipal.json?sort_desc_by=date&with_metadata=true&limit=5&filter_by_location_id=' + city_id;
  },
  getData: function() {
    var pop = d3.json(this.popUrl)
      .header('authorization', 'Bearer ' + this.tbiToken)

    d3.queue()
      .defer(pop.get)
      .await(function (error, jsonData) {
        if (error) throw error;

        var value = jsonData.data[0].value;

        new SimpleCard(this.container, jsonData, value, 'population');
      }.bind(this));
  },
  render: function() {
    this.getData();
  }
});
