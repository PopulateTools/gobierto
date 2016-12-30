'use strict';

var VisUnemploymentAge = Class.extend({
  init: function(divId, city_id, current_year) {
    this.container = divId;
    this.currentYear = (current_year !== undefined) ? parseInt(current_year) : null;
    this.data = null;
    this.tbiToken = window.tbiToken;
    this.popUrl = 'https://tbi.populate.tools/gobierto/datasets/ds-poblacion-municipal-edad.json?include=municipality&filter_by_year=' + current_year + '&filter_by_location_id=' + city_id;
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
        
        var less_25 = jsonData
          .filter(function(d) {
            return d.age >= 16 && d.age < 25
          })
          .reduce(function(a, b) {
            return a + b.value
          }, 0);
          
        // console.log(jsonData)
        // console.log(less_25)
        
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
