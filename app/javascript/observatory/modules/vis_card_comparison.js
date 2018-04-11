import { Class, d3, d3locale, accounting } from 'shared'

export var ComparisonCard = Class.extend({
  init: function(divClass, json, value_1, value_2, cardName) {
    d3.timeFormatDefaultLocale(d3locale[I18n.locale]);

    this.div = d3.select(divClass);
    this.firstDataType = this.div.attr('data-type-first');
    this.secondDataType = this.div.attr('data-type-second');

    // var trend = this.div.attr('data-trend');
    var freq = this.div.attr('data-freq');
    var parseDate = freq === 'daily' ? d3.timeParse('%Y-%m-%d') : freq === 'monthly' ? d3.timeParse('%Y-%m') : d3.timeParse('%Y');
    var parsedDate = parseDate(json.data[0].date);
    var formatDate = d3.timeFormat("%b %Y");

    this.div.selectAll('.tw-sharer')
      .attr('target', '_blank')
      .attr('href', 'https://twitter.com/intent/tweet?text=' + I18n.t('gobierto_observatory.cards.meta.where') + encodeURI(window.populateData.municipalityName) + ': ' +  encodeURI(I18n.t('gobierto_observatory.cards.' + cardName + '.title')).toLowerCase() + I18n.t('gobierto_observatory.cards.meta.time') + encodeURI(formatDate(parsedDate).toLowerCase()) + ', ' + encodeURI(this._printData(this.firstDataType, value_1))  + '&url=' + window.location.href + '&via=gobierto&source=webclient');

    this.div.selectAll('.fb-sharer')
      .attr('target', '_blank')
      .attr('href', 'https://www.facebook.com/sharer/sharer.php?u=' + window.location.href);

    this.div.select('.widget_figure .figure-first')
      .text(this._printData(this.firstDataType, value_1));

    this.div.select('.widget_figure .figure-second')
      .text(this._printData(this.secondDataType, value_2));

    // Append source
    this.div.selectAll('.widget_src')
      .attr('title', json.metadata.indicator['source name'])
      .text(json.metadata.indicator['source name']);

    // Append update frequency
    this.div.selectAll('.widget_freq')
      .text(this._printFreq(json.metadata.frequency_type));

    // Append date of last data point
    this.div.selectAll('.widget_updated')
      .text(formatDate(parsedDate));

    // Append metadata
    this.div.selectAll('.widget_title')
      .attr('title', I18n.t('gobierto_observatory.cards.' + cardName + '.title'))
      .text(I18n.t('gobierto_observatory.cards.' + cardName + '.title'));

    // Append backface info
    this.div.selectAll('.js-data-desc')
      .text(json.metadata.indicator.description);
    this.div.selectAll('.js-data-freq')
      .text(formatDate(parsedDate));
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
  _printData: function(type, data) {
    // Switch between different figure types
    switch (type) {
      case 'percentage':
        return accounting.formatNumber(data, 0) + '%';
      case 'currency':
        return accounting.formatNumber(data, 0) + '€';
      case 'currency_per_person':
        return accounting.formatNumber(data, 1) + '€/' + I18n.t('gobierto_observatory.inhabitants');
      default:
        return accounting.formatNumber(data, 0);
    }
  }
});
