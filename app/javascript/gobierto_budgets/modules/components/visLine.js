import * as flight from 'flightjs';
import { VisLineasJ } from '../../../lib/visualizations';

var visLine = flight.component(function(){
  this.attributes({
    'containerId': '#lines_chart',
    'legendId': '#lines_tooltip'
  });

  this.after('initialize', function() {
    var visLineasJ = new VisLineasJ(this.attr.containerId, this.attr.legendId, this.$node.data('line-widget-type'), this.$node.data('line-widget-series'));
    visLineasJ.render(this.$node.data('line-widget-url'));

    $('#lines_chart_wrapper [data-line-widget-url]').on('click', function(e){
      e.preventDefault();
      visLineasJ.measure = $(this).data('line-widget-type');
      visLineasJ.render($(this).data('line-widget-url'));
      $('#lines_chart_wrapper [data-line-widget-url]').removeClass('active');
      $('#lines_chart_wrapper [data-line-widget-url]').attr({
        'tabindex': -1,
        'aria-selected': false
      });

      $(this).addClass('active');
      $(this).attr({
        'tabindex': 0,
        'aria-selected': true
      });
    });
  });
});

var visLineComparison = flight.component(function(){
  this.attributes({
    'containerId': '#lines_chart_comparison',
    'legendId': '#lines_tooltip_comparison'
  });

  this.after('initialize', function() {
    var visLineasJ = new VisLineasJ(this.attr.containerId, this.attr.legendId, this.$node.data('line-widget-type'), this.$node.data('line-widget-series'));
    visLineasJ.render(this.$node.data('line-widget-url'));

    $('#lines_chart_comparison_wrapper [data-line-widget-url]').on('click', function(e){
      e.preventDefault();
      $(visLineasJ.container+"_wrapper").removeProp('hidden');
      visLineasJ.measure = $(this).data('line-widget-type');
      visLineasJ.render($(this).data('line-widget-url'));
      $('#lines_chart_comparison_wrapper [data-line-widget-url]').removeClass('active');
      $('#lines_chart_comparison_wrapper [data-line-widget-url]').attr({
        'tabindex': -1,
        'aria-selected': false
      });

      $(this).addClass('active');
      $(this).attr({
        'tabindex': 0,
        'aria-selected': true
      });
    });
  });
});

$(document).on('turbolinks:load', function() {
  visLine.attachTo('#lines_chart_wrapper [data-line-widget-url].active');
  visLineComparison.attachTo('#lines_chart_comparison_wrapper [data-line-widget-url].active');
});
