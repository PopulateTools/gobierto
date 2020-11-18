import { Sparkline, SparklineTableCard } from "lib/visualizations";
import { Card } from "./card.js";

export class DeathRateCard extends Card {
  constructor(divClass, city_id) {
    super(divClass);

    this.deathsPlaceUrl =
      window.populateData.endpoint +
      "/datasets/ds-defunciones-municipal.json?sort_desc_by=date&with_metadata=true&limit=2&filter_by_location_id=" +
      city_id;
    this.deathsProvinceUrl =
      window.populateData.endpoint +
      "/datasets/ds-defunciones-provincial.json?sort_desc_by=date&with_metadata=true&limit=2&filter_by_location_id=" +
      window.populateData.provinceId;
    this.deathsSpainUrl =
      window.populateData.endpoint +
      "/datasets/ds-defunciones-nacional.json?sort_desc_by=date&with_metadata=true&limit=2";
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
    var deathsPlace = this.handlePromise(this.deathsPlaceUrl);
    var deathsProvince = this.handlePromise(this.deathsProvinceUrl);
    var deathsCountry = this.handlePromise(this.deathsSpainUrl);
    var popPlace = this.handlePromise(this.popPlaceUrl);
    var popProvinceOne = this.handlePromise(this.popProvinceOneUrl);
    var popProvinceTwo = this.handlePromise(this.popProvinceTwoUrl);
    var popCountryOne = this.handlePromise(this.popCountryOneUrl);
    var popCountryTwo = this.handlePromise(this.popCountryTwoUrl);

    Promise.all([
      deathsPlace,
      deathsProvince,
      deathsCountry,
      popPlace,
      popProvinceOne,
      popProvinceTwo,
      popCountryOne,
      popCountryTwo
    ]).then(
      ([
        deathsPlace,
        deathsProvince,
        deathsCountry,
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

        deathsPlace.data.forEach(function(d, i) {
          d.date = d.date.slice(0, 4);
          d.figure = (d.value / popPlace[i].value) * 1000;
          d.location_type = "place";
        });

        deathsProvince.data.forEach(function(d, i) {
          d.date = d.date.slice(0, 4);
          d.figure = (d.value / popProvince[i].value) * 1000;
          d.location_type = popProvince[i].location_type;
        });

        deathsCountry.data.forEach(function(d, i) {
          d.date = d.date.slice(0, 4);
          d.figure = (d.value / popCountry[i].value) * 1000;
          d.location_type = popCountry[i].location_type;
        });

        this.data = deathsPlace.data.concat(
          deathsProvince.data,
          deathsCountry.data
        );

        // d3v5
        //
        this.nest = d3
          .nest()
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
          deathsPlace,
          this.nest,
          "deaths"
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
