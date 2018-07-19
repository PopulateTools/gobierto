import { Class, d3 } from "shared"

export var VisPopulationPyramid = Class.extend({
  init: function(divId, city_id, current_year) {
    this.container = divId
    this.currentYear = (current_year !== undefined) ? parseInt(current_year) : null
    this.data = null
    this.tbiToken = window.populateData.token
    this.dataUrl = `${window.populateData.endpoint}/datasets/ds-poblacion-municipal-edad-sexo.json?filter_by_date=${this.currentYear}&filter_by_location_id=${city_id}&except_columns=_id,province_id,location_id,autonomous_region_id`

    this.isMobile = window.innerWidth <= 768

    // Chart dimensions
    this.gutter = 10
    this.margin = {
      top: this.gutter * 1.5,
      right: this.gutter,
      bottom: this.gutter * 2.5,
      left: this.gutter * 4
    }
    this.width = this._getDimensions().width
    this.height = this._getDimensions().height

    // Scales & Ranges
    this.xScaleMale = d3.scaleLinear()
    this.xScaleFemale = d3.scaleLinear()
		this.yScale = d3.scaleBand().padding(0.2)

    // Create axes
    this.xAxisMale = d3.axisBottom()
    this.xAxisFemale = d3.axisBottom()
    this.yAxis = d3.axisRight()

    // Chart objects
    this.svg = null
    this.chart = null

    // Create main elements
    this.svg = d3.select(this.container)
      .append("svg")
      .attr("width", this.width + this.margin.left + this.margin.right)
      .attr("height", this.height + this.margin.top + this.margin.bottom)
      .append("g")
      .attr("class", "chart-container")
      .attr("transform", "translate(" + this.margin.left + "," + this.margin.top + ")")

    // Append axes containers
    this.svg.append("g").attr("class","x axis males")
    this.svg.append("g").attr("class","x axis females")
    this.svg.append("g").attr("class","y axis")

    // d3.select(window).on(`resize.${this.container}`, this._resize.bind(this))
  },
  getData: function() {
    d3.json(this.dataUrl)
      .header("authorization", "Bearer " + this.tbiToken)
      .get(function(error, jsonData) {
        if (error) throw error

        this.data = jsonData

        this.data.forEach(d => {
          d.age = parseInt(d.age)
          d.value = Number(d.value)
        })

        this.data.sort((a,b) => a.age - b.age)

        this.updateRender()
        this._renderBars()

      }.bind(this))
  },
  render: function() {
    if (this.data === null) {
      this.getData()
    } else {
      this.updateRender()
    }
  },
  updateRender: function() {
    this.xScaleMale
      .range([0, this.width / 2])
      .domain([d3.max(this.data.map(d => d.value)), 0])

    this.xScaleFemale
      .range([0, this.width / 2])
      .domain([0, d3.max(this.data.map(d => d.value))])

    this.yScale
      .rangeRound([this.height, 0])
      .domain(_.uniq(this.data.map(d => d.age)))

    this._renderAxis()
  },
  _renderAxis: function() {
    // X axes
    function xAxisMale(g) {
      g.call(this.xAxisMale.scale(this.xScaleMale))
      g.selectAll(".domain").remove()
      g.selectAll(".tick line").remove()
    }

    function xAxisFemale(g) {
      g.call(this.xAxisFemale.scale(this.xScaleFemale))
      g.selectAll(".domain").remove()
      g.selectAll(".tick:not(:first-child) line").remove()
      g.selectAll(".tick:first-child line")
        .attr("y1", -this.gutter)
        .attr("y2", -this.height)
    }

    this.svg.select(".x.axis.males")
      .attr("transform", `translate(0,${this.height - (this.margin.bottom / 2)})`)
      .call(xAxisMale.bind(this))
    this.svg.select(".x.axis.females")
      .attr("transform", `translate(${this.width / 2},${this.height - (this.margin.bottom / 2)})`)
      .call(xAxisFemale.bind(this))

    // Y axis
    function yAxis(g) {
      g.call(this.yAxis
        .scale(this.yScale)
        .tickValues(this.yScale.domain().filter((d,i) => !(i%10))))
      g.selectAll(".domain").remove()
      g.selectAll(".tick line")
        .attr("x1", 0)
        .attr("x2", this.width)
      g.selectAll(".tick text")
        .attr("x", -this.margin.left / 4)
    }

    this.svg.select(".y.axis").call(yAxis.bind(this))

    // Titles
    let titles = this.svg.append("g")
      .attr("class", "titles")

    titles.append("text")
      .attr("transform", `translate(${(this.width / 2) - this.gutter},0)`)
      .attr("text-anchor", "end")
      .text("Hombres")

    titles.append("text")
      .attr("transform", `translate(${(this.width / 2) + this.gutter},0)`)
      .attr("text-anchor", "start")
      .text("Mujeres")

    titles.append("text")
      .attr("text-anchor", "end")
      .text("Edad")
  },
  _renderBars: function() {
    // We keep this separate to not create them after every resize
    let g = this.svg.append("g")
      .attr("class", "bars")

    let male = g.append("g")
      .attr("class", "males")
      .selectAll("rect")
      .data(this.data.filter(d => d.sex === "V"))

    let female = g.append("g")
      .attr("class", "females")
      .selectAll("rect")
      .data(this.data.filter(d => d.sex === "M"))

    male.exit().remove()
    female.exit().remove()

    male.enter().append("rect")
      .attr("x", d => this.xScaleMale(d.value))
      .attr("y", d => this.yScale(d.age))
      .attr("width", d => (this.width / 2) - this.xScaleMale(d.value))
      .attr("height", this.yScale.bandwidth())
      .on("mousemove", this._mousemove.bind(this))
      .on("mouseout", this._mouseout.bind(this))

    female.enter().append("rect")
      .attr("x", this.width / 2)
      .attr("y", d => this.yScale(d.age))
      .attr("width", d => this.xScaleFemale(d.value))
      .attr("height", this.yScale.bandwidth())
      .on("mousemove", this._mousemove.bind(this))
      .on("mouseout", this._mouseout.bind(this))

    // Append tooltip group & children
    // var focusG = this.svg.append("g")
    //   .attr("class", "focus")
    //
    // focusG.append("text").attr("class", "focus-halo")
    // focusG.append("text").attr("class", "focus-text")
  },
  _mousemove: function(d) {
    // Move the whole group
    this.svg.select(".focus")
      .attr("text-anchor", "middle")
      .attr("transform", "translate(300, 0)")
      // .attr("transform", "translate(" + this.xScale(d.age) + "," + (this.yScale(d.value) -15) + ")")

    // Fill the halo and the tooltip
    // this.svg.select(".focus-halo")
    //   .attr("stroke", "white")
    //   .attr("stroke-width", "2px")
    //   .text("valor: " + d.value)

    this.svg.select(".focus-text")
      .text("x: " + d.age + " valor: " + d.value)
  },
  _mouseout: function() {
    // this.svg.select(".focus")
    //   .attr("transform", "translate(-100,-100)")
  },
  _getDimensions: function (opts = {}) {
    let ratio = opts.ratio || 4 / 3
    let width = opts.width || +d3.select(this.container).node().getBoundingClientRect().width / 2
    let height = opts.height || width / ratio

    return {
      ratio,
      width,
      height
    }
  },
  _resize: function() {
    // TODO: COmpletar
    this.width = this._getDimensions().width
    this.height = this._getDimensions().height

    this.updateRender()

    d3.select(`${this.container} svg`)
      .attr("width", this.width + this.margin.left + this.margin.right)
      .attr("height", this.height + this.margin.top + this.margin.bottom)

    this.svg.select(".chart-container")
      .attr("transform", "translate(" + this.margin.left + "," + this.margin.top + ")")

    // Update bars
    // d3.select("#age_distribution .bars").selectAll("rect")
    //   .attr("x", function(d) { return this.xScale(d.age) }.bind(this))
    //   .attr("y", function(d) { return this.yScale(d.value) }.bind(this))
    //   .attr("width", this.xScale.bandwidth())
    //   .attr("height", function(d) { return this.height - this.yScale(d.value) }.bind(this))
  }
})
