var TreeMapChart = Class.extend({

  init: function(options) {
    this.id = Math.floor((Math.random() * 100) + 1);
    this.selector = options.selector;
    this.margin = {top: 0, right: 0, bottom: 0, left: 0};
    this.treemap = null;
    this.div = null;
    this.color = null;
    this.container = d3.select(this.selector);
    this.url = options.url;
  },

  render: function(callback) {
    var chartWidth = 528;
    var chartHeight = 300;
    //var chartWidth = parseInt(this.container.style('width'), 10);
    //var chartHeight = parseInt(this.container.style('height'), 10);
    this.width = chartWidth - this.margin.left - this.margin.right;
    this.height = chartHeight - this.margin.top - this.margin.bottom;

    this.treemap = d3.layout.treemap()
      .size([this.width, this.height])
      .sticky(true)
      .value(function(d) { return d.budget; });

    this.div = this.container.append("div")
      .style("position", "relative")
      .style("width", (this.width + this.margin.left + this.margin.right) + "px")
      .style("height", (this.height + this.margin.top + this.margin.bottom) + "px")
      .style("left", this.margin.left + "px")
      .style("top", this.margin.top + "px");

    function position() {
      this.style("left", function(d) { return d.x + "px"; })
        .style("top", function(d) { return d.y + "px"; })
        .style("width", function(d) { return Math.max(0, d.dx - 1) + "px"; })
        .style("height", function(d) { return Math.max(0, d.dy - 1) + "px"; });
    }

    function maketip(d) {
      var tip = '<p class="tip3">' + d.name + '</p><p class="tip1">' + accounting.formatMoney(d.budget) + '</p><p></p>';
      return tip;
    }

    d3.json(this.url, function(error, root){
      if (error) throw error;

      this.color = d3.scale.ordinal().domain(root.children.map(function(e){ return e.code; })).range(colorbrewer.Set1[5]);

      var node = this.div.datum(root).selectAll(".node")
        .data(this.treemap.nodes)
        .enter().append("div")
        .attr("class", "node tipcircle")
        .attr ("title", maketip)
        .call(position)
        .style("background", function(d) { return d.children ? this.color(d.code[0]) : null; }.bind(this))
        .text(function(d) { return d.children ? null : d.name; });

      if(callback)
        callback();

    }.bind(this));
  },

});
