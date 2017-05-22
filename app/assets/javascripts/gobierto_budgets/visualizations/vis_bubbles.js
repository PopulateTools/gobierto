'use strict';

var VisBubbles = Class.extend({
  init: function(divId, budgetCategory) {
    this.container = divId;
    this.data = null;
    this.url = '/bubble_data.json';
    this.budget_category = budgetCategory;
    this.forceStrength = 0.045;
  
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
    var budgetCategory = this.budget_category;
    
    var selectionNode = d3.select(this.container)._groups[0][0];
    
    var tooltip = d3.select(this.container)
      .append('div')
      .attr('class', 'tooltip');
      
    var budgetColor = d3.scaleOrdinal()
      .domain(['income', 'expense'])
      .range(['#d9eef1', '#fab395'])
      
    var filtered = this.data.filter(function(d) { return d.budget_category === this.budget_category; }.bind(this));
    
    var color = d3.scaleOrdinal()
      .domain([
          "Deuda pública",
          "Servicios públicos básicos",
          "Actuaciones de protección y promoción social",
          "Producción de bienes públicos de carácter preferente",
          "Actuaciones de carácter económico",
          "Actuaciones de carácter general",
          "Impuestos directos",
          "Impuestos indirectos",
          "Tasas y otros ingresos",
          "Transferencias corrientes",
          "Ingresos patrimoniales",
          "Enajenación de inversiones reales",
          "Transferencias de capital",
          "Activos financieros",
          "Pasivos financieros"
        ])
      .range(['#00909e', '#f39d96', '#f6b128', '#aac44b', '#a25fa6', '#981f2e', '#00909e', '#f39d96', '#f6b128', '#aac44b', '#a25fa6', '#981f2e', '#feecae', '#f79d68', '#edefee'])

    var maxAmount = d3.max(this.data, function (d) { return d.value; });

    var radiusScale = d3.scalePow()
      .exponent(0.5)
      .range([2, 100])
      .domain([0, maxAmount]);

    var nodes = filtered.map(function (d) {
      return {
        id: +d.id,
        radius: radiusScale(d.value),
        value: d.value,
        group: d.level_1,
        name: d.level_2,
        pct_diff: d.pct_diff,
        per_inhabitant: d.per_inhabitant,
        x: Math.random() * 900,
        y: -d.pct_diff * 1000
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
      
    var bubbles = this.svg.selectAll('g')
      .data(nodes, function (d) { return d.id; })
      .enter()
      .append('g')
      .attr('class', 'bubble-g')
      
    bubbles.append('circle')
      .attr('class', 'bubble')
      .attr('r', function (d) { return d.radius; })
      .attr('fill', budgetColor(this.budget_category))
      .attr('stroke', d3.rgb(budgetColor(this.budget_category)).darker())
      .attr('stroke-width', 2)
      .on('mouseenter', colorize)
      .on('mousemove', mousemoved)
      .on('mouseleave', mouseleft);
      
    bubbles.append('text')
      .attr('text-anchor', 'middle')
      .tspans(function(d) {
        return d.radius > 50 ? d3.wordwrap(d.name, 15) : d3.wordwrap('', 15) 
      })
      
    function colorize(d) {
      bubbles.selectAll('.bubble')
        .transition()
        .duration(300)
        .attr('fill', function (d) { return color(d.group); })
        .attr('stroke', function(d) {
          return d3.rgb(color(d.group)).darker()
        });
    }
    
    function mousemoved(d) {
      var coordinates = d3.mouse(selectionNode);
      var x = coordinates[0], y = coordinates[1];
      
      d3.select(this)
        .attr('stroke', 'black')
        .attr('stroke-width', 2);

      tooltip
        .style('display', 'block')
        .style('left', (x - 50) + 'px')
        .style('top', (y + 40) + 'px')
        
      tooltip.html('<div>' + d.name + '</div><div>' + d3.format("+.1%")(d.pct_diff, 1) + '</div>');
    }
    
    function mouseleft(d) {
      tooltip.style('display', 'none');
      
      bubbles.selectAll('.bubble')
        .transition()
        .duration(300)
        .attr('fill', budgetColor(budgetCategory))
        .attr('stroke', d3.rgb(budgetColor(budgetCategory)).darker())

      d3.select(this)
        .attr('stroke', d3.rgb(budgetColor(budgetCategory)).darker())
    }
    
    function ticked() {
      bubbles.attr('transform', function(d) { return 'translate(' + d.x + ',' + d.y + ')' })
    }
  },
  _charge: function(d) {
    return -Math.pow(d.radius, 2) * 0.05;
  }.bind(this)
});