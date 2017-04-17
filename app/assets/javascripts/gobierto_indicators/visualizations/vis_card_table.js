'use strict';

var TableCard = Class.extend({
  init: function(divClass, json, nest, cardName) {
    d3.timeFormatDefaultLocale(es_ES);

    this.div = d3.select(divClass);
    this.dataTypeOne = this.div.attr('data-type-one');
    this.dataTypeTwo = this.div.attr('data-type-two');

    var freq = this.div.attr('data-freq');

    var parseDate = freq === 'daily' ? d3.timeParse('%Y-%m-%d') : freq === 'monthly' ? d3.timeParse('%Y-%m') : d3.timeParse('%Y');
    var parsedDate = parseDate(json.data[0].date);
    var formatDate = d3.timeFormat("%B %Y");

    // Append source
    this.div.selectAll('.widget_src')
      .text(json.metadata.indicator['source name']);

    // Append date of last data point
    this.div.selectAll('.widget_updated')
      .text(formatDate(parsedDate));

    // Append metadata
    this.div.selectAll('.widget_title')
      .text(I18n.t('gobierto_indicators.cards.' + cardName + '.title'));
      
    var rows = nest.map(function(d) {
      return '<th>' + d.value.column + '</th> \
        <td>' + d.value.location + '</td> \
        <td>' + this._printData(d.value.gross, this.dataTypeOne) + '</td> \
        <td>' + this._printData(d.value.net, this.dataTypeTwo) + '</td>'
    }.bind(this));

    this.div.select('.widget_table')
      .selectAll('tr')
      .data(rows)
      .enter()
      .append('tr')
      .html(function(d) { return d; });
  },
  _printData: function(data, dataType) {
    // Switch between different figure types
    switch (data, dataType) {
      case 'percentage':
        return accounting.formatNumber(data, 1) + '%';
        break;
      case 'currency':
        return accounting.formatNumber(data, 0) + '€';
        break;
      case 'currency_per_person':
        return accounting.formatNumber(data, 0) + '€/hab';
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
