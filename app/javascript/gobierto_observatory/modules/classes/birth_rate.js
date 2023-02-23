import { nest } from "d3-collection";
import { Sparkline, SparklineTableCard } from "lib/visualizations";
import { Card } from "./card.js";

export class BirthRateCard extends Card {
  constructor(divClass, city_id) {
    super(divClass);

    this.birthsPlaceUrl =
      window.populateData.endpoint +
      `
      SELECT year, SUM(value::integer) AS value,
        CONCAT(year, '-', 1, '-', 1) AS date
      FROM tasa_natalidad
      WHERE
        place_id = ${city_id}
      GROUP BY year
      Order BY year DESC limit 5
      `
    this.birthsProvinceUrl =
      window.populateData.endpoint +
      `
      SELECT year, SUM(value::integer) AS value,
        CONCAT(year, '-', 1, '-', 1) AS date
        FROM tasa_natalidad
        WHERE
          place_id = ${window.populateData.provinceId}
        GROUP BY year
        Order BY year DESC limit 5
      `
    this.birthsSpainUrl =
      window.populateData.endpoint +
      `
      SELECT year, SUM(value::integer) AS value,
        CONCAT(year, '-', 1, '-', 1) AS date
        FROM tasa_natalidad
        GROUP BY year
        Order BY year DESC limit 5
      `
    this.popPlaceUrl =
      window.populateData.endpoint +
      `
      SELECT year, SUM(total::integer) AS value,
      CONCAT(max(year), '-', 1, '-', 1) AS date
      FROM poblacion_edad_sexo
      WHERE
        place_id = ${city_id} AND
        sex = 'Total'
      GROUP BY year
      Order BY year DESC limit 5
      `
    this.popProvinceOneUrl =
      window.populateData.endpoint +
      `
      SELECT year, AVG(total::integer) AS value,
      CONCAT(max(year), '-', 1, '-', 1) AS date
        FROM poblacion_edad_sexo
        WHERE
          place_id = ${window.populateData.provinceId} AND
          sex = 'Total'
        GROUP BY year
        Order BY year DESC limit 5
      `
    this.popProvinceTwoUrl =
      window.populateData.endpoint +
      `
      SELECT year, AVG(total::integer) AS value,
      CONCAT(max(year), '-', 1, '-', 1) AS date
        FROM poblacion_edad_sexo
        GROUP BY year
        Order BY year DESC limit 5
      `
    this.popCountryOneUrl =
      window.populateData.endpoint +
      `
      SELECT year, SUM(total::integer) AS value,
      CONCAT(max(year), '-', 1, '-', 1) AS date
        FROM poblacion_edad_sexo
        WHERE year = 2015
        GROUP BY year
        Order BY year DESC limit 5
      `
    this.popCountryTwoUrl =
      window.populateData.endpoint +
      `
      SELECT year, SUM(total::integer) AS value,
      CONCAT(max(year), '-', 1, '-', 1) AS date
        FROM poblacion_edad_sexo
        WHERE year = 2014
        GROUP BY year
        Order BY year DESC limit 5
      `
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
