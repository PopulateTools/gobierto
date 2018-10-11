import * as d3 from 'd3'
import { Card } from './card.js'
import { TableCard } from 'lib/visualizations'

export class IncomeCard extends Card {
  constructor(divClass, city_id) {
    super(divClass)

    this.placeGrossUrl = window.populateData.endpoint + '/datasets/ds-renta-bruta-media-municipal.json?sort_desc_by=date&with_metadata=true&limit=1&filter_by_location_id=' + city_id;
    this.bcnGrossUrl = window.populateData.endpoint + '/datasets/ds-renta-bruta-media-municipal.json?sort_desc_by=date&with_metadata=true&limit=1&filter_by_location_id=08019'; // TODO: Use Populate Data's related cities API
    this.vlcGrossUrl = window.populateData.endpoint + '/datasets/ds-renta-bruta-media-municipal.json?sort_desc_by=date&with_metadata=true&limit=1&filter_by_location_id=46250';  // TODO: Use Populate Data's related cities API
    this.placeNetUrl = window.populateData.endpoint + '/datasets/ds-renta-disponible-media-municipal.json?sort_desc_by=date&with_metadata=true&limit=1&filter_by_location_id=' + city_id;
    this.bcnNetUrl = window.populateData.endpoint + '/datasets/ds-renta-disponible-media-municipal.json?sort_desc_by=date&with_metadata=true&limit=1&filter_by_location_id=08019'; // TODO: Use Populate Data's related cities API
    this.vlcNetUrl = window.populateData.endpoint + '/datasets/ds-renta-disponible-media-municipal.json?sort_desc_by=date&with_metadata=true&limit=1&filter_by_location_id=46250'; // TODO: Use Populate Data's related cities API
  }

  getData() {
    var placeGross = d3.json(this.placeGrossUrl)
    .header('authorization', 'Bearer ' + this.tbiToken);

    var bcnGross = d3.json(this.bcnGrossUrl)
      .header('authorization', 'Bearer ' + this.tbiToken);

    var vlcGross = d3.json(this.vlcGrossUrl)
      .header('authorization', 'Bearer ' + this.tbiToken);

    var placeNet = d3.json(this.placeNetUrl)
      .header('authorization', 'Bearer ' + this.tbiToken);

    var bcnNet = d3.json(this.bcnNetUrl)
      .header('authorization', 'Bearer ' + this.tbiToken);

    var vlcNet = d3.json(this.vlcNetUrl)
      .header('authorization', 'Bearer ' + this.tbiToken);

    d3.queue()
      .defer(placeGross.get)
      .defer(bcnGross.get)
      .defer(vlcGross.get)
      .defer(placeNet.get)
      .defer(bcnNet.get)
      .defer(vlcNet.get)
      .await(function (error, placeGross, bcnGross, vlcGross, placeNet, bcnNet, vlcNet) {
        if (error) throw error;

        // Gross
        placeGross.data.forEach(function(d) {
          d.column = 'first_column';
          d.location_name = window.populateData.municipalityName;
          d.kind = 'gross';
        });

        bcnGross.data.forEach(function(d) {
          d.column = 'second_column';
          d.location_name = 'Barcelona'
          d.kind = 'gross';
        });

        vlcGross.data.forEach(function(d) {
          d.column = 'third_column';
          d.location_name = 'Valencia'
          d.kind = 'gross';
        });

        // Net
        placeNet.data.forEach(function(d) {
          d.column = 'first_column';
          d.location_name = window.populateData.municipalityName;
          d.kind = 'net';
        });

        bcnNet.data.forEach(function(d) {
          d.column = 'second_column';
          d.location_name = 'Barcelona';
          d.kind = 'net';
        });

        vlcNet.data.forEach(function(d) {
          d.column = 'third_column';
          d.location_name = 'Valencia'
          d.kind = 'net';
        });

        this.data = placeGross.data.concat(bcnGross.data, vlcGross.data, placeNet.data, bcnNet.data, vlcNet.data);

        this.nest = d3.nest()
          .key(function(d) { return d.location_id; })
          .rollup(function(v) {
            return {
              column: v[0].column,
              key: v[0].location_name,
              valueOne: v.filter(function(d) { return d.kind === 'gross' })[0].value,
              valueTwo: v.filter(function(d) { return d.kind === 'net' })[0].value,
            }
          })
          .entries(this.data);

        new TableCard(this.container, placeGross, this.nest, 'income');
      }.bind(this));
  }
}
