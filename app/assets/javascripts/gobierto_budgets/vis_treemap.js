'use strict';

var TreemapVis = Class.extend({
  init: function(divId, size, clickable){
    this.containerId = divId;

    // Chart dimensions
    this.containerWidth = null;
    this.margin = {top: 0, right: 0, bottom: 0, left: 0};
    this.width = null;
    this.height = null;

    this.sizeFactor = size == 'big' ? 5.5 : 2.5;
    this.clickable = clickable;

    this.treemap = null;
    this.container = null;

    // var colors = ['#FFD100', '#FE7000', '#ED2F00', '#940099', '#487304', '#4A73B0', '#1B4145', '#444300', '#24190E'];
    var colors = ['#FFBCC8', '#FF6181', '#EE2657', '#8C3044', '#516773', '#427991', '#1F3F4F', '#473D3F', '#24191B'];
    this.colorScale = d3.scale.ordinal().range(colors);

    this.opacity = 1;
    this.duration = 1;
  },

  render: function(urlData) {
    $(this.containerId).html('');

    // Chart dimensions
    this.containerWidth = parseInt(d3.select(this.containerId).style('width'), 10);
    this.width = this.containerWidth - this.margin.left - this.margin.right;
    this.height = (this.containerWidth / this.sizeFactor) - this.margin.top - this.margin.bottom;
    
    this.container = d3.select(this.containerId)
      .style("position", "relative")
      .style("width", (this.width + this.margin.left + this.margin.right) + "px")
      .style("height", (this.height + this.margin.top + this.margin.bottom) + "px")
      .style("left", this.margin.left + "px")
      .style("top", this.margin.top + "px");

    this.treemap = d3.layout.treemap()
      .size([this.width, this.height])
      .sticky(true)
      .sort(function comparator(b, a){
        return b.budget - a.budget;
      })
      .value(function(d) { return d.budget; });

    d3.json(urlData)
      .mimeType('application/json')
      .get(function(error, root){
        if (error) throw error;

        this.colorScale
          .domain(root.children.map(function(d) { return d.name; }));

        var node = this.container.datum(root).selectAll(".treemap_node")
          .data(this.treemap.nodes)
          .enter().append("div")
          .attr("class", function(d){
            if(this.clickable){
              return "tipsit-treemap treemap_node clickable";
            } else {
              return "tipsit-treemap treemap_node";
            }
          }.bind(this))
        .attr("title", function(d){ 
          return "<strong>" + d.name + "</strong><br>" + accounting.formatMoney(d.budget, "€", 0, '.') + "<br>" + accounting.formatMoney(d.budget_per_inhabitant, "€", 0, ',') + " /hab";
        }.bind(this))
        .attr("data-url", function(d){ 
          if(this.clickable){
            return d.children ? null : urlData.split('?')[0] + "?parent_code=" + d.code;
          }
        }.bind(this))
        .call(this._position)
        .style("background", function(d) { return this.colorScale(d.name); }.bind(this))
        .html(function(d) {
          if(d.children) {
            return null;
          } else {
            // If the square is small, don't add the text
            if(d.dx > 70 && d.dy > 90) {
              return "<p><strong>" + d.name + "</strong></p><p>" + accounting.formatMoney(d.budget_per_inhabitant, "€", 0) + "/hab</p>";
            }
          }
        })
        .call(rebindAll)
      }.bind(this));
  },

  _position: function() {
    this.style("left", function(d) { return d.x + "px"; })
      .style("top", function(d) { return d.y + "px"; })
      .style("width", function(d) { return Math.max(0, d.dx) + "px"; })
      .style("height", function(d) { return Math.max(0, d.dy) + "px"; });
  },
});
