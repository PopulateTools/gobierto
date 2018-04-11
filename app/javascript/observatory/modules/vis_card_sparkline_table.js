import { Class, d3, d3locale, accounting } from 'shared'

export var SparklineTableCard = Class.extend({
  init: function(divClass, json, value, cardName) {
    d3.timeFormatDefaultLocale(d3locale[I18n.locale]);

    this.div = d3.select(divClass);
    this.dataType = this.div.attr('data-type');

    // var trend = this.div.attr('data-trend');
    var freq = this.div.attr('data-freq');

    var parseDate = freq === 'daily' ? d3.timeParse('%Y-%m-%d') : freq === 'monthly' ? d3.timeParse('%Y-%m') : d3.timeParse('%Y');
    var parsedDate = parseDate(json.data[0].date);
    var formatDate = d3.timeFormat("%b %Y");

    this.div.selectAll('.tw-sharer')
      .attr('target', '_blank')
      .attr('href', 'https://twitter.com/intent/tweet?text=' + I18n.t('gobierto_observatory.cards.meta.where') + encodeURI(window.populateData.municipalityName) + ': ' +  encodeURI(I18n.t('gobierto_observatory.cards.' + cardName + '.title')).toLowerCase() + I18n.t('gobierto_observatory.cards.meta.time') + encodeURI(formatDate(parsedDate).toLowerCase()) + ', ' + encodeURI(this._printData(value[0].value))  + '&url=' + window.location.href + '&via=gobierto&source=webclient');

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
      .attr('title', I18n.t('gobierto_observatory.cards.' + cardName + '.title'))
      .text(I18n.t('gobierto_observatory.cards.' + cardName + '.title'));

    // Append backface info
    this.div.selectAll('.js-data-desc')
      .text(json.metadata.indicator.description);
    this.div.selectAll('.js-data-freq')
      .text(formatDate(parsedDate));

    var rows = value.map(function(d) {
      return '<td>' + I18n.t('gobierto_observatory.cards.' + cardName + '.' + this._normalize(d.key), {place: window.populateData.municipalityName, province: window.populateData.provinceName }) + '</td> \
        <td class="sparktable sparkline-' + this._normalize(d.key) + '"></td> \
        <td>' + accounting.formatNumber(d.diff, 1) + '%</td> \
        <td>' + this._printData(d.value) + '</td>'
    }.bind(this));

    this.div.select('.widget_table')
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
        return I18n.t('gobierto_observatory.cards.frequency.yearly')
      case 'monthly':
        return I18n.t('gobierto_observatory.cards.frequency.monthly')
      case 'weekly':
        return I18n.t('gobierto_observatory.cards.frequency.weekly')
      case 'daily':
        return I18n.t('gobierto_observatory.cards.frequency.dailt')
      default:
        return ''
    }
  },
  _printData: function(data) {
    // Switch between different figure types
    switch (this.dataType) {
      case 'percentage':
        return accounting.formatNumber(data, 1) + '%';
      case 'percentage_by_thousand':
        return accounting.formatNumber(data, 1) + '‰';
      case 'currency':
        return accounting.formatNumber(data, 1) + '€';
      case 'currency_per_person':
        return accounting.formatNumber(data, 1) + '€/' + I18n.t('gobierto_observatory.inhabitants');
      default:
        return accounting.formatNumber(data, 0);
    }
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
