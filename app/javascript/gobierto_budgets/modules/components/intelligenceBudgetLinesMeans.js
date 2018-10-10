import * as d3 from 'd3'
import * as flight from 'flightjs'
import { accounting } from 'lib/shared'

var intelligenceBudgetLinesMeans = flight.component(function(){
  this.attributes({
  });

  this.after('initialize', function() {
    this.$year = this.$node.find('select[name=yearIntelligence]')
    this.$variable = this.$node.find('select[name=variable]');

    this.$variable.on('change', function(e){
      e.preventDefault();
      return this.renderWidgets(this.$node.data('url'), true);
    }.bind(this));

    this.$year.on('change', function(e){
      e.preventDefault();
      return this.renderWidgets(this.$node.data('url'), true);
    }.bind(this));

    this.$node.find('[data-view-all]').on('click', function(e){
      e.preventDefault();

      var $widget = $(e.target).parents('div:eq(0)');
      $(e.target).remove();
      $widget.find('tr:hidden').show();
    }.bind(this));

    this.$node.find('[data-budget-line-up]').find('[data-select-filter-1] select').on('change', function(e){
      e.preventDefault();

      return this.renderWidgets(this.$node.data('url'), true);
    }.bind(this));

    this.$node.find('[data-budget-line-up]').find('[data-select-filter-2] select').on('change', function(e){
      e.preventDefault();

      return this.renderWidgets(this.$node.data('url'), true);
    }.bind(this));

    this.renderWidgets(this.$node.data('url'), true);
  });

  this.renderWidgets = function(url, limit){
    var variable = this.$variable.val();
    var year = this.$year.val();

    // List of differences is always sorted based on the first filter of the first widget
    var f1 = this.$node.find('[data-budget-line-up]').find('[data-select-filter-1] select').val();
    var f2 = this.$node.find('[data-budget-line-up]').find('[data-select-filter-2] select').val();
    var variableFilter1 = (variable == 'amount_per_inhabitant') ? 'avg_per_inhabitant_'+f1 : 'avg_'+f1;
    var variableFilter2 = (variable == 'amount_per_inhabitant') ? 'avg_per_inhabitant_'+f2 : 'avg_'+f2;

    $.getJSON(this.dataUrl(year), function(collection){
      collection.forEach(function(d){
        var v1 = d[variable];
        var v2 = d[variableFilter1];
        var v3 = d[variableFilter2];
        d['differenceFilter1'] = ((v1 - v2)/v2)*100;
        d['differenceFilter2'] = ((v1 - v3)/v3)*100;
      });
      collection = _.sortBy(collection, 'differenceFilter1');
      this.attr.possitiveDiff = _.filter(collection, function(d){ return d.differenceFilter1 > 0; }).reverse();
      this.attr.negativeDiff = _.filter(collection, function(d){ return d.differenceFilter1 < 0; });

      this.renderWidget(this.attr.possitiveDiff, this.$node.find('[data-budget-line-up]'), year, limit);
      this.renderWidget(this.attr.negativeDiff, this.$node.find('[data-budget-line-down]'), year, limit);
      this.renderInsight(this.attr.possitiveDiff, this.$node.find('[data-budget-line-up]'), 'alto', this.attr.possitiveDiff.length / collection.length);
      this.renderInsight(this.attr.negativeDiff, this.$node.find('[data-budget-line-down]'), 'bajo', this.attr.negativeDiff.length / collection.length);
    }.bind(this));
  }

  this.renderInsight = function(collection, $container, direction, percentage){
    var variable = this.$variable.val() == 'amount' ? 'gasto' : 'gasto por habitante';
    var comparationVariable = $container.find('[data-select-filter-1] select :selected').text().toLowerCase();
    var comparationPercentage = accounting.formatNumber(percentage * 100) + '%';

    var insightText = $container.data('place-name');
    insightText += " tiene un " + variable;
    insightText += " más " + direction;
    insightText += " que la " + comparationVariable;
    insightText += " en un " + comparationPercentage + " de partidas";

    $container.find('[data-insight] p').html(insightText);
  }

  this.renderWidget = function(collection, $container, year, limit){
    var variable = this.$variable.val();
    var f1 = $container.find('[data-select-filter-1] select').val();
    var f2 = $container.find('[data-select-filter-2] select').val();
    var variableFilter1 = (variable == 'amount_per_inhabitant') ? 'avg_per_inhabitant_'+f1 : 'avg_'+f1;
    var variableFilter2 = (variable == 'amount_per_inhabitant') ? 'avg_per_inhabitant_'+f2 : 'avg_'+f2;
    var $tbody = $container.find('tbody');
    $tbody.html('');
    var i = 0;
    collection.forEach(function(d){
      $tbody.append('<tr '+((limit == true && i >=5) ? 'style="display:none"' : '')+'><td>' + window.budgetCategoriesDictionary(d.code, 'G', 'functional') + '</td><td>' +
          this.formatMoney(d[variable]) + '</td><td>' +
          this.formatMoney(d[variableFilter1]) + '</td>' +
          '<td class="'+(d.differenceFilter1 > 0 ? 'positive' : 'negative')+'">' + accounting.formatNumber(d.differenceFilter1) + '%</td><td>' +
          this.formatMoney(d[variableFilter2]) + '</td>' +
          '<td class="'+(d.differenceFilter2 > 0 ? 'positive' : 'negative')+'">' + accounting.formatNumber(d.differenceFilter2) + '%</td></tr>');
      i++;
    }.bind(this));
  }

  this.dataUrl = function(year){
    var url = this.$node.data('url');

    return url.replace("year", year);
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
  intelligenceBudgetLinesMeans.attachTo('[data-intelligence-budget-lines-means]');
});
