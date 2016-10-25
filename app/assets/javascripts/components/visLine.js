(function(window, undefined){
  'use strict';

  window.visLine = flight.component(function(){
    this.attributes({
      'containerId': '#lines_chart',
      'legendId': '#lines_tooltip'
    });

    this.after('initialize', function() {
      var visLineasJ = new VisLineasJ(this.attr.containerId, this.attr.legendId, this.$node.data('line-widget-type'), this.$node.data('line-widget-series'));
      visLineasJ.render(this.$node.data('line-widget-url'));

      $('[data-line-widget-url]').on('click', function(e){
        e.preventDefault();
        visLineasJ.measure = $(this).data('line-widget-type');
        visLineasJ.render($(this).data('line-widget-url'));
        $('[data-line-widget-url]').removeClass('active');
        $(this).addClass('active');
      });
    });
  });

  $(function() {
    window.visLine.attachTo('[data-line-widget-url].active');
  });

})(window);
