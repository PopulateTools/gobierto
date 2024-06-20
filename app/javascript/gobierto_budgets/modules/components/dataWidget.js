import * as flight from 'flightjs'
import Mustache from 'mustache'

export var dataWidget = flight.component(function(){
  this.after('initialize', function() {
    $.getJSON(this.$node.data('widget-data-url'), function(data){
      var template = $(this.$node.data('widget-template')).html();
      if (this.$node.attr('title') !== undefined){
        data.title = this.$node.attr('title');
      }
      var html = Mustache.render(template, data);
      this.$node.html(html);
      if (this.$node.data('callback') !== undefined) {
        var callback = this.$node.data('callback');
        callback += "(this.$node)";
        eval(callback);
      }
    }.bind(this));
  });
});

$(document).on('turbolinks:load', function() {
  dataWidget.attachTo('[data-widget-type]');
});
