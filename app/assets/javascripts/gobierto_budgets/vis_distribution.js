'use strict';

var VisDistribution = Class.extend({
  init: function(divId, measure, mean) {
    this.container = divId;
    
    // Chart dimensions
    this.containerWidth = null;
    this.margin = {top: 10, right: 22, bottom: 20, left: 10};
    this.width = null;
    this.height = null;
    
    // Variable 
    this.measure = measure;
    this.mean = mean;

    // Scales
    this.xScale = d3.scale.ordinal();
    this.yScale = d3.scale.linear();
    this.xMinMaxScale = d3.scale.linear();
    this.colorScale = d3.scale.ordinal();

    // Axis
    this.xAxis = d3.svg.axis();
    this.yAxis = d3.svg.axis();

    // Data
    this.data = null;
    this.dataChart = null;
    this.dataBuckets = null;
    this.dataMean = null;
    this.dataFreq = null; 
    this.dataDomain = null;
    this.kind = null;
    this.meanCut = null;

    // Objects
    this.tooltip = null;
    this.formatPercent = this.measure == 'percentage' ? d3.format('%') : d3.format(".2f");

    // Chart objects
    this.svgDistribution = null;
    this.chart = null;

    // Constant values
    this.opacity = .7;
    this.opacityLow = .4;
    this.duration = 1500;
    this.mainColor = '#F69C95';
    this.darkColor = '#B87570';
    this.niceCategory = null;
  },

  render: function(urlData) {

    // Chart dimensions
    this.containerWidth = parseInt(d3.select(this.container).style('width'), 10);
    this.width = this.containerWidth - this.margin.left - this.margin.right;
    this.height = (this.containerWidth / 1.9) - this.margin.top - this.margin.bottom;

    // Append tooltip
    this.tooltip = d3.select('body').append('div')
      .attr('class', 'vis_distribution_tooltip')
      .style('opacity', 0);


    // Append svg
    this.svgDistribution = d3.select(this.container).append('svg')
        .attr('width', this.width + this.margin.left + this.margin.right)
        .attr('height', this.height + this.margin.top + this.margin.bottom)
        .attr('class', 'svg_distribution')
      .append('g')
        .attr('transform', 'translate(' + this.margin.left + ',' + this.margin.top + ')');

    // Set nice category
    this.niceCategory = {
      "Actuaciones de carácter general": "Actuaciones Generales",
      "Actuaciones de carácter económico": "Actuaciones Económicas",
      "Producción de bienes públicos de carácter preferente": "Bienes Públicos",
      "Actuaciones de protección y promoción social": "Protección Social",
      "Servicios públicos básicos": "Servicios Públicos",
      "Deuda pública": "Deuda Pública",
      "mean_national": "Media Nacional",
      "mean_autonomy": "Media Autonómica",
      "mean_province": "Media Provincial",
      "G": "gasto/habitante",
      "I": "ingreso/habitante",
      "percentage": "% sobre el total"
    }

    // Load the data
    d3.json(urlData, function(error, jsonData){
      if (error) throw error;
      
      this.data = jsonData;
      
      // Map the data
      this.dataChart = this.data.budgets[this.measure].filter(function(d) { return d.name.match(/^(?!^mean)/) ; });
      this.dataBuckets = this.data.buckets[this.measure];
      this.dataMean = this.data.budgets[this.measure].filter(function(d) { return d.name.match(/^mean/) ; });
      this.kind = this.data.kind;

      
      // dataDomain, to plot the min & max labels    
      this.dataDomain = ([
        d3.min(this.dataChart, function(d) { return d.value; }),
        d3.max(this.dataChart, function(d) { return d.value; })
            ]);
      

      // Get the frequencies for every cut
     
      this.dataFreq = d3.nest()
            .key(function(d) { return d.cut; })
            .rollup(function(v) { return {"values": v.length, "label": v[0].label}; })
            .entries(this.dataChart)
            .map(function(d) {
              var key = d.key;
              var values = d.values.values;
              var label = d.values.label;
              
              return {'key':key, 'values':values, 'label': label}; 
            });

      // And the cuts with some frequency
      var currentBuckets = this.dataFreq.map(function(d) { return d.key; })

      // Fill the empty buckets
      this.dataBuckets.forEach(function(d) { 
        d.cut = d.cut.toString();
        if (currentBuckets.indexOf(d.cut) == -1) {
          var obj = {
            "key": d.cut,
            "label": d.label,
            "values": 0
          }
          this.dataFreq.push(obj)
        }
      }.bind(this));

      this.dataFreq.sort(function(a,b) { return (+a.key) - (+b.key); })

      // Set the scales
      this.xScale
        .domain(this.dataFreq.map(function(d) { return d.key; }))
        .rangeRoundBands([this.margin.left, this.width], .05);

      this.xMinMaxScale
        .domain(this.dataDomain)
        .range([this.margin.left, this.width])

      this.yScale
        .domain([0, d3.max(this.dataFreq, function(d) { return d.values; })]) 
        .range([this.height, this.margin.top]);


      // Define the axis 

      this.xMinMaxAxis = d3.svg.axis()
          .scale(this.xMinMaxScale)
          .tickValues(this.dataDomain)
          .tickFormat(function(d) { return this.measure != 'percentage' ? d3.round(d, 2) : d + '%'; }.bind(this))
          .orient("bottom");
      
      // --> DRAW THE AXIS
      // -> Draw xAxis (just draw the xMeanAxis)
      this.svgDistribution.append("g")
          .attr("class", "x axis")
          .attr("transform", "translate(0," + this.height + ")")
          .call(this.xMinMaxAxis);

      // Change ticks color
      d3.selectAll('.x.axis').selectAll('text')
        .style('fill', this.darkColor);


      // --> DRAW THE BAR CHART 
      this.chart = this.svgDistribution.append('g')
          .attr('class', 'distribution_chart');

      this.chart.append('g')
        .selectAll('rect')
          .data(this.dataFreq)
          .enter()
        .append('rect')
          .attr('class', function(d) { return 'bar_distribution c' + d.key; })
          .attr('x', function(d) { return this.xScale(d.key); }.bind(this))
          .attr('width', this.xScale.rangeBand())
          .attr('y', function(d) { return this.yScale(d.values); }.bind(this))
          .attr('height', function(d) { return this.height - this.yScale(d.values); }.bind(this))
          .attr('fill', this.mainColor)
        .on('mouseover', this._mouseover.bind(this))
        .on('mouseout', this._mouseout.bind(this));

      // --> HIGHLIGHT THE MEAN CUT 
      this.meanCut = this.dataMean[0].cut; 

      this.svgDistribution.selectAll('.bar_distribution.c' + this.meanCut)
          .attr('fill', d3.rgb(this.mainColor).darker(1));


    }.bind(this)); // end load data
  }, // end render

  updateRender: function () {
    
    // re-map the data
    this.dataChart = this.data.budgets[this.measure].filter(function(d) { return d.name.match(/^(?!^mean)/) ; });
    this.dataBuckets = this.data.buckets[this.measure];
    this.dataMean = this.data.budgets[this.measure].filter(function(d) { return d.name.match(/^mean/) ; });
    this.kind = this.data.kind;
    
    // dataDomain, to plot the min & max labels    
    this.dataDomain = ([
      d3.min(this.dataChart, function(d) { return d.value; }),
      d3.max(this.dataChart, function(d) { return d.value; })
          ]);
    
    // Get the frequencies for every cut
    this.dataFreq = d3.nest()
          .key(function(d) { return d.cut; })
          .rollup(function(v) { return {"values": v.length, "label": v[0].label}; })
          .entries(this.dataChart)
          .map(function(d) {
              var key = d.key;
              var values = d.values.values;
              var label = d.values.label;
              
              return {'key':key, 'values':values, 'label': label}; 
            });

    // And the cuts with some frequency
    var currentBuckets = this.dataFreq.map(function(d) { return d.key; })

    // Fill the empty buckets
    this.dataBuckets.forEach(function(d) { 
      d.cut = d.cut.toString();
      if (currentBuckets.indexOf(d.cut) == -1) {
        var obj = {
          "key": d.cut,
          "label": d.label,
          "values": 0
        }
        this.dataFreq.push(obj)
      }
    }.bind(this));

    this.dataFreq.sort(function(a,b) { return (+a.key) - (+b.key); })

    this.meanCut = this.dataMean[0].cut.toString()
    
    // Update the scales
    this.xMinMaxScale.domain(this.dataDomain);
    this.yScale.domain([0, d3.max(this.dataFreq, function(d) { return d.values; })]);
    
    // Update the axis
    this.xMinMaxAxis 
      .scale(this.xMinMaxScale)
      .tickValues(this.dataDomain)
      .tickFormat(function(d) { return this.measure != 'percentage' ? d3.round(d, 2) : d + '%'; }.bind(this));

    this.svgDistribution.select(".x.axis")
      .transition()
      .duration(this.duration)
      .delay(this.duration/4)
      .ease("sin-in-out") 
      .call(this.xMinMaxAxis);

    // Change ticks color
    this.svgDistribution.selectAll('.x.axis').selectAll('text')
      .style('fill', this.darkColor);

    this.svgDistribution.selectAll('.bar_distribution')
        .data(this.dataFreq)
        .transition()
        .duration(this.duration/2)
        .attr('y', function(d, i) { return this.yScale(d.values); }.bind(this))
        .attr('height', function(d) { return this.height - this.yScale(d.values); }.bind(this))
        .attr('fill', function(d) { return d.key != this.meanCut ? this.mainColor : this.darkColor; }.bind(this));
  },

  //PRIVATE
  _tickValues:  function (scale) {
    var range = scale.domain()[1] - scale.domain()[0];
    var a = range/4;
    return [scale.domain()[0], scale.domain()[0] + a, scale.domain()[0] + (a * 2), scale.domain()[1] - a, scale.domain()[1]];
  },

  _mouseover: function () {
    var selected = d3.event.target,
        selectedClass = selected.classList,
        selectedData = d3.select(selected).data()[0];

    if (this.measure == 'per_person') {
      var text = '<strong>' + selectedData.values + '</strong> municipios tienen un <strong><br>' + 
        this.niceCategory[this.kind] + ' <br>' + selectedData.label + '</strong>' 
    } else {
      var text = 'Para <strong>' + selectedData.values + '</strong> municipios el <strong><br>' + 
        this.niceCategory['percentage'] + ' es<strong><br>' + selectedData.label + '</strong>' 
    }
    
    this.tooltip
        .transition()
        .duration(this.duration / 4)
        .style('opacity', this.opacity);

    this.tooltip
        .html(text)
        .style('left', (d3.event.pageX + 50) + 'px')
        .style('top', (d3.event.pageY - 25) + 'px');

    this.svgDistribution.selectAll('.bar_distribution')
      .filter(function(d) { return 'c' + d.key != selectedClass[1]; }.bind(this))
      .transition()
      .duration(this.duration / 4)
      .style('opacity', .5);

  },

  _mouseout: function () {

    this.tooltip
        .transition()
        .duration(this.duration / 4)
        .style('opacity', 0);

    this.svgDistribution.selectAll('.bar_distribution')
      .transition()
      .duration(this.duration / 4)
      .style('opacity', 1);
  }

}); // End object








