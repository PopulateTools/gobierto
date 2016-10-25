var LineChart = Class.extend({

  init: function(options) {
    this.id = Math.floor((Math.random() * 100) + 1);
    this.selector = options.selector;
    //this.margin = {top: 30, right: 20, bottom: 30, left: 120};
    this.margin = {top: 0, right: 20, bottom: 30, left: 20};
    this.svg = null;
    //this.color = d3.scale.category10();
    this.container = d3.select(this.selector);
    this.url = options.url;
    this.headers = null;
  },

  render: function(callback) {
    var chartWidth = 528;
    var chartHeight = 300;
    //var chartWidth = parseInt(this.container.style('width'), 10);
    //var chartHeight = parseInt(this.container.style('height'), 10);
    this.width = chartWidth - this.margin.left - this.margin.right;
    this.height = chartHeight - this.margin.top - this.margin.bottom;

    this.x = d3.time.scale().range([0, this.width]);
    this.y = d3.scale.linear().range([this.height, 0]);
    this.xAxis = d3.svg.axis()
      .scale(this.x)
      .orient("bottom");

    //this.yAxis = d3.svg.axis()
      //.scale(this.y)
      //.orient("left")
      //.tickFormat(function(d) { return accounting.formatMoney(d); });

    this.svg = this.container.append("svg")
      .attr("width", this.width + this.margin.left + this.margin.right)
      .attr("height", this.height + this.margin.top + this.margin.bottom)
      .append("g")
      .attr("transform", "translate(" + this.margin.left + "," + this.margin.top + ")");

    var line = d3.svg.line()
      .x(function(d) { return this.x(d.date); }.bind(this))
      .y(function(d) { return this.y(d.budget); }.bind(this));

    var parseDate = d3.time.format('%Y').parse;

    d3.json(this.url, function(error, data) {
      if (error) throw error;

      //this.color.domain(data.map(function(d){ return d.name }));
      var copy = [];
      copy.push(data[0]);
      data = copy;

      data.forEach(function(d) {
        d.values.forEach(function(v){
          v.date = parseDate(v.date.toString());
        })
      });

      var years = data[0].values.map(function(d){ return d.date });
      this.xAxis.tickValues(years);
      this.x.domain(d3.extent(years));

      var values = d3.merge(data.map(function(d){ return d.values.map(function(v){ return parseFloat(v.budget);}) }));
      var factor = 0.1;
      this.y.domain([ d3.min(values) - d3.min(values) * 0.5, d3.max(values) + d3.max(values) * factor]);

      this.svg.append("g")
        .attr("class", "x axis")
        .attr("transform", "translate(0," + this.height + ")")
        .call(this.xAxis);

      //this.svg.append("g")
        //.attr("class", "y axis")
        //.call(this.yAxis)

      var budget = this.svg.selectAll(".budget")
        .data(data)
        .enter().append("g")
        .attr("class", "budget");

      budget.append("path")
        .attr("class", "line")
        .attr("d", function(d) { return line(d.values); });

      var maketip = function (d) {
        var tip = '<p class="tip3">' + d.name + '</p><p class="tip1">' + accounting.formatMoney(d.budget) + '</p> <p class="tip3">'+  d.date.getFullYear() +'</p>';
        return tip;
      }

      budget.selectAll("circle")
        .data(function(d){ return(d.values); })
        .enter()
        .append("circle")
        .attr("class","tipcircle")
        .attr("cx", function(d,i){return this.x(d.date)}.bind(this))
        .attr("cy",function(d,i){return this.y(d.budget)}.bind(this))
        .style('fill', '#BCC41A')
        .attr("r",4)
        .style('opacity', 1)//1e-6
        .attr ("title", maketip);

      if(callback){
        callback();
      }
    }.bind(this));
  },

});
