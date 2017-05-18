'use strict';

var VisBubbles = Class.extend({
  init: function(divId, budgetCategory) {
    this.container = divId;
    this.data = null;
    this.url = '/bubble_data.json';
    this.budget_category = budgetCategory;
    this.forceStrength = 0.05;
    
    this.margin = {top: 20, right: 10, bottom: 20, left: 10},
    this.width = parseInt(d3.select(this.container).style('width')) - this.margin.left - this.margin.right;
    this.height = 520 - this.margin.top - this.margin.bottom;
    this.center = { x: this.width / 2, y: this.height / 2 };
    
    this.svg = d3.select(this.container).append('svg')
      .attr('width', this.width + this.margin.left + this.margin.right)
      .attr('height', this.height + this.margin.top + this.margin.bottom)
      .append('g')
      .attr('transform', 'translate(' + this.margin.left + ',' + this.margin.top + ')');
  },
  getData: function() {
    d3.json(this.url, function(error, jsonData) {
      if (error) throw error;

      this.data = jsonData;
      this.updateRender();
    }.bind(this));
  },
  render: function() {
    if (this.data === null) {
      this.getData();
    } else {
      this.updateRender();
    }
  },
  updateRender: function(callback) {
    var selectionNode = d3.select(this.container)._groups[0][0];
    
    var tooltip = d3.select(this.container)
      .append('div')
      .attr('class', 'tooltip');
    
    var filtered = this.data.filter(function(d) { return d.budget_category === this.budget_category; }.bind(this));
    
    var color = d3.scaleOrdinal(d3.schemeCategory10)
      .domain(filtered.map(function(d) { return d.level_1; }))
    
    var maxAmount = d3.max(this.data, function (d) { return d.value; });

    var radiusScale = d3.scalePow()
      .exponent(0.5)
      .range([2, 150])
      .domain([0, maxAmount]);

    var nodes = filtered.map(function (d) {
      return {
        id: d.id,
        radius: radiusScale(d.value),
        value: d.value,
        group: d.level_1,
        name: d.level_2,
        x: Math.random() * 900,
        y: -d.pct_section * 900
      };
    });

    nodes.sort(function (a, b) { return b.value - a.value; });
    
    var simulation = d3.forceSimulation()
      .velocityDecay(0.2)
      .force('x', d3.forceX().strength(this.forceStrength).x(this.center.x))
      .force('y', d3.forceY().strength(this.forceStrength).y(this.center.y))
      .force('charge', d3.forceManyBody().strength(this._charge))
      .nodes(nodes)
      .on('tick', ticked);
      
    var bubbles = this.svg.selectAll('.bubble')
      .data(nodes, function (d) { return d.id; })
      .enter()
      .append('circle')
      .attr('class', 'bubble')
      .attr('r', function (d) { return d.radius; })
      .attr('fill', function (d) { return color(d.group); })
      .attr('stroke', function (d) { return d3.rgb(color(d.group)).darker(); })
      .attr('stroke-width', 2)
      .on('mousemove', mousemoved)
      .on('mouseleave', mouseleft);
      
    function mousemoved(d) {
      var coordinates = d3.mouse(selectionNode);
      var x = coordinates[0], y = coordinates[1];

      d3.select(this)
        .attr('stroke', 'black')
        .attr('stroke-width', 2);

      tooltip
        .style('display', 'block')
        .style('left', (x - 50) + 'px')
        .style('top', (y + 80) + 'px')
        
      tooltip.html(d.name);
    }
    
    function mouseleft(d) {
      tooltip.style('display', 'none');

      d3.select(this)
        .attr('stroke', d3.rgb(color(d.group)).darker() )
    }
    
    function ticked() {
      bubbles
        .attr('cx', function (d) { return d.x; })
        .attr('cy', function (d) { return d.y; });
    }
  },
  _charge: function(d) {
    return -Math.pow(d.radius, 2) * 0.05;
  }.bind(this),
});