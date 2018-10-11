import * as d3 from 'd3'
import { Card } from './card.js'
import { ComparisonCard } from 'lib/visualizations'

export class IncomeOverviewCard extends Card {
  constructor(divClass) {
    super(divClass)

    this.incomeProvinceUrl = window.populateData.endpoint + '/datasets/ds-renta-bruta-media-provincial.json?sort_desc_by=date&with_metadata=true&limit=1&filter_by_location_id=' + window.populateData.provinceId;
    this.incomeCountryUrl = window.populateData.endpoint + '/datasets/ds-renta-bruta-media-nacional.json?sort_desc_by=date&with_metadata=true&limit=1';
  }

  getData() {
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
  }
}
