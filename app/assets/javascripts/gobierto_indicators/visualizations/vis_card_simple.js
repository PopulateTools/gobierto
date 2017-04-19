'use strict';

var SimpleCard = Class.extend({
  init: function(divClass, json, value, cardName) {
    d3.timeFormatDefaultLocale(eval(I18n.locale));

    this.div = d3.select(divClass);
    this.dataType = this.div.attr('data-type');

    var trend = this.div.attr('data-trend');
    var freq = this.div.attr('data-freq');

    var parseDate = freq === 'daily' ? d3.timeParse('%Y-%m-%d') : freq === 'monthly' ? d3.timeParse('%Y-%m') : d3.timeParse('%Y');
    var parsedDate = parseDate(json.data[0].date);
    var formatDate = d3.timeFormat("%B %Y");

    this.div.select('.widget_figure')
      .text(this._printData(value));

    // Append source
    this.div.selectAll('.widget_src')
      .text(json.metadata.indicator['source name']);

    // Append date of last data point
    this.div.selectAll('.widget_updated')
      .text(formatDate(parsedDate));

    // Append metadata
    this.div.selectAll('.widget_title')
      .text(I18n.t('gobierto_indicators.cards.' + cardName + '.title'));
    
    if (typeof json.data[1] !== 'undefined') {
      var spark = new Sparkline(divClass + ' .sparkline', json.data, trend, freq);
      spark.render();

      var pctChange = (value / json.data[1].value * 100) - 100;
      var pctFormat = accounting.formatNumber(pctChange, 1) + '%';
      var isPositive = pctChange > 0;

      // If is a positive change, attach a plus sign to the number
      this.div.select('.widget_pct')
        .text(function() { return isPositive ? '+' + pctFormat : pctFormat; });

      // Return the correct icon
      this.div.select('.widget_pct')
        .append('i')
        .attr('aria-hidden', 'true')
        .attr('class', function() {
          return isPositive ? 'fa fa-caret-up' : 'fa fa-caret-down';
        });
    }
  },
  _printData: function(data) {
    // Switch between different figure types
    switch (this.dataType) {
      case 'percentage':
        return accounting.formatNumber(data, 1) + '%';
        break;
      case 'currency':
        return accounting.formatNumber(data, 1) + '€';
        break;
      case 'currency_per_person':
        return accounting.formatNumber(data, 1) + '€/' + I18n.t('gobierto_indicators.inhabitants');
        break;
      default:
        return accounting.formatNumber(data, 0);
    }
  }
});

