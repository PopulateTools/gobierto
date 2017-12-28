'use strict';

var TableCard = Class.extend({
  init: function(divClass, json, nest, cardName) {
    d3.timeFormatDefaultLocale(eval(I18n.locale));

    this.div = d3.select(divClass);
    this.dataTypeOne = this.div.attr('data-type-one');
    this.dataTypeTwo = this.div.attr('data-type-two');

    var freq = this.div.attr('data-freq');

    var parseDate = freq === 'daily' ? d3.timeParse('%Y-%m-%d') : freq === 'monthly' ? d3.timeParse('%Y-%m') : d3.timeParse('%Y');
    var parsedDate = parseDate(json.data[0].date);
    var formatDate = d3.timeFormat("%b %Y");

    this.div.selectAll('.tw-sharer')
      .attr('target', '_blank')
      .attr('href', 'https://twitter.com/intent/tweet?text=' + I18n.t('gobierto_indicators.cards.meta.where') + encodeURI(window.populateData.municipalityName) + ': ' +  encodeURI(I18n.t('gobierto_indicators.cards.' + cardName + '.title')).toLowerCase() + I18n.t('gobierto_indicators.cards.meta.time') + encodeURI(formatDate(parsedDate).toLowerCase()) + ', ' + encodeURI(this._printData(nest[0].value.valueOne))  + '&url=' + window.location.href + '&via=gobierto&source=webclient');

    this.div.selectAll('.fb-sharer')
      .attr('target', '_blank')
      .attr('href', 'https://www.facebook.com/sharer/sharer.php?u=' + window.location.href);

    // Append source
    this.div.selectAll('.widget_src')
      .attr('title', json.metadata.indicator['source name'])
      .text(json.metadata.indicator['source name']);

    // Append date of last data point
    this.div.selectAll('.widget_updated')
      .text(formatDate(parsedDate));

    // Append update frequency
    this.div.selectAll('.widget_freq')
      .text(this._printFreq(json.metadata.frequency_type));

    // Append metadata
    this.div.selectAll('.widget_title')
      .attr('title', I18n.t('gobierto_indicators.cards.' + cardName + '.title'))
      .text(I18n.t('gobierto_indicators.cards.' + cardName + '.title'));

    // Append backface info
    this.div.selectAll('.js-data-desc')
      .text(json.metadata.indicator.description);
    this.div.selectAll('.js-data-freq')
      .text(formatDate(parsedDate));

    var header = nest.map(function(d) {
      return I18n.t('gobierto_indicators.cards.' + cardName + '.' + this._normalize(d.value.column));
    }.bind(this));

    var rows = nest.map(function(d) {
      return '<td>' + d.value.key + '</td> \
        <td class="right">' + this._printData(d.value.valueOne, this.dataTypeOne) + '</td> \
        <td class="right">' + this._printData(d.value.valueTwo, this.dataTypeTwo) + '</td>'
    }.bind(this));

    var table = this.div.select('.widget_table');

    table
      .selectAll('th')
      .data(header)
      .enter()
      .append('th')
      .attr('class', 'right')
      .html(function(d) {
        if (d === "") d = '<span style="display:none" aria-hidden="true">WCAG 2.0 AA</span>';
        return d; });

    table
      .selectAll('tr')
      .data(rows)
      .enter()
      .append('tr')
      .html(function(d) { return d; });
  },
  _printFreq: function(json) {
    // Switch between different figure types
    switch (json) {
      case 'yearly':
        return I18n.t('gobierto_indicators.cards.frequency.yearly')
        break;
      case 'monthly':
      return I18n.t('gobierto_indicators.cards.frequency.monthly')
        break;
      case 'weekly':
      return I18n.t('gobierto_indicators.cards.frequency.weekly')
        break;
      case 'daily':
      return I18n.t('gobierto_indicators.cards.frequency.dailt')
        break;
      default:
        return ''
    }
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
        return accounting.formatNumber(data, 0) + '€/' + I18n.t('gobierto_indicators.inhabitants');
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
