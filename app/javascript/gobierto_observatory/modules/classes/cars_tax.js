import * as d3 from 'd3'
import { Card } from './card.js'
import { ComparisonCard } from 'lib/visualizations'

export class CarsTaxCard extends Card {
  constructor(divClass, city_id) {
    super(divClass)

    this.placeTaxUrl = window.populateData.endpoint + '/datasets/ds-impuestos-turismos-municipal.json?sort_desc_by=date&with_metadata=true&limit=1&filter_by_location_id=' + city_id;
    this.provinceTaxUrl = window.populateData.endpoint + '/datasets/ds-impuestos-turismos-municipal/average.json?sort_desc_by=date&with_metadata=true&limit=1&filter_by_province_id=' + window.populateData.provinceId;
  }

  getData() {
    var placeTax = d3.json(this.placeTaxUrl)
    .header('authorization', 'Bearer ' + this.tbiToken);

    var provinceTax = d3.json(this.provinceTaxUrl)
      .header('authorization', 'Bearer ' + this.tbiToken);

    d3.queue()
      .defer(placeTax.get)
      .defer(provinceTax.get)
      .await(function (error, placeTax, provinceTax) {
        if (error) throw error;

        var valueOne = placeTax.data[0].value;
        var valueTwo = provinceTax.average;

        new ComparisonCard(this.container, placeTax, valueOne, valueTwo, 'cars_tax');
      }.bind(this));
  }
}
