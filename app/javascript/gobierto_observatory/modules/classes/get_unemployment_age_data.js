import { sum } from "d3-array";
import { nest } from "d3-collection";
import { timeParse } from "d3-time-format";
import { Card } from "./card.js";

export class GetUnemploymentAgeData extends Card {
  constructor(city_id) {
    super();

    this.popUrl =
      window.populateData.endpoint + `
      SELECT SUM(total::integer) AS value
          FROM poblacion_edad_sexo
          WHERE
            place_id = ${city_id} AND
            year = (SELECT max(year) FROM poblacion_edad_sexo ) AND
            sex = 'Total'
      `
    this.unemplUrl =
      window.populateData.endpoint + `
      SELECT CONCAT(year, '-', month)
        AS Date,
        SUM(value::integer) AS value,
        sex FROM paro_personas
          GROUP BY sex, year, month
    `
    this.parseTime = timeParse("%Y-%m");
    this.data = null;
  }

  getData(callback) {
    var pop = this.handlePromise(this.popUrl);
    var unemployed = this.handlePromise(this.unemplUrl);

    Promise.all([pop, unemployed]).then(([jsonData, unemployed]) => {
      // d3v5
      //
      jsonData.forEach(function(d) {
        d.age = parseInt(d.age)
      })
      var nested = nest()
        .key(function(d) {
          return d.date;
        })
        .rollup(function(v) {
          return {
            "<25": sum(
              v.filter(function(d) {
                return d.age >= 16 && d.age < 25;
              }),
              function(d) {
                return d.value;
              }
            ),
            "25-44": sum(
              v.filter(function(d) {
                return d.age >= 25 && d.age < 45;
              }),
              function(d) {
                return d.value;
              }
            ),
            ">=45": sum(
              v.filter(function(d) {
                return d.age >= 45 && d.age < 65;
              }),
              function(d) {
                return d.value;
              }
            )
          };
        })
        .entries(jsonData);

      var temp = {};
      nested.forEach(function(k) {
        temp[k.key] = k.value;
      });
      nested = temp;

      // d3v6
      //
      // Get population for each group & year
      // var nested = rollup(
      //   jsonData,
      //   v => ({
      //     "<25": sum(v.filter(d => d.age >= 16 && d.age < 25), d => d.value),
      //     "25-44": sum(v.filter(d => d.age >= 25 && d.age < 45), d => d.value),
      //     ">=45": sum(v.filter(d => d.age >= 45 && d.age < 65), d => d.value)
      //   }),
      //   d => d.date
      // );
      // // Convert Map to Object
      // nested = Array.from(nested.entries()).reduce(
      //   (main, [key, value]) => ({ ...main, [key]: value }),
      //   {}
      // );

      // Get the last year from the array
      var lastYear = unemployed[unemployed.length - 1].date.slice(0, 4);

      unemployed.forEach(d => {
        var year = d.date.slice(0, 4);

        if (Object.prototype.hasOwnProperty.call(nested, year)) {
          if (nested[year] === undefined) {
            d.pct = d.value / nested[year - 1][d.age_range];
          } else {
            d.pct = d.value / nested[year][d.age_range];
          }
        } else if (year >= lastYear - 2){
          // If we are in the last year, divide the unemployment by last year's population
          if (nested[year - 1] === undefined) {
            d.pct = d.value / nested[year - 2][d.age_range];
          } else {
            d.pct = d.value / nested[year - 1][d.age_range];
          }
        } else {
          d.pct = null;
        }
        d.date = this.parseTime(d.date);
      });

      // Filtering values to start from the first data points
      this.data = unemployed.filter(
        d => d.age_range != "<25" && d.date >= this.parseTime("2011-01")
      );

      window.unemplAgeData = this.data;

      if (callback) callback();
    });
  }
}
