'use strict';

var IncomeCard = Class.extend({
  init: function(divClass, city_id) {
    this.container = divClass;
    this.div = d3.select(this.container);
    this.tbiToken = window.populateData.token;
    this.placeGrossUrl = window.populateData.endpoint + '/datasets/ds-renta-bruta-media-municipal.json?sort_desc_by=date&with_metadata=true&limit=1&filter_by_location_id=' + city_id;
    this.provinceGrossUrl = window.populateData.endpoint + '/datasets/ds-renta-bruta-media-provincial.json?sort_desc_by=date&with_metadata=true&limit=1&filter_by_location_id=' + window.populateData.provinceId;
    this.countryGrossUrl = window.populateData.endpoint + '/datasets/ds-renta-bruta-media-nacional.json?sort_desc_by=date&with_metadata=true&limit=1';
    this.placeNetUrl = window.populateData.endpoint + '/datasets/ds-renta-disponible-media-municipal.json?sort_desc_by=date&with_metadata=true&limit=1&filter_by_location_id=' + city_id;
    this.provinceNetUrl = window.populateData.endpoint + '/datasets/ds-renta-disponible-media-provincial.json?sort_desc_by=date&with_metadata=true&limit=1&filter_by_location_id=' + window.populateData.provinceId;
    this.countryNetUrl = window.populateData.endpoint + '/datasets/ds-renta-disponible-media-nacional.json?sort_desc_by=date&with_metadata=true&limit=1';
    this.trend = this.div.attr('data-trend');
    this.freq = this.div.attr('data-freq');
  },
  getData: function() {
    var placeGross = d3.json(this.placeGrossUrl)
    .header('authorization', 'Bearer ' + this.tbiToken);

    var provinceGross = d3.json(this.provinceGrossUrl)
      .header('authorization', 'Bearer ' + this.tbiToken);
    
    var countryGross = d3.json(this.countryGrossUrl)
      .header('authorization', 'Bearer ' + this.tbiToken);

    var placeNet = d3.json(this.placeNetUrl)
      .header('authorization', 'Bearer ' + this.tbiToken);

    var provinceNet = d3.json(this.provinceNetUrl)
      .header('authorization', 'Bearer ' + this.tbiToken);

    var countryNet = d3.json(this.countryNetUrl)
      .header('authorization', 'Bearer ' + this.tbiToken);

    d3.queue()
      .defer(placeGross.get)
      .defer(provinceGross.get)
      .defer(countryGross.get)
      .defer(placeNet.get)
      .defer(provinceNet.get)
      .defer(countryNet.get)
      .await(function (error, placeGross, provinceGross, countryGross, placeNet, provinceNet, countryNet) {
        if (error) throw error;
        
        // Gross
        placeGross.data.forEach(function(d) {
          d.location_type = 'place';
          d.location_name = window.populateData.municipalityName;
          d.kind = 'gross';
        });
        
        provinceGross.data.forEach(function(d) {
          d.location_type = 'province';
          d.location_name = window.populateData.provinceName;
          d.kind = 'gross';
        });
        
        countryGross.data.forEach(function(d) {
          d.location_type = 'country';
          d.location_name = I18n.t('country');
          d.kind = 'gross';
        });
        
        // Net
        placeNet.data.forEach(function(d) {
          d.location_type = 'place';
          d.location_name = window.populateData.municipalityName;
          d.kind = 'net';
        });
        
        provinceNet.data.forEach(function(d) {
          d.location_type = 'province';
          d.location_name = window.populateData.provinceName;
          d.kind = 'net';
        });
        
        countryNet.data.forEach(function(d) {
          d.location_type = 'country';
          d.location_name = I18n.t('country');
          d.kind = 'net';
        });
        
        this.data = placeGross.data.concat(provinceGross.data, countryGross.data, placeNet.data, provinceNet.data, countryNet.data);

        this.nest = d3.nest()
          .key(function(d) { return d.location_id; })
          .rollup(function(v) {
            return {
              column: v[0].location_type,
              key: v[0].location_name,
              valueOne: v.filter(function(d) { return d.kind === 'gross' })[0].value,
              valueTwo: v.filter(function(d) { return d.kind === 'net' })[0].value,
            }
          })
          .entries(this.data);

        new TableCard(this.container, placeGross, this.nest, 'income');
      }.bind(this));
  },
  render: function() {
    this.getData();
  }
});
