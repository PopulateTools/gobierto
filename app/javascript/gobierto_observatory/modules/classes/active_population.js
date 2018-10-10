import * as d3 from 'd3'
import { Card } from './card.js'
import { ComparisonCard } from 'lib/visualizations'

export class ActivePopulationCard extends Card {
  constructor(divClass, city_id) {
    super(divClass);

    this.activePopUrl = window.populateData.endpoint + '/datasets/ds-poblacion-activa-municipal.json?sort_desc_by=date&with_metadata=true&limit=5&filter_by_location_id=' + city_id;
    this.popUrl = window.populateData.endpoint + '/datasets/ds-poblacion-municipal.json?sort_desc_by=date&with_metadata=true&limit=5&filter_by_location_id=' + city_id;
  }

  getData() {
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
  }
}
