'use strict';

var VisBubbles = Class.extend({
  init: function(divId, budgetCategory, data) {
    this.container = divId;
    this.currentYear = parseInt(d3.select('body').attr('data-year'));
    this.srcData = data;
    this.data = this.srcData.filter(function(d) { return d.year === this.currentYear; }.bind(this));;
    this.budget_category = budgetCategory;
    this.forceStrength = 0.045;
    
    this.margin = {top: 20, right: 10, bottom: 20, left: 10},
    this.width = parseInt(d3.select(this.container).style('width')) - this.margin.left - this.margin.right;
    this.height = 520 - this.margin.top - this.margin.bottom;
    this.center = { x: this.width / 2, y: this.height / 2 };
    
    this.filtered = this.data.filter(function(d) { return d.budget_category === this.budget_category; }.bind(this));
    this.maxAmount = d3.max(this.filtered, function (d) { return d.value; });
    
    this.selectionNode = d3.select(this.container)._groups[0][0];
    
    this.tooltip = d3.select(this.container)
      .append('div')
      .attr('class', 'tooltip');

    this.radiusScale = d3.scalePow()
      .exponent(0.5)
      .range([2, 100])
      .domain([0, this.maxAmount]);

    this.nodes = this.filtered.map(function (d) {
      return {
        id: d.id,
        radius: this.radiusScale(d.value),
        value: d.value,
        group: d.level_1,
        name: d.level_2,
        pct_diff: d.pct_diff,
        per_inhabitant: d.per_inhabitant,
        x: Math.random() * 900,
        y: -d.pct_diff * 1000,
        year: d.year
      };
    }.bind(this));

    this.nodes.sort(function (a, b) { return b.value - a.value; });
    
    this.svg = d3.select(this.container).append('svg')
      .attr('width', this.width + this.margin.left + this.margin.right)
      .attr('height', this.height + this.margin.top + this.margin.bottom)
      .append('g')
      .attr('transform', 'translate(' + this.margin.left + ',' + this.margin.top + ')');
  },
  render: function() {
    this.updateRender();
  },
  update: function(year) {
    console.log(year);
    this.data = this.srcData.filter(function(d) { return d.year === year; }.bind(this));;
    this.filtered = this.data.filter(function(d) { return d.budget_category === this.budget_category; }.bind(this));
    this.maxAmount = d3.max(this.filtered, function (d) { return d.value; });
    this.radiusScale.domain([0, this.maxAmount]);
    
    this.nodes = this.filtered.map(function (d) {
      return {
        id: d.id,
        radius: this.radiusScale(d.value),
        value: d.value,
        group: d.level_1,
        name: d.level_2,
        pct_diff: d.pct_diff,
        per_inhabitant: d.per_inhabitant,
        x: Math.random() * 900,
        y: -d.pct_diff * 1000,
        year: d.year
      };
    }.bind(this));
    
    this.bubbles = this.bubbles.data(this.nodes, function (d) { return d.id; })
    
    this.bubbles.exit()
      .transition()
      .attr('r', '0')
      .remove();

    this.bubbles.selectAll('circle')
      .attr('r', function (d) { return d.radius; })
      .merge(this.bubbles);
      
    this.simulation.nodes(this.bubbles);
    this.simulation.alpha(1).restart();
  },
  updateRender: function(callback) {
    var budgetCategory = this.budget_category;
      
    this.budgetColor = d3.scaleOrdinal()
      .domain(['income', 'expense'])
      .range(['#d9eef1', '#fab395']);

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
      .range(['#00909e', '#f39d96', '#f6b128', '#aac44b', '#a25fa6', '#981f2e', '#00909e', '#f39d96', '#f6b128', '#aac44b', '#a25fa6', '#981f2e', '#feecae', '#f79d68', '#edefee']);
    
    this.simulation = d3.forceSimulation()
      .velocityDecay(0.2)
      .force('x', d3.forceX().strength(this.forceStrength).x(this.center.x))
      .force('y', d3.forceY().strength(this.forceStrength).y(this.center.y))
      .force('charge', d3.forceManyBody().strength(this._charge))
      .nodes(this.nodes)
      .on('tick', this._ticked.bind(this));
      
    this.bubbles = this.svg.selectAll('g')
      .data(this.nodes, function (d) { return d.id; })
      .enter()
      .append('g')
      .attr('class', 'bubble-g')
      
    this.bubbles.append('circle')
      .attr('class', function(d) { return d.name + ' bubble'})
      .attr('r', function (d) { return d.radius; })
      .attr('fill', this.budgetColor(this.budget_category))
      .attr('stroke', d3.rgb(this.budgetColor(this.budget_category)).darker())
      .attr('stroke-width', 2)
      .on('mouseenter', colorize.bind(this))
      .on('mousemove', this._mousemoved.bind(this))
      .on('mouseleave', this._mouseleft.bind(this));
      
    this.bubbles.append('text')
      .attr('text-anchor', 'middle')
      .tspans(function(d) {
        return d.radius > 50 ? d3.wordwrap(d.name, 15) : d3.wordwrap('', 15) 
      })
      
    function colorize(d) {
      this.bubbles.selectAll('.bubble')
        .transition()
        .duration(300)
        .attr('fill', function (d) { return color(d.group); })
        .attr('stroke', function(d) {
          return d3.rgb(color(d.group)).darker()
        });
    }
  },
  _ticked: function() {
    this.bubbles.attr('transform', function(d) { return 'translate(' + d.x + ',' + d.y + ')' })
  },
  _mousemoved: function(d) {
    var coordinates = d3.mouse(this.selectionNode);
    var x = coordinates[0], y = coordinates[1];

    this.tooltip
      .style('display', 'block')
      .style('left', (x - 50) + 'px')
      .style('top', (y + 40) + 'px')
      
    this.tooltip.html('<div>' + d.name + '</div><div>(' + d.year + ') ' + d3.format("+.1%")(d.pct_diff, 1) + '</div>');
  },
  _mouseleft: function() {
    this.tooltip.style('display', 'none');
  },
  _charge: function(d) {
    return -Math.pow(d.radius, 2) * 0.05;
  }.bind(this)
});