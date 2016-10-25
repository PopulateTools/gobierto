'use strict';

var BarsVis = Class.extend({
  init: function(divId, mean, divLegend) {
    this.container = divId;
    this.containerLegend = divLegend;
    
    // Chart dimensions
    this.containerWidth = null;
    this.margin = {top: 10, right: 50, bottom: 20, left: 82};
    this.width = null;
    this.height = null;    
    
    // Variable 
    this.mean = mean;

    // Scales
    this.xScale = d3.scale.linear();
    this.yScale = d3.scale.ordinal();
    this.colorScale = d3.scale.ordinal();

    // Axis
    this.xAxis = d3.svg.axis();
    this.yAxis = d3.svg.axis();

    // Legend
    this.legendScale = d3.scale.ordinal()
    this.svgLegendBars = null;
    this.legendBars = d3.legend.color();

    // Data
    this.data = null;
    this.dataChart = null;
    this.chartTitle = null;
    this.kind= null;

    // Objects
    this.tooltip = null;
    this.formatPercent = this.measure == 'percentage' ? d3.format('%') : d3.format(".f");

    // Chart objects
    this.svgBars = null;
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
      .attr('class', 'vis_bars_tooltip')
      .style('opacity', 0);

    // Append svg
    this.svgBars = d3.select(this.container).append('svg')
        .attr('width', this.width + this.margin.left + this.margin.right)
        .attr('height', this.height + this.margin.top + this.margin.bottom)
        .attr('class', 'svg_chart')
        .style('background-color', d3.rgb(this.mainColor).brighter(1))
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
      "G": "Gasto/habitante",
      "I": "Ingreso/habitante",
      "percentage": "% sobre el total",
      "Gastos de personal": "Gastos de Personal",
      "Gastos en bienes corrientes y servicios": "Bienes y Servicios",
      "Gastos financieros": "Gastos Financieros",
      "Transferencias corrientes": "Transferencias Corrientes",
      "Fondo de contingencia y otros imprevistos": "Contingencias e Imprevistos",
      "Inversiones reales": "Inversiones Reales",
      "Transferencias de capital": "Transferencia de Capital",
      "Activos financieros": "Activos Financieros",
      "Pasivos financieros": "Pasivos Financieros",
      "Impuestos directos": "Impuestos Directos",
      "Impuestos indirectos": "Impuestos Indirectos",
      "Tasas y otros ingresos": "Tasas y Otros Ingresos",
      "Ingresos patrimoniales": "Ingresos Patrimoniales",
      "Enajenación de inversiones reales": "Enaj. Inversiones Reales"
    }

    // Load the data
    d3.json(urlData, function(error, jsonData){
      if (error) throw error;
      
      this.dataChart = jsonData.budgets;
      this.kind = jsonData.kind; 
      
      this.dataChart.sort(function(a, b) { return a.value - b.value; })
      
      // Get the values array to take the max
      var values = [];
      this.dataChart.forEach(function(d) {
        values.push(d.value, d.mean_national, d.mean_autonomy, d.mean_province)
      });

      // Set the scales
      this.xScale
        .domain([0, d3.max(values)])
        .range([0, this.width - this.margin.right]);


      this.yScale
        .domain(this.dataChart.map(function(d) { return d.name; })) 
        .rangeRoundBands([this.height, 0], .05);


      // Define the axis 

      this.xAxis
          .scale(this.xScale)
          .tickValues(this._tickValues(this.xScale))
          .tickFormat(function(d) { return d3.round(d, 2) + '€/hab'; })
          .orient("bottom");

      this.yAxis
          .scale(this.yScale)  
          .tickFormat(function(d) { return this.niceCategory[d]; }.bind(this))
          .orient("left");

      // --> DRAW THE AXIS
      // -> Draw xAxis (just draw the xMeanAxis)
      this.svgBars.append('g')
          .attr('class', 'x axis')
          .attr('transform', 'translate(' + this.margin.left + ',' + this.height + ')')
          .call(this.xAxis);

      // -> Draw yAxis
      this.svgBars.append('g')
          .attr('class', 'y axis')
          .attr('transform', 'translate(' + this.margin.left + ',0)')
          .call(this.yAxis);

      // Change ticks color
      d3.selectAll('.axis').selectAll('text')
        .attr('fill', this.darkColor);

      d3.selectAll('.x.axis').selectAll('text')
        .style('text-anchor', function(d, i) { return i == 0 ? 'start' : 'end' ; });
      

      // --> DRAW BARS CHART 
      this.chart = this.svgBars.append('g')
          .attr('class', 'chart');

      this.chart.append('g')
          .attr('class', 'bars')
        .selectAll('rect')
          .data(this.dataChart)
          .enter()
        .append('rect')
          .attr('class', function(d) { return 'bar ' + this._normalize(this.niceCategory[d.name]); }.bind(this))
          .attr('x', this.margin.left)
          .attr('width', 0)
          .attr('y', function(d) { return this.yScale(d.name); }.bind(this))
          .attr('height', this.yScale.rangeBand())
          .attr('fill', this.mainColor)
          .on('mouseover', this._mouseover.bind(this))
          .on('mouseout', this._mouseout.bind(this))

      this.chart.selectAll('.bar')
          .transition()
          .duration(this.duration)
          .attr('width', function(d) { return this.xScale(d.value); }.bind(this));

      // --> DRAW THE MEAN LINE 
      var meanGroup = this.chart.append('g')
          .attr('class', 'mean_lines')
          .attr('transform', 'translate(' + this.margin.left + ',0)');
          

      meanGroup.selectAll('.mean_line')
          .data(this.dataChart)
          .enter()
        .append('line')
          .attr('class', function(d) { return 'mean_line ' + this._normalize(this.niceCategory[d.name]); }.bind(this))
          .attr('x1', function(d) { return this.xScale(d[this.mean]); }.bind(this))
          .attr('y1', function(d) { return this.yScale(d.name); }.bind(this))
          .attr('x2', function(d) { return this.xScale(d[this.mean]); }.bind(this))
          .attr('y2', function(d) { return this.yScale(d.name) + this.yScale.rangeBand(); }.bind(this))
          .attr('stroke', this.darkColor)
          .attr('stroke-width', 2)
          .style('opacity', 0);

      this.chart.selectAll('.mean_line')
          .transition()
          .delay(this.duration / 1.2)
          .duration(this.duration / 2)
          .style('opacity', 1)


      // --> DRAW THE Legend 
      
      this.legendScale.domain([this.niceCategory[this.mean]]).range([this.darkColor]);

      this.svgLegendBars = d3.select(this.containerLegend).append('svg');

      this.svgLegendBars.append("g")
        .attr("class", "legend_bar")
        .attr('transform', 'translate(' + (this.margin.left / 1.5) + ',' + 2 + ')')
        
      this.legendBars
          .shapeWidth(2)
          .shapeHeight(20)
          .scale(this.legendScale);

      this.svgLegendBars.select(".legend_bar")
        .call(this.legendBars);

      this.svgLegendBars.select("text")
        .attr('fill', this.mainColor)
        .attr('font-size', '14px');


    }.bind(this)); // end load data
  }, // end render

  updateRender: function () {
    
    // Update the mean lines
    this.svgBars.selectAll('.mean_line')
      .transition()
      .duration(this.duration)
      .attr('x1', function(d) { return this.xScale(d[this.mean]); }.bind(this))
      .attr('x2', function(d) { return this.xScale(d[this.mean]); }.bind(this));

    // Update the legend
    this.legendScale.domain([this.niceCategory[this.mean]]);

    this.legendBars
        .scale(this.legendScale);
    
    this.svgLegendBars.select(".legend_bar")
        .call(this.legendBars);

  }, // end updateRender

  //PRIVATE
  _tickValues:  function (scale) {
    // var range = scale.domain()[1] - scale.domain()[0];
    // var a = range/4;
    return [scale.domain()[0], scale.domain()[1]]
    // return [scale.domain()[0], scale.domain()[0] + a, scale.domain()[0] + (a * 2), scale.domain()[1] - a, scale.domain()[1]];
  },

  _mouseover: function () {
    var selected = d3.event.target,
        selectedClass = selected.classList,
        selectedData = d3.select(selected).data()[0];


    var text = this.niceCategory[this.kind] + ': <strong>' + this.formatPercent(selectedData.value) + 
              '</strong>€<br>' + this.niceCategory[this.mean] + ': <strong>' + selectedData[this.mean] +
              '</strong>€<br>'+ this.niceCategory['percentage']+': <strong>' + selectedData.percentage + '</strong>%<br>';

    this.svgBars.selectAll('.bar')
      .filter(function(d) { return this._normalize(this.niceCategory[d.name]) != selectedClass[1]; }.bind(this))
      .transition()
      .duration(this.duration / 4)
      .style('opacity', .5);
    
    this.tooltip
        .transition()
        .duration(this.duration / 4)
        .style('opacity', this.opacity);

    this.tooltip
        .html(text)
        .style('left', (d3.event.pageX + 50) + 'px')
        .style('top', (d3.event.pageY - 25) + 'px');

  },

  _mouseout: function () {
    var selected = d3.event.target,
        selectedClass = selected.classList;

    this.svgBars.selectAll('.bar')
      .filter(function(d) { return this._normalize(this.niceCategory[d.name]) != selectedClass[1]; }.bind(this))
      .transition()
      .duration(this.duration / 4)
      .style('opacity', 1);

    this.tooltip.transition()
        .duration(this.duration / 4)
        .style("opacity", 0);
  },

  _normalize: (function() {
    var from = "ÃÀÁÄÂÈÉËÊÌÍÏÎÒÓÖÔÙÚÜÛãàáäâèéëêìíïîòóöôùúüûÑñÇç ", 
        to   = "AAAAAEEEEIIIIOOOOUUUUaaaaaeeeeiiiioooouuuunncc_",
        mapping = {};
   
    for(var i = 0, j = from.length; i < j; i++ )
        mapping[ from.charAt( i ) ] = to.charAt( i );
   
    return function( str ) {
        var ret = [];
        for( var i = 0, j = str.length; i < j; i++ ) {
            var c = str.charAt( i );
            if( mapping.hasOwnProperty( str.charAt( i ) ) )
                ret.push( mapping[ c ] );
            else
                ret.push( c );
        }      
        return ret.join( '' ).toLowerCase();
    }
 
  })()

}); // End object








