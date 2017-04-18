'use strict';

var BarsCard = Class.extend({
  init: function(divClass, json, data, cardName) {
    d3.timeFormatDefaultLocale(es_ES);

    this.div = d3.select(divClass);
    this.dataType = this.div.attr('data-type');

    var freq = this.div.attr('data-freq');

    var parseDate = freq === 'daily' ? d3.timeParse('%Y-%m-%d') : freq === 'monthly' ? d3.timeParse('%Y-%m') : d3.timeParse('%Y');
    var parsedDate = parseDate(json.data[0].date);
    var formatDate = d3.timeFormat("%B %Y");
    var isMobile = innerWidth <= 768;

    // Append source
    this.div.selectAll('.widget_src')
      .text(json.metadata.indicator['source name']);

    // Append date of last data point
    this.div.selectAll('.widget_updated')
      .text(formatDate(parsedDate));

    // Append metadata
    this.div.selectAll('.widget_title')
      .text(I18n.t('gobierto_indicators.cards.' + cardName + '.title'));
    
    // Paint bars
    var x = d3.scaleLinear()
      .range([0, isMobile ? 50 : 60])
      .domain([0, d3.max(data, function(d) { return d.figure; })]);
      
    var row = this.div.select('.bars')
      .selectAll('div')
      .data(data)
      .enter()
      .append('div')
      .attr('class', 'row');
      
    row.append('div')
      .attr('class', 'key')
      .text(function(d) { return d.key });
      
    row.append('div')
      .attr('class', 'bar')
      .style('width', function(d) { return x(d.figure) + '%'; });
      
    row.append('div')
      .attr('class', 'qty')
      .text(function(d) { return this._printData(d.figure); }.bind(this));
  },
  _printData: function(data) {
    // Switch between different figure types
    switch (this.dataType) {
      case 'percentage':
        return accounting.formatNumber(data, 1) + '%';
        break;
      case 'currency':
        return accounting.formatNumber(data, 0) + '€';
        break;
      case 'currency_per_person':
        return accounting.formatNumber(data, 0) + '€/hab';
        break;
      case 'per_inhabitant':
        return accounting.formatNumber(data, 2) + '/hab';
        break;
      default:
        return accounting.formatNumber(data, 0);
    }
  },
  _normalize: function(str) {
    var from = "1234567890ÃÀÁÄÂÈÉËÊÌÍÏÎÒÓÖÔÙÚÜÛãàáäâèéëêìíïîòóöôùúüûÑñÇç ‘/&().!",
        to = "izeasgtogoAAAAAEEEEIIIIOOOOUUUUaaaaaeeeeiiiioooouuuunncc_____",
        mapping = {};

    for (var i = 0, j = from.length; i < j; i++) {
      mapping[from.charAt(i)] = to.charAt(i);
    }

    var ret = [];
    for (var i = 0, j = str.length; i < j; i++) {
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
