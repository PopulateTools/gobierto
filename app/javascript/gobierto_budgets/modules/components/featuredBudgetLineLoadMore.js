import * as flight from 'flightjs'

export var featuredBudgetLineLoadMore = flight.component(function(){
  this.after('initialize', function() {
    this.$node.on('click', this.clickHandle.bind(this));
  });

  this.clickHandle = function(e){
    e.preventDefault();
    this.trigger('loadFeaturedBudgetLine');
  };
});
