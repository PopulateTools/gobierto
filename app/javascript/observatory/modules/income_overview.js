import { Class, d3 } from 'shared'
import { ComparisonCard } from './vis_card_comparison.js'

export var IncomeOverviewCard = Class.extend({
  init: function(divClass) {
    this.container = divClass;
    this.div = d3.select(this.container);
    this.tbiToken = window.populateData.token;
    this.incomeProvinceUrl = window.populateData.endpoint + '/datasets/ds-renta-bruta-media-provincial.json?sort_desc_by=date&with_metadata=true&limit=1&filter_by_location_id=' + window.populateData.provinceId;
    this.incomeCountryUrl = window.populateData.endpoint + '/datasets/ds-renta-bruta-media-nacional.json?sort_desc_by=date&with_metadata=true&limit=1';
    this.trend = this.div.attr('data-trend');
    this.freq = this.div.attr('data-freq');
  },
  getData: function() {
    var incomeProvince = d3.json(this.incomeProvinceUrl)
    .header('authorization', 'Bearer ' + this.tbiToken);

    var incomeCountry = d3.json(this.incomeCountryUrl)
      .header('authorization', 'Bearer ' + this.tbiToken);

    d3.queue()
      .defer(incomeProvince.get)
      .defer(incomeCountry.get)
      .await(function (error, incomeProvince, incomeCountry) {
        if (error) throw error;

        var valueOne = incomeProvince.data[0].value;
        var valueTwo = incomeCountry.data[0].value;

        new ComparisonCard(this.container, incomeProvince, valueOne, valueTwo, 'income_overview');
      }.bind(this));
  },
  render: function() {
    this.getData();
  }
});
