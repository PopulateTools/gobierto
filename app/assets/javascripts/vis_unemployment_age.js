'use strict';

var VisUnemploymentAge = Class.extend({
  init: function(divId, city_id, current_year) {
    this.container = divId;
    this.currentYear = (current_year !== undefined) ? parseInt(current_year) : null;
    this.data = null;
    this.tbiToken = window.tbiToken;
    this.popUrl = 'https://tbi.populate.tools/gobierto/datasets/ds-poblacion-municipal-edad.json?sort_asc_by=date&filter_by_location_id=' + city_id;
    this.unemplUrl = 'https://tbi.populate.tools/gobierto/datasets/ds-personas-paradas-municipio-edad.json?sort_asc_by=date&filter_by_location_id=' + city_id;
  
    // Chart dimensions
    this.margin = {top: 15, right: 0, bottom: 25, left: 0};
    this.width = this._width() - this.margin.left - this.margin.right;
    this.height = this._height() - this.margin.top - this.margin.bottom;

    // Scales & Ranges
    this.xScale = d3.scaleTime();
    this.yScale = d3.scaleLinear();
    this.color = d3.scaleOrdinal();

    // Create axes
    this.xAxis = d3.axisBottom();
    this.yAxis = d3.axisLeft();

    // Chart objects
    this.svg = null;
    this.chart = null;

    // Create main elements
    this.svg = d3.select(this.container)
      .append('svg')
      .attr('width', this.width + this.margin.left + this.margin.right)
      .attr('height', this.height + this.margin.top + this.margin.bottom)
      .append('g')
      .attr('class', 'chart-container')
      .attr('transform', 'translate(' + this.margin.left + ',' + this.margin.top + ')');
    
    // Append axes containers
    this.svg.append('g').attr('class','x axis');
    this.svg.append('g').attr('class','y axis');

    d3.select(window).on('resize.' + this.container, this._resize.bind(this));
  },
  getData: function() {
    var pop = d3.json(this.popUrl)
      .header('authorization', 'Bearer ' + this.tbiToken)

    var unemployed = d3.json(this.unemplUrl)
      .header('authorization', 'Bearer ' + this.tbiToken)

    d3.queue()
      .defer(pop.get)
      .defer(unemployed.get)
      .await(function (error, jsonData, unemployed) {
        if (error) throw error;

        // Get population for each group & year
        var nested = d3.nest()
          .key(function(d) { return d.date; })
          .rollup(function(v) { return {
              '<25': d3.sum(v.filter(function(d) {return d.age >= 16 && d.age < 25}), function(d) { return d.value; }),
              '25-44': d3.sum(v.filter(function(d) {return d.age >= 25 && d.age < 45}), function(d) { return d.value; }),
              '>=45': d3.sum(v.filter(function(d) {return d.age >= 45 && d.age < 65}), function(d) { return d.value; }),
            };
          })
          .entries(jsonData);

        var temp = {};
        nested.forEach(function(k) {
          temp[k.key] = k.value
        });
        nested = temp;
        
        // Get the last year from the array
        var lastYear = unemployed[unemployed.length - 1].date.slice(0,4);

        unemployed.forEach(function(d) {
          var year = d.date.slice(0,4);
          
          if(nested.hasOwnProperty(year)) {
            d.pct = d.value / nested[year][d.age_range];
          } else if(year === lastYear) {
            // If we are in the last year, divide the unemployment by last year's population
            d.pct = d.value / nested[year - 1][d.age_range];
          } else {
            d.pct = null;
          }
          d.date = d3.timeParse('%Y-%m')(d.date);
        })
        
        // Filtering values to start from the first data points
        this.data = unemployed.filter(function(d) { return d.date >= d3.timeParse('%Y-%m')('2011-01') });
        
        this.nest = d3.nest()
          .key(function(d) { return d.age_range; })
          .entries(this.data);
        
        this.updateRender();
        this._renderLines();

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
    this.xScale
      .rangeRound([0, this.width])
      .domain([d3.timeParse('%Y-%m')('2010-11'), d3.max(this.data, function(d) { return d.date})]);

    this.yScale
      .rangeRound([this.height, 0])
      .domain([0, d3.max(this.data, function(d) { return d.pct})]);
      
    this.color
      .domain(['<25', '25-44', '>=45'])
      .range(['#66c2a5', '#fc8d62', '#8da0cb']);

    this._renderAxis();
  },
  _renderLines: function() {
    this.line = d3.line()
      .x(function(d) { return this.xScale(d.date); }.bind(this))
      .y(function(d) { return this.yScale(d.pct); }.bind(this));
      
    this.svg.append('g')
      .attr('class', 'lines')
      .selectAll('path')
      .data(this.nest, function(d) { return d.key; })
      .enter()
      .append('path')
      .attr('class', 'line')
      .attr('d', function(d) { d.line = this; return this.line(d.values); }.bind(this))
      .attr('stroke', function(d) { return this.color(d.key); }.bind(this));
  },
  _renderAxis: function() {    
    // X axis
    this.svg.select('.x.axis')
      .attr('transform', 'translate(0,' + this.height + ')');

    this.xAxis.tickPadding(5);
    this.xAxis.tickSize(0, 0);
    this.xAxis.scale(this.xScale);
    // this.xAxis.tickFormat(this._formatNumberX.bind(this));
    this.svg.select('.x.axis').call(this.xAxis);

    // Y axis      
    this.yAxis.tickSize(-this.width);
    this.yAxis.scale(this.yScale);
    this.yAxis.ticks(3, '%');
    // this.yAxis.tickFormat(this._formatNumberY.bind(this));
    this.svg.select('.y.axis').call(this.yAxis);

    // Remove the zero
    this.svg.selectAll(".y.axis .tick")
      .filter(function (d) { return d === 0;  })
      .remove();
    
    // Move y axis ticks on top of the chart
    this.svg.selectAll('.y.axis .tick text')
      .attr('text-anchor', 'start')
      .attr('dx', '0.25em')
      .attr('dy', '-0.55em');
  },
  _formatNumberX: function(d) {
  },
  _formatNumberY: function(d) {
  },
  _width: function() {
    return parseInt(d3.select(this.container).style('width'));
  },
  _height: function() {
    return this._width() * 0.45;
  },
  _resize: function() {
    this.width = this._width();
    this.height = this._height();

    this.updateRender();

    d3.select(this.container + ' svg')
      .attr('width', this.width + this.margin.left + this.margin.right)
      .attr('height', this.height + this.margin.top + this.margin.bottom)

    this.svg.select('.chart-container')
      .attr('transform', 'translate(' + this.margin.left + ',' + this.margin.top + ')');
  }
});
