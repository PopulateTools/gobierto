import * as d3 from 'd3'
import * as flight from 'flightjs'
import { accounting } from 'lib/shared'

var intelligenceBudgetLines = flight.component(function(){
  this.attributes({
  });

  this.after('initialize', function() {
    this.$yearFrom = this.$node.find('select[name=year_from]');
    this.$yearTo = this.$node.find('select[name=year_to]');
    this.$variable = this.$node.find('select[name=variable]');

    this.$yearFrom.on('change', function(e){
      e.preventDefault();
      return this.renderWidgets(this.$node.data('url'), true);
    }.bind(this));

    this.$yearTo.on('change', function(e){
      e.preventDefault();
      return this.renderWidgets(this.$node.data('url'), true);
    }.bind(this));

    this.$variable.on('change', function(e){
      e.preventDefault();
      return this.renderWidgets(this.$node.data('url'), true);
    }.bind(this));

    this.$node.find('[data-view-all]').on('click', function(e){
      e.preventDefault();

      var $widget = $(e.target).parents('div:eq(0)');
      $(e.target).remove();
      $widget.find('tr:hidden').show();
    }.bind(this));

    this.renderWidgets(this.$node.data('url'), true);
  });

  this.renderWidgets = function(url, limit){
    var yearFrom = this.$yearFrom.val();
    var yearTo = this.$yearTo.val();
    var variable = this.$variable.val();

    $.getJSON(this.dataUrl(yearFrom, yearTo), function(data){
      var groups = _.groupBy(data, 'year');
      var collection = [];
      groups[yearFrom].forEach(function(d){
        var d2 = _.find(groups[yearTo], function(d2){ return d2.code == d.code; });
        if(d2 !== undefined){
          collection.push({
            code: d.code,
            amount_year_from: d[variable],
            amount_year_to: d2[variable],
            difference: ((d2[variable] - d[variable])/d[variable])*100
          });
        }
      });
      collection = _.sortBy(collection, 'difference');
      this.attr.possitiveDiff = _.filter(collection, function(d){ return d.difference > 0; }).reverse();
      this.attr.negativeDiff = _.filter(collection, function(d){ return d.difference < 0; });

      this.renderWidget(this.attr.possitiveDiff, this.$node.find('[data-budget-line-up]'), yearFrom, yearTo, limit);
      this.renderWidget(this.attr.negativeDiff, this.$node.find('[data-budget-line-down]'), yearFrom, yearTo, limit);
    }.bind(this));
  }

  this.renderWidget = function(collection, $container, yearFrom, yearTo, limit){
    if(limit === true) {
      if(collection.length < 5) {
        // Remove pagination link
        $container.parents('table').next().remove();
      }
    }
    var $tbody = $container.find('tbody');
    var $thead = $container.find('thead');
    $thead.find('td[data-year-from]').html(yearFrom);
    $thead.find('td[data-year-to]').html(yearTo);
    $tbody.html('');
    var i = 0;
    collection.forEach(function(d){
      $tbody.append('<tr '+((limit == true && i >=5) ? 'style="display:none"' : '')+'><td>' + window.budgetCategoriesDictionary(d.code, 'G', 'functional') + '</td><td>' +
          this.formatMoney(d.amount_year_from) + '</td><td>' +
          this.formatMoney(d.amount_year_to) + '</td>' +
          '<td class="'+(d.difference > 0 ? 'positive' : 'negative')+'">' +
          accounting.formatNumber(d.difference) + ' %</td></tr>');
      i++;
    }.bind(this));
  }

  this.dataUrl = function(yearFrom, yearTo){
    var url = this.$node.data('url');

    return url.replace("year_from", yearFrom).replace("year_to", yearTo);
  }

  this.formatMoney = function(n){
    var d3Locale = d3.timeFormatDefaultLocale({
      "decimal": ",",
      "thousands": ".",
      "grouping": [3],
      "currency": ["€"],
      "dateTime": "%a %b %e %X %Y",
      "date": "%m/%d/%Y",
      "time": "%H:%M:%S",
      "periods": ["AM", "PM"],
      "days": ["Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo"],
      "shortDays": ["Lun", "Mar", "Mie", "Jue", "Vie", "Sab", "Dom"],
      "months": ["Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"],
      "shortMonths": ["Ene", "Feb", "Mar", "Abr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    });

    if(n > 1000000) {
      return d3Locale.numberFormat(',.3s')(n) + '€';
    } else {
      return d3Locale.numberFormat(',.3r')(n) + '€';
    }
  }
});

$( document ).on('turbolinks:load', function() {
  intelligenceBudgetLines.attachTo('[data-intelligence-budget-lines]');
});
