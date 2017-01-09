'use strict';

var VisUnemploymentAge = Class.extend({
  init: function(divId, city_id, current_year) {
    this.container = divId;
    this.currentYear = (current_year !== undefined) ? parseInt(current_year) : null;
    this.data = null;
    this.tbiToken = window.tbiToken;
    this.popUrl = 'https://tbi.populate.tools/gobierto/datasets/ds-poblacion-municipal-edad.json?sort_asc_by=date&filter_by_location_id=' + city_id;
    this.unemplUrl = 'https://tbi.populate.tools/gobierto/datasets/ds-personas-paradas-municipio-edad.json?sort_asc_by=date&filter_by_location_id=' + city_id;
  },
  getData: function() {
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

        unemployed.forEach(function(d) {
          var year = d.date.slice(0,4);
          if(nested.hasOwnProperty(year)) {
            d.pct = d.value / nested[year][d.age_range];
          } else {
            d.pct = null;
          }
        });

      }.bind(this));
  },
  render: function() {
    if (this.data === null) {
      this.getData();
    } else {
      this.updateRender();
    }
  },
  updateRender: function(callback) {
  },
  _renderAxis: function() {
  },
  _formatNumberX: function(d) {
  },
  _formatNumberY: function(d) {
  },
  _width: function() {
  },
  _height: function() {
  },
  _resize: function() {
  }
});
