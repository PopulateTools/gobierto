'use strict';

var VisAgeReport = Class.extend({
  init: function(divId) {
    d3.csv('/consultation_report.csv', function(error, data) {
      console.log(data);
    })
  },
  getData: function() {
  },
  render: function() {
  },
  updateRender: function(callback) {
  },
  _mouseover: function() {
  },
  _mouseout: function() {
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
