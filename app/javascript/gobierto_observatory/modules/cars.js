import * as d3 from 'd3'
import { Card } from './card.js'
import { BarsCard } from 'lib/visualizations'

export class CarsCard extends Card {
  constructor(divClass, city_id) {
    super(divClass)

    this.carsPlaceUrl = window.populateData.endpoint + '/datasets/ds-vehiculos-municipales-total.json?sort_desc_by=date&with_metadata=true&limit=1&filter_by_location_id=' + city_id;
    this.carsProvinceUrl = window.populateData.endpoint + '/datasets/ds-vehiculos-provinciales-total.json?sort_desc_by=date&limit=1&filter_by_location_id=' + window.populateData.provinceId;
    this.carsCountryUrl = window.populateData.endpoint + '/datasets/ds-vehiculos-nacionales-total.json?sort_desc_by=date';
    this.popPlaceUrl = window.populateData.endpoint + '/datasets/ds-poblacion-municipal.json?sort_desc_by=date&limit=1&filter_by_location_id=' + city_id;
    this.popProvinceUrl = window.populateData.endpoint + '/datasets/ds-poblacion-municipal/sum.json?sort_desc_by=date&limit=1&&filter_by_year=2015&filter_by_province_id=' + window.populateData.provinceId;
    this.popCountryUrl = window.populateData.endpoint + '/datasets/ds-poblacion-municipal/sum.json?sort_desc_by=date&filter_by_year=2015';
  }

  getData() {
    var carsPlace = d3.json(this.carsPlaceUrl)
      .header('authorization', 'Bearer ' + this.tbiToken);

    var popPlace = d3.json(this.popPlaceUrl)
      .header('authorization', 'Bearer ' + this.tbiToken);

    var carsProvince = d3.json(this.carsProvinceUrl)
      .header('authorization', 'Bearer ' + this.tbiToken);

    var popProvince = d3.json(this.popProvinceUrl)
      .header('authorization', 'Bearer ' + this.tbiToken);

    var carsCountry = d3.json(this.carsCountryUrl)
      .header('authorization', 'Bearer ' + this.tbiToken);

    var popCountry = d3.json(this.popCountryUrl)
      .header('authorization', 'Bearer ' + this.tbiToken);

    d3.queue()
      .defer(carsPlace.get)
      .defer(popPlace.get)
      .defer(carsProvince.get)
      .defer(popProvince.get)
      .defer(carsCountry.get)
      .defer(popCountry.get)
      .await(function (error, carsPlace, popPlace, carsProvince, popProvince, carsCountry, popCountry) {

        carsPlace.data.forEach(function(d) {
          d.date = d.date.slice(0, 4);
          d.figure = d.value / popPlace[0].value;
          d.key = window.populateData.municipalityName;
        });

        carsProvince.forEach(function(d) {
          d.figure = d.value / popProvince.sum;
          d.key = window.populateData.provinceName;
        });

        carsCountry.forEach(function(d) {
          d.figure = d.value / popCountry.sum;
          d.key = I18n.t('country');
        });

        this.data = carsPlace.data.concat(carsProvince, carsCountry);

        new BarsCard(this.container, carsPlace, this.data, 'cars');
      }.bind(this));
  }
}
