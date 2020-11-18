import { nest } from "d3-collection";
import { Sparkline, SparklineTableCard } from "lib/visualizations";
import { Card } from "./card.js";

export class BirthRateCard extends Card {
  constructor(divClass, city_id) {
    super(divClass);

    this.birthsPlaceUrl =
      window.populateData.endpoint +
      "/datasets/ds-nacimientos-municipal.json?sort_desc_by=date&with_metadata=true&limit=2&filter_by_location_id=" +
      city_id;
    this.birthsProvinceUrl =
      window.populateData.endpoint +
      "/datasets/ds-nacimientos-provincial.json?sort_desc_by=date&with_metadata=true&limit=2&filter_by_location_id=" +
      window.populateData.provinceId;
    this.birthsSpainUrl =
      window.populateData.endpoint +
      "/datasets/ds-nacimientos-nacional.json?sort_desc_by=date&with_metadata=true&limit=2";
    this.popPlaceUrl =
      window.populateData.endpoint +
      "/datasets/ds-poblacion-municipal.json?sort_desc_by=date&limit=2&filter_by_location_id=" +
      city_id;
    this.popProvinceOneUrl =
      window.populateData.endpoint +
      "/datasets/ds-poblacion-municipal/sum.json?sort_desc_by=date&limit=1&filter_by_year=2015&filter_by_province_id=" +
      window.populateData.provinceId;
    this.popProvinceTwoUrl =
      window.populateData.endpoint +
      "/datasets/ds-poblacion-municipal/sum.json?sort_desc_by=date&limit=1&&filter_by_year=2014&filter_by_province_id=" +
      window.populateData.provinceId;
    this.popCountryOneUrl =
      window.populateData.endpoint +
      "/datasets/ds-poblacion-municipal/sum.json?sort_desc_by=date&limit=1&filter_by_year=2015";
    this.popCountryTwoUrl =
      window.populateData.endpoint +
      "/datasets/ds-poblacion-municipal/sum.json?sort_desc_by=date&limit=1&filter_by_year=2014";
  }

  getData() {
    var birthsPlace = this.handlePromise(this.birthsPlaceUrl);
    var birthsProvince = this.handlePromise(this.birthsProvinceUrl);
    var birthsCountry = this.handlePromise(this.birthsSpainUrl);
    var popPlace = this.handlePromise(this.popPlaceUrl);
    var popProvinceOne = this.handlePromise(this.popProvinceOneUrl);
    var popProvinceTwo = this.handlePromise(this.popProvinceTwoUrl);
    var popCountryOne = this.handlePromise(this.popCountryOneUrl);
    var popCountryTwo = this.handlePromise(this.popCountryTwoUrl);

    Promise.all([
      birthsPlace,
      birthsProvince,
      birthsCountry,
      popPlace,
      popProvinceOne,
      popProvinceTwo,
      popCountryOne,
      popCountryTwo
    ]).then(
      ([
        birthsPlace,
        birthsProvince,
        birthsCountry,
        popPlace,
        popProvinceOne,
        popProvinceTwo,
        popCountryOne,
        popCountryTwo
      ]) => {
        var popProvince = [
          {
            date: "2015",
            value: popProvinceOne.sum,
            location_type: "province",
            location_id: window.populateData.provinceId,
            location_name: window.populateData.provinceName
          },
          {
            date: "2014",
            value: popProvinceTwo.sum,
            location_type: "province",
            location_id: window.populateData.provinceId,
            location_name: window.populateData.provinceName
          }
        ];

        var popCountry = [
          {
            date: "2015",
            location_type: "country",
            value: popCountryOne.sum,
            location_name: I18n.t("country")
          },
          {
            date: "2014",
            location_type: "country",
            value: popCountryTwo.sum,
            location_name: I18n.t("country")
          }
        ];

        birthsPlace.data.forEach(function(d, i) {
          d.date = d.date.slice(0, 4);
          d.figure = (d.value / popPlace[i].value) * 1000;
          d.location_type = "place";
        });

        birthsProvince.data.forEach(function(d, i) {
          d.date = d.date.slice(0, 4);
          d.figure = (d.value / popProvince[i].value) * 1000;
          d.location_type = popProvince[i].location_type;
        });

        birthsCountry.data.forEach(function(d, i) {
          d.date = d.date.slice(0, 4);
          d.figure = (d.value / popCountry[i].value) * 1000;
          d.location_type = popCountry[i].location_type;
        });

        this.data = birthsPlace.data.concat(
          birthsProvince.data,
          birthsCountry.data
        );

        // d3v5
        //
        this.nest = nest()
          .key(function(d) {
            return d.location_type;
          })
          .rollup(function(v) {
            return {
              value: v[0].figure,
              diff: ((v[0].figure - v[1].figure) / v[1].figure) * 100
            };
          })
          .entries(this.data);

        this.nest.forEach(
          function(d) {
            (d.key = d.key), (d.diff = d.value.diff), (d.value = d.value.value);
          }.bind(this)
        );

        // d3v6
        //
        // this.nest = rollup(
        //   this.data,
        //   v => ({
        //     value: v[0].figure,
        //     diff: ((v[0].figure - v[1].figure) / v[1].figure) * 100
        //   }),
        //   d => d.location_type
        // );
        // // Convert map to specific array
        // this.nest = Array.from(this.nest, ([key, { value, diff }]) => ({
        //   key,
        //   value,
        //   diff
        // }));

        new SparklineTableCard(
          this.container,
          birthsPlace,
          this.nest,
          "births"
        );

        var place = this.data.filter(d => d.location_type === "place");
        var province = this.data.filter(d => d.location_type === "province");
        var country = this.data.filter(d => d.location_type === "country");

        var opts = {
          trend: this.trend,
          freq: this.freq
        };

        var placeSpark = new Sparkline(
          this.container + " .sparkline-place",
          place,
          opts
        );
        var provinceSpark = new Sparkline(
          this.container + " .sparkline-province",
          province,
          opts
        );
        var countrySpark = new Sparkline(
          this.container + " .sparkline-country",
          country,
          opts
        );

        placeSpark.render();
        provinceSpark.render();
        countrySpark.render();
      }
    );
  }
}
