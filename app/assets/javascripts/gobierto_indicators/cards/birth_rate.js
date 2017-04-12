'use strict';

var BirthRateCard = Class.extend({
  init: function(divClass, city_id) {
    this.container = divClass;
    this.tbiToken = window.populateData.token;
    this.url = window.populateData.endpoint + '/datasets/ds-nacimientos-municipal.json?sort_desc_by=date&with_metadata=true&limit=2&filter_by_location_id=' + city_id;
    this.popUrl = window.populateData.endpoint + '/datasets/ds-poblacion-municipal.json?sort_desc_by=date&with_metadata=true&limit=2&filter_by_location_id=' + city_id;
    // this.provinceUrl = window.populateData.endpoint + '/datasets/ds-nacimientos-municipal.json?sort_desc_by=date&with_metadata=true&limit=2&filter_by_location_id=' + city_id.slice(0, 2);
    // this.spainUrl = window.populateData.endpoint + '/datasets/ds-nacimientos-municipal.json?sort_desc_by=date&with_metadata=true&limit=2&filter_by_location_id=' + city_id;
  },
  getData: function() {
    var data = d3.json(this.url)
      .header('authorization', 'Bearer ' + this.tbiToken);
      
    var pop = d3.json(this.popUrl)
      .header('authorization', 'Bearer ' + this.tbiToken);
    
    // var province = d3.json(this.popUrl)
    //   .header('authorization', 'Bearer ' + this.tbiToken);
    // 
    // var spain = d3.json(this.popUrl)
    //   .header('authorization', 'Bearer ' + this.tbiToken);

    d3.queue()
      .defer(data.get)
      .defer(pop.get)
      .await(function (error, jsonData, jsonPop) {
        if (error) throw error;
        
        
        var birthRate = jsonData.data[0].value / jsonPop.data[0].value;
        
        console.log(jsonData);
        console.log(jsonPop);
        
        // var value = jsonActive.data[0].value;
        // var rate = value / jsonPop.data[0].value * 100;
        
        // new SparklineTableCard(this.container, jsonActive, rate, value);
      }.bind(this));
  },
  render: function() {
    this.getData();
  }
});
