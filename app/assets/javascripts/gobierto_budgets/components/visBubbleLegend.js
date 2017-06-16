'use strict';

var VisBubbleLegend = Class.extend({
  init: function(divId) {
    this.container = divId;
    this.isMobile = window.innerWidth <= 740;

    var margin = {top: 15, right: 5, bottom: 15, left: 5},
      width = parseInt(d3.select(this.container).style('width')) - margin.left - margin.right,
      height = this.isMobile ? 320 : 520 - margin.top - margin.bottom;

    var svg = d3.select(this.container).append('svg')
      .attr('width', width + margin.left + margin.right)
      .attr('height', height + margin.top + margin.bottom)
      .style('overflow', 'visible')
      .append('g')
      .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')');

    var gradient = svg.append('defs')
      .append('linearGradient')
      .attr('id', 'gradient_legend')
      .attr('x1', '0%')
      .attr('x2', '0%')
      .attr('y1', '0%')
      .attr('y2', '100%')

    gradient.append('stop')
      .attr('offset', '5%')
      .attr('stop-color', 'black')

    gradient.append('stop')
      .attr('offset', '100%')
      .attr('stop-color', 'magenta')

    svg.append('marker')
      .attr('id', 'arrow_start')
      .attr('viewBox', '-10 -10 20 20')
      .attr('markerWidth', 6)
      .attr('markerHeight', 6)
      .attr('orient', '-90')
      .append('path')
      .attr('fill','#D6D6D6')
      .attr('d', 'M-4,-6 L 10,0 L -4,6');

    svg.append('marker')
      .attr('id', 'arrow_end')
      .attr('viewBox', '-10 -10 20 20')
      .attr('markerWidth', 6)
      .attr('markerHeight', 6)
      .attr('orient', 'auto')
      .append('path')
      .attr('fill','#D6D6D6')
      .attr('d', 'M-4,-6 L 10,0 L -4,6');

    svg.append('line')
      .attr('transform', 'translate(' + width / 2 + ',' + 0 + ')')
      .attr('x1', 0)
      .attr('x2', 0)
      .attr('y1', 0)
      .attr('y2', height)
      // .attr('stroke', 'url(#gradient_legend)')
      .attr('stroke', '#D6D6D6')
      .attr('stroke-width', 4)
      .attr('marker-end', 'url(#arrow_end)')
      .attr('marker-start', 'url(#arrow_start)')

    var labelRect = svg.append('rect')
      .attr('transform', 'translate(-80' + ',' + (height / 2 - 25) + ')')
      .attr('width', 200)
      .attr('height', 60)
      .attr('fill', 'white')

    var label = svg.append('text')
      .attr('transform', 'translate(' + width / 2 + ',' + height / 2 + ')')
      .attr('text-anchor', 'middle')

    label.append('tspan')
      .text('Cambio entre este año');

    label.append('tspan')
      .attr('x', 0)
      .attr('y', 18)
      .text('y el pasado');
},
});
