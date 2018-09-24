import * as d3 from 'd3'
import { Sparkline } from './vis_sparkline.js'
import { SparklineTableCard } from './vis_card_sparkline_table.js'
import { Class } from 'shared'

export var InvestmentByInhabitantCard = Class.extend({
  init: function(divClass, city_id) {
    this.container = divClass;
    this.div = d3.select(this.container);
    this.tbiToken = window.populateData.token;
    this.url = window.populateData.endpoint + '/datasets/ds-inversion-por-habitante.json?sort_desc_by=date&with_metadata=true&limit=2&filter_by_municipality_id=' + city_id;
    this.bcnUrl = window.populateData.endpoint + '/datasets/ds-inversion-por-habitante.json?sort_desc_by=date&with_metadata=true&limit=2&filter_by_municipality_id=08019';  // TODO: Use Populate Data's related cities API
    this.vlcUrl = window.populateData.endpoint + '/datasets/ds-inversion-por-habitante.json?sort_desc_by=date&with_metadata=true&limit=2&filter_by_municipality_id=46250';  // TODO: Use Populate Data's related cities API
    this.trend = this.div.attr('data-trend');
    this.freq = this.div.attr('data-freq');
  },
  getData: function() {
    var data = d3.json(this.url)
      .header('authorization', 'Bearer ' + this.tbiToken);

    var bcn = d3.json(this.bcnUrl)
      .header('authorization', 'Bearer ' + this.tbiToken);

    var vlc = d3.json(this.vlcUrl)
      .header('authorization', 'Bearer ' + this.tbiToken);

    d3.queue()
      .defer(data.get)
      .defer(bcn.get)
      .defer(vlc.get)
      .await(function (error, json, bcn, vlc) {
        if (error) throw error;

        json.data.forEach(function(d) {
          d.location_name = window.populateData.municipalityName;
          d.row = 'first_column';
        });

        bcn.data.forEach(function(d) {
          d.location_name = 'Barcelona';
          d.row = 'second_column';
        });

        vlc.data.forEach(function(d) {
          d.location_name = 'Valencia';
          d.row = 'third_column';
        });

        this.data = json.data.concat(bcn.data, vlc.data);

        this.nest = d3.nest()
          .key(function(d) { return d.row; })
          .rollup(function(v) { return {
              value: v[0].value,
              diff: (v[0].value - v[1].value) / v[1].value * 100,
            };
          })
          .entries(this.data);

        this.nest.forEach(function(d) {
          d.key = d.key,
          d.diff = d.value.diff,
          d.value = d.value.value
        }.bind(this));

        new SparklineTableCard(this.container, json, this.nest, 'investment_by_inhabitant');

        /* Sparklines */
        var place = this.data.filter(function(d) { return d.location_name === window.populateData.municipalityName; });
        bcn = this.data.filter(function(d) { return d.location_name === 'Barcelona'; });
        vlc = this.data.filter(function(d) { return d.location_name === 'Valencia'; });

        var placeSpark = new Sparkline(this.container + ' .sparkline-first_column', place, this.trend, this.freq);
        var bcnSpark = new Sparkline(this.container + ' .sparkline-second_column', bcn, this.trend, this.freq);
        var vlcSpark = new Sparkline(this.container + ' .sparkline-third_column', vlc, this.trend, this.freq);

        placeSpark.render();
        bcnSpark.render();
        vlcSpark.render();
      }.bind(this));
  },
  render: function() {
    this.getData();
  },
  _normalize: function(str) {
    var from = "1234567890ÃÀÁÄÂÈÉËÊÌÍÏÎÒÓÖÔÙÚÜÛãàáäâèéëêìíïîòóöôùúüûÑñÇç ‘/&().!",
        to = "izeasgtogoAAAAAEEEEIIIIOOOOUUUUaaaaaeeeeiiiioooouuuunncc_____",
        mapping = {};

    for (let i = 0, j = from.length; i < j; i++) {
      mapping[from.charAt(i)] = to.charAt(i);
    }

    var ret = [];
    for (let i = 0, j = str.length; i < j; i++) {
      var c = str.charAt(i);
      if (mapping.hasOwnProperty(str.charAt(i))) {
        ret.push(mapping[c]);
      }
      else {
        ret.push(c);
      }
    }

    return ret.join('').toLowerCase();
  }
});
