import * as flight from 'flightjs'
import { dataWidget } from './dataWidget.js'
import { featuredBudgetLineLoadMore } from './featuredBudgetLineLoadMore.js'

var featuredBudgetLine = flight.component(function(){
  this.after('initialize', function() {
    this.loadFeaturedBudgetLine();
    this.on(document, "loadFeaturedBudgetLine", this.loadFeaturedBudgetLine);
  });

  this.loadFeaturedBudgetLine = function(){
    var url = this.$node.data('featured-budget-line');
    $.ajax({
      url: url,
      dataType: 'html',
      success: function(response) {
        $('[data-featured-budget-line]').html(response);
        dataWidget.attachTo('[data-widget-type]');
        featuredBudgetLineLoadMore.attachTo('[data-featured-budget-line-load-more]');
      }
    });
  };
});

$(document).on('turbolinks:load', function() {
  featuredBudgetLine.attachTo('[data-featured-budget-line]');
});
