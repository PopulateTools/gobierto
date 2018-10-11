import * as d3 from 'd3'
import { Card } from './card.js'
import { Sparkline, SparklineTableCard } from 'lib/visualizations'

export class DeathRateCard extends Card {
  constructor(divClass, city_id) {
    super(divClass)

    this.deathsPlaceUrl = window.populateData.endpoint + '/datasets/ds-defunciones-municipal.json?sort_desc_by=date&with_metadata=true&limit=2&filter_by_location_id=' + city_id;
    this.deathsProvinceUrl = window.populateData.endpoint + '/datasets/ds-defunciones-provincial.json?sort_desc_by=date&with_metadata=true&limit=2&filter_by_location_id=' + window.populateData.provinceId;
    this.deathsSpainUrl = window.populateData.endpoint + '/datasets/ds-defunciones-nacional.json?sort_desc_by=date&with_metadata=true&limit=2';
    this.popPlaceUrl = window.populateData.endpoint + '/datasets/ds-poblacion-municipal.json?sort_desc_by=date&limit=2&filter_by_location_id=' + city_id;
    this.popProvinceOneUrl = window.populateData.endpoint + '/datasets/ds-poblacion-municipal/sum.json?sort_desc_by=date&limit=1&filter_by_year=2015&filter_by_province_id=' + window.populateData.provinceId;
    this.popProvinceTwoUrl = window.populateData.endpoint + '/datasets/ds-poblacion-municipal/sum.json?sort_desc_by=date&limit=1&&filter_by_year=2014&filter_by_province_id=' + window.populateData.provinceId;
    this.popCountryOneUrl = window.populateData.endpoint + '/datasets/ds-poblacion-municipal/sum.json?sort_desc_by=date&limit=1&filter_by_year=2015';
    this.popCountryTwoUrl = window.populateData.endpoint + '/datasets/ds-poblacion-municipal/sum.json?sort_desc_by=date&limit=1&filter_by_year=2014';
  }

  getData() {
    var deathsPlace = d3.json(this.deathsPlaceUrl)
      .header('authorization', 'Bearer ' + this.tbiToken);

    var deathsProvince = d3.json(this.deathsProvinceUrl)
      .header('authorization', 'Bearer ' + this.tbiToken);

    var deathsCountry = d3.json(this.deathsSpainUrl)
      .header('authorization', 'Bearer ' + this.tbiToken);

    var popPlace = d3.json(this.popPlaceUrl)
      .header('authorization', 'Bearer ' + this.tbiToken);

    var popProvinceOne = d3.json(this.popProvinceOneUrl)
      .header('authorization', 'Bearer ' + this.tbiToken);

    var popProvinceTwo = d3.json(this.popProvinceTwoUrl)
      .header('authorization', 'Bearer ' + this.tbiToken);

    var popCountryOne = d3.json(this.popCountryOneUrl)
      .header('authorization', 'Bearer ' + this.tbiToken);

    var popCountryTwo = d3.json(this.popCountryTwoUrl)
      .header('authorization', 'Bearer ' + this.tbiToken);

    d3.queue()
      .defer(deathsPlace.get)
      .defer(deathsProvince.get)
      .defer(deathsCountry.get)
      .defer(popPlace.get)
      .defer(popProvinceOne.get)
      .defer(popProvinceTwo.get)
      .defer(popCountryOne.get)
      .defer(popCountryTwo.get)
      .await(function (error, deathsPlace, deathsProvince, deathsCountry, popPlace, popProvinceOne, popProvinceTwo, popCountryOne, popCountryTwo) {
        if (error) throw error;

        var popProvince = [
          {
            date: '2015',
            value: popProvinceOne.sum,
            location_type: 'province',
            location_id: window.populateData.provinceId,
            location_name: window.populateData.provinceName
          },
          {
            date: '2014',
            value: popProvinceTwo.sum,
            location_type: 'province',
            location_id: window.populateData.provinceId,
            location_name: window.populateData.provinceName
          }
        ]

        var popCountry = [
          {
            date: '2015',
            location_type: 'country',
            value: popCountryOne.sum,
            location_name: I18n.t('country')
          },
          {
            date: '2014',
            location_type: 'country',
            value: popCountryTwo.sum,
            location_name: I18n.t('country')
          }
        ]

        deathsPlace.data.forEach(function(d, i) {
          d.date = d.date.slice(0, 4);
          d.figure = d.value / popPlace[i].value * 1000;
          d.location_type = 'place';
        });

        deathsProvince.data.forEach(function(d, i) {
          d.date = d.date.slice(0, 4);
          d.figure = d.value / popProvince[i].value * 1000;
          d.location_type = popProvince[i].location_type;
        });

        deathsCountry.data.forEach(function(d, i) {
          d.date = d.date.slice(0, 4);
          d.figure = d.value / popCountry[i].value * 1000;
          d.location_type = popCountry[i].location_type;
        });

        this.data = deathsPlace.data.concat(deathsProvince.data, deathsCountry.data);

        this.nest = d3.nest()
          .key(function(d) { return d.location_type; })
          .rollup(function(v) { return {
              value: v[0].figure,
              diff: (v[0].figure - v[1].figure) / v[1].figure * 100,
            };
          })
          .entries(this.data);

        this.nest.forEach(function(d) {
          d.key = d.key,
          d.diff = d.value.diff,
          d.value = d.value.value
        }.bind(this));

        new SparklineTableCard(this.container, deathsPlace, this.nest, 'deaths');

        var place = this.data.filter(function(d) { return d.location_type === 'place'; });
        var province = this.data.filter(function(d) { return d.location_type === 'province'; });
        var country = this.data.filter(function(d) { return d.location_type === 'country'; });

        var placeSpark = new Sparkline(this.container + ' .sparkline-place', place, this.trend, this.freq);
        var provinceSpark = new Sparkline(this.container + ' .sparkline-province', province, this.trend, this.freq);
        var countrySpark = new Sparkline(this.container + ' .sparkline-country', country, this.trend, this.freq);

        placeSpark.render();
        provinceSpark.render();
        countrySpark.render();
      }.bind(this));
  }
}
