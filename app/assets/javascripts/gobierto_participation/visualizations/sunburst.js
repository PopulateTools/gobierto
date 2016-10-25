var SunburstChart = Class.extend({

  init: function(options) {
    this.id = Math.floor((Math.random() * 100) + 1);
    this.selector = options.selector;
    this.margin = {top: 10, right: 0, bottom: 10, left: 0};
    this.svg = null;
    this.color = null;
    this.container = d3.select(this.selector);
    this.url = options.url;
    this.radius = null;
    this.partition = null;
    this.arc = null;
  },

  render: function(callback) {
    var chartWidth = 528;
    var chartHeight = 300;
    //var chartWidth = parseInt(this.container.style('width'), 10);
    //var chartHeight = parseInt(this.container.style('height'), 10);
    this.width = chartWidth - this.margin.left - this.margin.right;
    this.height = chartHeight - this.margin.top - this.margin.bottom;
    this.radius = Math.min(this.width, this.height) / 2;

    this.svg = this.container.append("svg")
      .attr("width", this.width + this.margin.left + this.margin.right)
      .attr("height", this.height + this.margin.top + this.margin.bottom)
      .append("g")
      .attr("transform", "translate(" + this.width / 2 + "," + this.height * .52 + ")");

    this.partition = d3.layout.partition()
      .sort(null)
      .size([2 * Math.PI, this.radius * this.radius])
      .value(function(d) { return 1; });

    this.arc = d3.svg.arc()
      .startAngle(function(d) { return d.x; })
      .endAngle(function(d) { return d.x + d.dx; })
      .innerRadius(function(d) { return Math.sqrt(d.y); })
      .outerRadius(function(d) { return Math.sqrt(d.y + d.dy); });

    d3.json(this.url, function(error, root) {
      if (error) throw error;
 
      this.color = d3.scale.ordinal().domain(root.children.map(function(e){ return e.code; })).range(colorbrewer.Set1[9]);

      // Stash the old values for transition.
      function stash(d) {
        d.x0 = d.x;
        d.dx0 = d.dx;
      }

      // Interpolate the arcs in data space.
      function arcTween(a) {
        var i = d3.interpolate({x: a.x0, dx: a.dx0}, a);
        return function(t) {
          var b = i(t);
          a.x0 = b.x;
          a.dx0 = b.dx;
          return this.arc(b);
        };
      }

      var maketip = function (d) {
        var tip = '<p class="tip3">' + d.name + '</p><p class="tip1">' + accounting.formatMoney(d.budget) + '</p><p>';
        return tip;
      }

      var value = function(d) { return d.budget; };
      var path = this.svg.datum(root).selectAll("path")
        .data(this.partition.value(value).nodes)
      .enter().append("path")
        .attr("display", function(d) { return d.depth ? null : "none"; }) // hide inner ring
        .attr("d", this.arc)
        .style("stroke", "#fff")
        .style("opacity", function(d) { console.log(d.depth); return 1 - d.depth*0.2; })
        .style("fill", function(d) { return this.color((d.children ? d : d.parent).code[0]); }.bind(this))
        .style("fill-rule", "evenodd")
        .attr('class', 'tipcircle')
        .attr('title', maketip)
        .each(stash);

      if(callback){
        callback();
      }
    }.bind(this));
  },

});
