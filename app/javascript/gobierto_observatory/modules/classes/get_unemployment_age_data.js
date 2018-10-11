import * as d3 from 'd3'
import { Card } from './card.js'

export class GetUnemploymentAgeData extends Card {
  constructor(city_id) {
    super()
    
    this.popUrl = window.populateData.endpoint + '/datasets/ds-poblacion-municipal-edad.json?sort_asc_by=date&filter_by_location_id=' + city_id;
    this.unemplUrl = window.populateData.endpoint + '/datasets/ds-personas-paradas-municipio-edad.json?sort_asc_by=date&filter_by_location_id=' + city_id;
    this.parseTime = d3.timeParse('%Y-%m');
    this.data = null;
  }

  getData(callback) {
    var pop = d3.json(this.popUrl)
      .header('authorization', 'Bearer ' + this.tbiToken)

    var unemployed = d3.json(this.unemplUrl)
      .header('authorization', 'Bearer ' + this.tbiToken)

    d3.queue()
      .defer(pop.get)
      .defer(unemployed.get)
      .await(function (error, jsonData, unemployed) {
        if (error) throw error;

        // Get population for each group & year
        var nested = d3.nest()
          .key(function(d) { return d.date; })
          .rollup(function(v) { return {
              '<25': d3.sum(v.filter(function(d) {return d.age >= 16 && d.age < 25}), function(d) { return d.value; }),
              '25-44': d3.sum(v.filter(function(d) {return d.age >= 25 && d.age < 45}), function(d) { return d.value; }),
              '>=45': d3.sum(v.filter(function(d) {return d.age >= 45 && d.age < 65}), function(d) { return d.value; }),
            };
          })
          .entries(jsonData);

        var temp = {};
        nested.forEach(function(k) {
          temp[k.key] = k.value
        });
        nested = temp;

        // Get the last year from the array
        var lastYear = unemployed[unemployed.length - 1].date.slice(0,4);

        unemployed.forEach(function(d) {
          var year = d.date.slice(0,4);

          if (nested.hasOwnProperty(year)) {
            d.pct = d.value / nested[year][d.age_range];
          } else if(year === lastYear) {
            // If we are in the last year, divide the unemployment by last year's population
            d.pct = d.value / nested[year - 1][d.age_range];
          } else {
            d.pct = null;
          }
          d.date = this.parseTime(d.date);
        }.bind(this));

        // Filtering values to start from the first data points
        this.data = unemployed.filter(function(d) { return d.age_range != '<25' && d.date >=this.parseTime('2011-01') }.bind(this));

        window.unemplAgeData = this.data;

        if (callback) callback();
      }.bind(this));
  }
}
