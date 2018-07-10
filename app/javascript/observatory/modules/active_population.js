import { Class, d3 } from 'shared'
import { ComparisonCard } from './vis_card_comparison.js'

export var ActivePopulationCard = Class.extend({
  init: function(divClass, city_id) {
    this.container = divClass;
    this.tbiToken = window.populateData.token;
    this.activePopUrl = window.populateData.endpoint + '/datasets/ds-poblacion-activa-municipal.json?sort_desc_by=date&with_metadata=true&limit=5&filter_by_location_id=' + city_id;
    this.popUrl = window.populateData.endpoint + '/datasets/ds-poblacion-municipal.json?sort_desc_by=date&with_metadata=true&limit=5&filter_by_location_id=' + city_id;
  },
  getData: function() {
    var active = d3.json(this.activePopUrl)
      .header('authorization', 'Bearer ' + this.tbiToken);

    var pop = d3.json(this.popUrl)
      .header('authorization', 'Bearer ' + this.tbiToken);

    d3.queue()
      .defer(active.get)
      .defer(pop.get)
      .await(function (error, jsonActive, jsonPop) {
        if (error) throw error;

        var value = jsonActive.data[0].value;
        var rate = value / jsonPop.data[0].value * 100;

        new ComparisonCard(this.container, jsonActive, rate, value, 'active_pop');
      }.bind(this));
  },
  render: function() {
    this.getData();
  }
});
