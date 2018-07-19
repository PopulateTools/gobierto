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
    this.width = {
      chart: this._getDimensions().width,
      pyramid: this._getDimensions().pyramid.width,
      areas: this._getDimensions().areas.width,
      markers: this._getDimensions().markers.width
    }
    this.height = {
      chart: this._getDimensions().height,
      pyramid: this._getDimensions().pyramid.height,
      areas: this._getDimensions().areas.height,
      markers: this._getDimensions().markers.height
    }

    // Scales & Ranges
    this.xScaleMale = d3.scaleLinear()
    this.xScaleFemale = d3.scaleLinear()
    this.xScaleAgeRanges = d3.scaleLinear()
		this.yScale = d3.scaleBand().padding(0.2)

    // Create axes
    this.xAxisMale = d3.axisBottom()
    this.xAxisFemale = d3.axisBottom()
    this.yAxis = d3.axisRight()

    // Chart objects
    this.svg = null
    this.pyramid = null
    this.areas = null
    this.markers = null

    // Create main elements
    this.svg = d3.select(this.container)
      .append("svg")
      .attr("width", this.width.chart + this.margin.left + this.margin.right)
      .attr("height", this.height.chart + this.margin.top + this.margin.bottom)
      .append("g")
      .attr("class", "chart-container")
      .attr("transform", "translate(" + this.margin.left + "," + this.margin.top + ")")

    this.pyramid = this.svg.append("g").attr("class", "pyramid")
    this.areas = this.svg.append("g")
      .attr("class", "areas")
      .attr("transform", `translate(${this.width.pyramid + this.gutter},0)`)
    this.markers = this.svg.append("g")
      .attr("class", "markers")
      .attr("transform", `translate(${this.width.pyramid + this.width.areas + this.gutter},0)`)

    // Append axes containers
    this.pyramid.append("g").attr("class","x axis males")
    this.pyramid.append("g").attr("class","x axis females")
    this.pyramid.append("g").attr("class","y axis")

    // d3.select(window).on(`resize.${this.container}`, this._resize.bind(this))
  },
  getData: function() {
    d3.json(this.dataUrl)
      .header("authorization", "Bearer " + this.tbiToken)
      .get(function(error, jsonData) {
        if (error) throw error

        jsonData.forEach(d => {
          d.age = parseInt(d.age)
          d.value = Number(d.value)
        })

        jsonData.sort((a,b) => a.age - b.age)

        const aux = {
          pyramid: jsonData,
          areas: this._transformAreasData(jsonData)
        }

        this.data = aux

        this.updateRender()
        this._renderBars()
        this._renderAreas()

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
      .range([0, this.width.pyramid / 2])
      .domain([d3.max(this.data.pyramid.map(d => d.value)), 0])

    this.xScaleFemale
      .range([0, this.width.pyramid / 2])
      .domain([0, d3.max(this.data.pyramid.map(d => d.value))])

    this.xScaleAgeRanges
      .range([0, this.width.areas / 3])
      .domain([d3.max(this.data.areas.map(d => d.value)), 0])

    this.yScale
      .rangeRound([this.height.pyramid, 0])
      .domain(_.uniq(this.data.pyramid.map(d => d.age)))

    this._renderAxis()
  },
  _transformAreasData: function (data, breakpoints) {
    let bp = breakpoints || [18, 65]
    return [
      {
        name: "Young",
        range: [d3.min(data.map(d => d.age)), bp[0] - 1],
        value: data.filter(d => d.age < bp[0]).map(d => d.value).reduce((a,b)=>a+b)
      },
      {
        name: "Adult",
        range: [bp[0], bp[1] - 1],
        value: data.filter(d => d.age < bp[1] && d.age >= bp[0]).map(d => d.value).reduce((a,b)=>a+b)
      },
      {
        name: "Elder",
        range: [bp[1], d3.max(data.map(d => d.age))],
        value: data.filter(d => d.age >= bp[1]).map(d => d.value).reduce((a,b)=>a+b)
      }
    ]
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
        .attr("y2", -this.height.pyramid)
    }

    this.pyramid.select(".x.axis.males")
      .attr("transform", `translate(0,${this.height.pyramid - (this.margin.bottom / 2)})`)
      .call(xAxisMale.bind(this))
    this.pyramid.select(".x.axis.females")
      .attr("transform", `translate(${this.width.pyramid / 2},${this.height.pyramid - (this.margin.bottom / 2)})`)
      .call(xAxisFemale.bind(this))

    // Y axis
    function yAxis(g) {
      g.call(this.yAxis
        .scale(this.yScale)
        .tickValues(this.yScale.domain().filter((d,i) => !(i%10))))
      g.selectAll(".domain").remove()
      g.selectAll(".tick line")
        .attr("x1", 0)
        .attr("x2", this.width.pyramid)
      g.selectAll(".tick text")
        .attr("x", -this.margin.left / 4)
    }

    this.pyramid.select(".y.axis").call(yAxis.bind(this))

    // Titles
    let titles = this.pyramid.append("g")
      .attr("class", "titles")

    titles.append("text")
      .attr("transform", `translate(${(this.width.pyramid / 2) - this.gutter},0)`)
      .attr("text-anchor", "end")
      .text("Hombres")

    titles.append("text")
      .attr("transform", `translate(${(this.width.pyramid / 2) + this.gutter},0)`)
      .attr("text-anchor", "start")
      .text("Mujeres")

    titles.append("text")
      .attr("text-anchor", "end")
      .text("Edad")
  },
  _renderBars: function() {
    // We keep this separate to not create them after every resize
    let g = this.pyramid.append("g")
      .attr("class", "bars")

    let male = g.append("g")
      .attr("class", "males")
      .selectAll("rect")
      .data(this.data.pyramid.filter(d => d.sex === "V"))

    let female = g.append("g")
      .attr("class", "females")
      .selectAll("rect")
      .data(this.data.pyramid.filter(d => d.sex === "M"))

    male.exit().remove()
    female.exit().remove()

    male.enter().append("rect")
      .attr("x", d => this.xScaleMale(d.value))
      .attr("y", d => this.yScale(d.age))
      .attr("width", d => (this.width.pyramid / 2) - this.xScaleMale(d.value))
      .attr("height", this.yScale.bandwidth())
      .on("mousemove", this._mousemove.bind(this))
      .on("mouseout", this._mouseout.bind(this))

    female.enter().append("rect")
      .attr("x", this.width.pyramid / 2)
      .attr("y", d => this.yScale(d.age))
      .attr("width", d => this.xScaleFemale(d.value))
      .attr("height", this.yScale.bandwidth())
      .on("mousemove", this._mousemove.bind(this))
      .on("mouseout", this._mouseout.bind(this))
  },
  _renderAreas: function() {
    let g = this.areas.selectAll("g")
      .data(this.data.areas)

    g.exit().remove()

    let ranges = g.enter().append("g")
      .attr("class", (d, i) => `range age-${i}`)

    ranges.append("rect")
      .attr("x", d => this.xScaleAgeRanges(d.value))
      .attr("y", d => this.yScale(d.range[1]))
      .attr("width", d => (this.width.areas / 3) - this.xScaleAgeRanges(d.value))
      .attr("height", d => this.yScale(d.range[0]) - this.yScale(d.range[1]))

    ranges.append("text")
      .attr("x", (this.width.areas / 3) + this.gutter)
      .attr("y", d => this.yScale(d.range[1]) + (1.5 * this.gutter))
      .attr("class", "title")
      .text(d => d.name)

    ranges.append("text")
      .attr("x", (this.width.areas / 3) + this.gutter)
      .attr("y", d => this.yScale(d.range[1]) + (1.5 * this.gutter))
      .attr("dy", "1.5em")
      .attr("class", "subtitle")
      .text("Tarari tarará")
  },
  _mousemove: function() {

  },
  _mouseout: function() {

  },
  _getDimensions: function (opts = {}) {
    let ratio = opts.ratio || 2.5
    let width = opts.width || +d3.select(this.container).node().getBoundingClientRect().width
    let height = opts.height || width / ratio

    let pyramid = {
      width: width / 2,
      height
    }
    let areas = {
      width: width / 4,
      height
    }
    let markers = {
      width: width / 4,
      height
    }

    return {
      ratio,
      width,
      height,
      pyramid,
      areas,
      markers
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
