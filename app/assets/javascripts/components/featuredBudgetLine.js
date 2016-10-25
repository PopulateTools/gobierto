(function(window, undefined){
  'use strict';

  window.featuredBudgetLine = flight.component(function(){
    this.after('initialize', function() {
      this.loadFeaturedBudgetLine();
      this.on(document, "loadFeaturedBudgetLine", this.loadFeaturedBudgetLine);
    });

    this.loadFeaturedBudgetLine = function(e){
      var url = this.$node.data('featured-budget-line');
      $.ajax({
        url: url,
        dataType: 'html',
        success: function(response) {
          $('[data-featured-budget-line]').html(response);
          window.dataWidget.attachTo('[data-widget-type]');
          window.featuredBudgetLineLoadMore.attachTo('[data-featured-budget-line-load-more]');
        }
      });
    };
  });

  $(function() {
    window.featuredBudgetLine.attachTo('[data-featured-budget-line]');
  });
})(window);
