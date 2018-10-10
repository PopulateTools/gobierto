import * as d3 from 'd3'
import { Card } from './card.js'
import { ComparisonCard } from 'lib/visualizations'

export class ContractsCard extends Card {
  constructor(divClass, city_id) {
    super(divClass)

    this.url = window.populateData.endpoint + '/datasets/ds-contratos-municipio-tipo.json?sort_desc_by=date&with_metadata=true&limit=3&filter_by_location_id=' + city_id;
  }

  getData() {
    var data = d3.json(this.url)
      .header('authorization', 'Bearer ' + this.tbiToken);

    d3.queue()
      .defer(data.get)
      .await(function (error, json) {
        if (error) throw error;

        var nest = d3.nest()
          .key(function(d) { return d.type; })
          .entries(json.data);

        var i = nest.filter(function(d) { return d.key === 'INI-I'; })[0].values[0].value;
        var t = nest.filter(function(d) { return d.key === 'INI-T'; })[0].values[0].value;

        new ComparisonCard(this.container, json, t, i, 'contracts_comparison');
      }.bind(this));
  }
}
