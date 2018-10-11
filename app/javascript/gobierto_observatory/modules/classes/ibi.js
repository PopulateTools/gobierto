import * as d3 from 'd3'
import { Card } from './card.js'
import { TableCard } from 'lib/visualizations'

export class IbiCard extends Card {
  constructor(divClass, city_id) {
    super(divClass)

    this.placeIbiCUrl = window.populateData.endpoint + '/datasets/ds-ibi-vivienda-urbana-municipal.json?sort_desc_by=date&with_metadata=true&limit=1&filter_by_location_id=' + city_id;
    this.bcnIbiCUrl = window.populateData.endpoint + '/datasets/ds-ibi-vivienda-urbana-municipal.json?sort_desc_by=date&with_metadata=true&limit=1&filter_by_location_id=08019'; // TODO: Use Populate Data's related cities API
    this.vlcIbiCUrl = window.populateData.endpoint + '/datasets/ds-ibi-vivienda-urbana-municipal.json?sort_desc_by=date&with_metadata=true&limit=1&filter_by_location_id=46250';  // TODO: Use Populate Data's related cities API
    this.placeIbiRUrl = window.populateData.endpoint + '/datasets/ds-ibi-vivienda-rustica-municipal.json?sort_desc_by=date&with_metadata=true&limit=1&filter_by_location_id=' + city_id;
    this.bcnIbiRUrl = window.populateData.endpoint + '/datasets/ds-ibi-vivienda-rustica-municipal.json?sort_desc_by=date&with_metadata=true&limit=1&filter_by_location_id=08019'; // TODO: Use Populate Data's related cities API
    this.vlcIbiRUrl = window.populateData.endpoint + '/datasets/ds-ibi-vivienda-rustica-municipal.json?sort_desc_by=date&with_metadata=true&limit=1&filter_by_location_id=46250'; // TODO: Use Populate Data's related cities API
  }

  getData() {
    var placeIbiC = d3.json(this.placeIbiCUrl)
    .header('authorization', 'Bearer ' + this.tbiToken);

    var bcnIbiC = d3.json(this.bcnIbiCUrl)
      .header('authorization', 'Bearer ' + this.tbiToken);

    var vlcIbiC = d3.json(this.vlcIbiCUrl)
      .header('authorization', 'Bearer ' + this.tbiToken);

    var placeIbiR = d3.json(this.placeIbiRUrl)
      .header('authorization', 'Bearer ' + this.tbiToken);

    var bcnIbiR = d3.json(this.bcnIbiRUrl)
      .header('authorization', 'Bearer ' + this.tbiToken);

    var vlcIbiR = d3.json(this.vlcIbiRUrl)
      .header('authorization', 'Bearer ' + this.tbiToken);

    d3.queue()
      .defer(placeIbiC.get)
      .defer(bcnIbiC.get)
      .defer(vlcIbiC.get)
      .defer(placeIbiR.get)
      .defer(bcnIbiR.get)
      .defer(vlcIbiR.get)
      .await(function (error, placeIbiC, bcnIbiC, vlcIbiC, placeIbiR, bcnIbiR, vlcIbiR) {
        if (error) throw error;

        // City tax
        placeIbiC.data.forEach(function(d) {
          d.column = 'first_column';
          d.location_name = window.populateData.municipalityName;
          d.kind = 'city';
        });

        bcnIbiC.data.forEach(function(d) {
          d.column = 'second_column';
          d.location_name = 'Barcelona'
          d.kind = 'city';
        });

        vlcIbiC.data.forEach(function(d) {
          d.column = 'third_column';
          d.location_name = 'Valencia'
          d.kind = 'city';
        });

        // Rustic tax
        placeIbiR.data.forEach(function(d) {
          d.column = 'first_column';
          d.location_name = window.populateData.municipalityName;
          d.kind = 'rustic';
        });

        bcnIbiR.data.forEach(function(d) {
          d.column = 'second_column';
          d.location_name = 'Barcelona';
          d.kind = 'rustic';
        });

        vlcIbiR.data.forEach(function(d) {
          d.column = 'third_column';
          d.location_name = 'Valencia'
          d.kind = 'rustic';
        });

        this.data = placeIbiC.data.concat(bcnIbiC.data, vlcIbiC.data, placeIbiR.data, bcnIbiR.data, vlcIbiR.data);

        this.nest = d3.nest()
          .key(function(d) { return d.location_id; })
          .rollup(function(v) {
            return {
              column: v[0].column,
              key: v[0].location_name,
              valueOne: v.filter(function(d) { return d.kind === 'city' })[0].value,
              valueTwo: v.filter(function(d) { return d.kind === 'rustic' })[0].value,
            }
          })
          .entries(this.data);

        new TableCard(this.container, placeIbiC, this.nest, 'ibi');
      }.bind(this));
  }
}
