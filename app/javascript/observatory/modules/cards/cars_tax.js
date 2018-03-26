import { Class, d3 } from 'shared'
import { ComparisonCard } from '../visualizations/vis_card_comparision.js'

export var CarsTaxCard = Class.extend({
  init: function(divClass, city_id) {
    this.container = divClass;
    this.div = d3.select(this.container);
    this.tbiToken = window.populateData.token;
    this.placeTaxUrl = window.populateData.endpoint + '/datasets/ds-impuestos-turismos-municipal.json?sort_desc_by=date&with_metadata=true&limit=1&filter_by_location_id=' + city_id;
    this.provinceTaxUrl = window.populateData.endpoint + '/datasets/ds-impuestos-turismos-municipal/average.json?sort_desc_by=date&with_metadata=true&limit=1&filter_by_province_id=' + window.populateData.provinceId;
    this.trend = this.div.attr('data-trend');
    this.freq = this.div.attr('data-freq');
  },
  getData: function() {
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
  },
  render: function() {
    this.getData();
  }
});
