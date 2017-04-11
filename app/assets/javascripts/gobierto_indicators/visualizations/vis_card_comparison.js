'use strict';

var ComparisonCard = Class.extend({
  init: function(divClass, json, value1, value2) {
    d3.timeFormatDefaultLocale(es_ES);

    this.div = d3.select(divClass);
    this.firstDataType = this.div.attr('data-type-first');
    this.secondDataType = this.div.attr('data-type-second');

    var trend = this.div.attr('data-trend');
    var freq = this.div.attr('data-freq');
    var parseDate = freq === 'daily' ? d3.timeParse('%Y-%m-%d') : freq === 'monthly' ? d3.timeParse('%Y-%m') : d3.timeParse('%Y');
    var parsedDate = parseDate(json.data[0].date);
    var formatDate = d3.timeFormat("%B %Y");

    this.div.select('.widget_figure .figure-first')
      .text(this._printData(this.firstDataType, value1));
      
    this.div.select('.widget_figure .figure-second')
      .text(this._printData(this.secondDataType, value2));

    // Append source
    this.div.selectAll('.widget_src')
      .text(json.metadata.indicator['source name']);

    // Append date of last data point
    this.div.selectAll('.widget_updated')
      .text(formatDate(parsedDate));

    // Append metadata
    this.div.selectAll('.widget_title')
      .text(json.metadata.name);
  },
  _printData: function(type, data) {
    // Switch between different figure types
    switch (type) {
      case 'percentage':
        return accounting.formatNumber(data, 0) + '%';
        break;
      case 'currency':
        return accounting.formatNumber(data, 1) + '€';
        break;
      case 'currency_per_person':
        return accounting.formatNumber(data, 1) + '€/hab';
        break;
      default:
        return accounting.formatNumber(data, 0);
    }
  }
});
