import * as d3 from 'd3'
import { Class } from 'shared'
import { SimpleCard } from './vis_card_simple.js'

export var TaxAutonomyCard = Class.extend({
  init: function(divClass, city_id, current_year) {
    this.container = divClass;
    this.currentYear = (current_year !== undefined) ? parseInt(current_year) : null;
    this.tbiToken = window.populateData.token;
    this.popUrl = window.populateData.endpoint + '/datasets/ds-autonomia-fiscal.json?sort_desc_by=date&with_metadata=true&limit=5&filter_by_municipality_id=' + city_id + '&date_date_range=20100101-' + this.currentYear + '1231';
  },
  getData: function() {
    var pop = d3.json(this.popUrl)
      .header('authorization', 'Bearer ' + this.tbiToken)

    d3.queue()
      .defer(pop.get)
      .await(function (error, jsonData) {
        if (error) throw error;

        var value = jsonData.data[0].value;

        new SimpleCard(this.container, jsonData, value, 'tax_autonomy');
      }.bind(this));
  },
  render: function() {
    this.getData();
  }
});
