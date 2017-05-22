'use strict';

var VisSlider = Class.extend({
  init: function(divId, data) {
    this.container = divId;
    this.data = data;
    
    var currentYear = parseInt(d3.select('body').attr('data-year'));
    var slideYear = currentYear;
    var years = _.uniq(this.data.map(function(d) { return d.year; })).filter(function(d) { return d <= currentYear; });
    
    var scale = d3.scaleLinear()
      .domain(d3.extent(years, function(d) { return d; }))
      .range([0, 100]);
    
    var wrapper = d3.select(this.container).append('div')
      .attr('class', 'timeline-wrap');
    
    wrapper.append('div')
      .attr('class', 'timeline-dot');
      
    var ul = wrapper.append('ul')
      .attr('class', 'timeline-pieces');
    
    var lis = ul.selectAll('li')
      .data(years)
      .enter()
      .append('li')
      .style('left', function(d) { return scale(d) + '%' })
      .attr('class', 'timeline-piece');
      
    lis.append('span')  
      .attr('class', 'timeline-piece-dot');
    
    lis.append('span')  
      .attr('class', function(d) {
        return slideYear === d ? 'active timeline-piece-label' : 'timeline-piece-label'
      })
      .text(function(d) { return d; });
  },
});