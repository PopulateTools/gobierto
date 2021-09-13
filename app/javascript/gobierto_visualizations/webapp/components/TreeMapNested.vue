<template>
  <div :class="`treemap-nested-container treemap-nested-container-${treemapId}`">
    <div
      :id="`treemap-nested-sidebar-${treemapId}`"
      class="treemap-nested-sidebar"
    >
      <div
        :id="`treemap-nested-sidebar-nav-${treemapId}`"
        class="treemap-nested-sidebar-nav"
      />
      <div
        :id="`treemap-nested-sidebar-button-group-${treemapId}`"
        class="treemap-nested-sidebar-button-group button-group"
      >
        <button
          :class="{ active : selected_size === firstButtonValue }"
          class="button-grouped sort-G"
          @click="handleTreeMapValue(firstButtonValue)"
        >
          {{ firstButtonLabel }}
        </button>
        <button
          :class="{ active : selected_size === secondButtonValue }"
          class="button-grouped sort-G"
          @click="handleTreeMapValue(secondButtonValue)"
        >
          {{ secondButtonLabel }}
        </button>
      </div>
    </div>
    <div
      :id="`treemap-nested-tooltip-first-depth-${treemapId}`"
      class="treemap-nested-tooltip-first"
    />
    <div
      :id="`treemap-nested-tooltip-second-depth-${treemapId}`"
      class="treemap-nested-tooltip-second"
    />
    <svg
      :id="`treemap-nested-${treemapId}`"
      :width="svgWidth"
      :height="svgHeight"
      class="treemap-nested"
    />
  </div>
</template>
<script>

import { select, selectAll, mouse } from 'd3-selection'
import { treemap, stratify, hierarchy, treemapBinary } from 'd3-hierarchy'
import { scaleLinear, scaleOrdinal } from 'd3-scale'
import { easeLinear } from 'd3-ease'
import { interpolate } from 'd3-interpolate';
import { sumDataByGroupKey } from "../lib/utils";
import { mean, median } from "d3-array";
import { nest } from "d3-collection";
import { createScaleColors, slugString } from "lib/shared";
import { money } from "lib/vue/filters";

const d3 = { select, selectAll, treemap, stratify, scaleLinear, scaleOrdinal, mouse, easeLinear, mean, median, nest, hierarchy, treemapBinary, interpolate }

export default {
  name: 'TreeMapNested',
  props: {
    data: {
      type: Array,
      default: () => []
    },
    rootData: {
      type: Object,
      default: () => {}
    },
    marginLeft: {
      type: Number,
      default: 0
    },
    marginRight: {
      type: Number,
      default: 0
    },
    marginTop: {
      type: Number,
      default: 30
    },
    marginBottom: {
      type: Number,
      default: 30
    },
    labelRootKey: {
      type: String,
      default: ''
    },
    height: {
      type: Number,
      default: 400
    },
    firstDepthForTreeMap: {
      type: String,
      default: ''
    },
    secondDepthForTreeMap: {
      type: String,
      default: ''
    },
    thirdDepthForTreeMap: {
      type: String,
      default: ''
    },
    treemapId: {
      type: String,
      default: ''
    },
    scaleColorKey: {
      type: String,
      default: ''
    },
    scaleColor: {
      type: Boolean,
      default: false
    },
    amount: {
      type: String,
      default: ''
    },
    firstButtonValue: {
      type: String,
      default: ''
    },
    secondButtonValue: {
      type: String,
      default: ''
    },
    firstButtonLabel: {
      type: String,
      default: ''
    },
    secondButtonLabel: {
      type: String,
      default: ''
    },
    labelTotalUnique: {
      type: String,
      default: ''
    },
    labelTotalPlural: {
      type: String,
      default: ''
    },
    keyForThirdDepth: {
      type: String,
      default: ''
    },
    depthEntity: {
      type: Boolean,
      default: false
    }
  },
  data() {
    return {
      svgWidth: 0,
      svgHeight: this.height,
      arrayValuesContractTypes: [],
      selected_size: this.amount,
      sizeForTreemap: this.amount,
      colors: []
    }
  },
  watch: {
    data(newValue, oldValue) {
      if (newValue !== oldValue) {
        this.dataNewValues = newValue
        this.transformDataTreemap(newValue)
      }
    },
    rootData(newValue, oldValue) {
      if (newValue !== oldValue) {
        this.buildTreeMap(newValue)
      }
    },
    $route(to, from) {
      if (to !== from) {
        this.containerChart = document.querySelector(`.treemap-nested-container-${this.treemapId}`);
        this.svgWidth = this.containerChart.offsetWidth;
        this.transformDataTreemap(this.data)
      }
    },
    scaleColorKey(newValue, oldValue) {
      if (newValue !== oldValue) {
        const freezeObjectColors = Object.freeze(this.data);
        this.arrayValuesContractTypes = Array.from(new Set(freezeObjectColors.map((d) => d[newValue])))
        this.colors = createScaleColors(this.arrayValuesContractTypes.length, this.arrayValuesContractTypes);
        this.transformDataTreemap(this.data)
      }
    }
  },
  mounted() {
    this.containerChart = document.querySelector(`.treemap-nested-container-${this.treemapId}`);
    this.svgWidth = this.containerChart.offsetWidth;
    /*To avoid add/remove colors in every update use Object.freeze(this.data)
    to create a scale/domain color persistent with the original keys*/
    const freezeObjectColors = Object.freeze(this.data);
    this.arrayValuesContractTypes = Array.from(new Set(freezeObjectColors.map((d) => d[this.scaleColorKey])))

    this.transformDataTreemap(this.data)

    window.addEventListener("resize", this.resizeListener)
  },
  destroyed() {
    window.removeEventListener("resize", this.resizeListener)
  },
  methods: {
    handleTreeMapValue(value) {
      this.closeTooltips()
      if (this.selected_size === value) return;
      this.selected_size = value
      this.sizeForTreemap = value
      this.transformDataTreemap(this.data)
    },
    transformDataTreemap(data) {
      this.$emit('transformData', data, this.sizeForTreemap)
    },
    buildTreeMap(rootData) {
      d3.select(`.treemap-container-${this.treemapId}`)
        .remove()
        .exit();
      d3.select(`.treemap-nested-sidebar-nav-breadcumb-${this.treemapId}`)
        .remove()
        .exit();

      this.closeTooltips()

      this.colors = createScaleColors(this.arrayValuesContractTypes.length, this.arrayValuesContractTypes);
      let transitioning;
      let dataTreeMapSumFinalAmount = this.data
      let firstDepthForTreeMap = this.firstDepthForTreeMap;
      let secondDepthForTreeMap = this.secondDepthForTreeMap;
      let thirdDepthForTreeMap = this.thirdDepthForTreeMap;
      let amountKey = this.amount
      let scaleColor = this.scaleColor
      let labelTotalContracts = this.labelTotalPlural
      let labelTotalUnique = this.labelTotalUnique
      let keyForThirdDepth = this.keyForThirdDepth
      let depthEntity = this.depthEntity
      let deepLevel
      const selected_size = this.selected_size;
      const treemapId = this.treemapId;

      const x = d3.scaleLinear()
        .domain([0, this.svgWidth])
        .range([0, this.svgWidth]);

      const y = d3.scaleLinear()
        .domain([0, this.height])
        .range([0, this.height]);

      const treemap = d3.treemap()
        .size([this.svgWidth, this.height])
        .paddingInner(0)
        .round(false);

      const containerChart = d3.select(`.treemap-nested-container-${treemapId}`)

      const svg = d3.select(`#treemap-nested-${treemapId}`)
        .append("g")
        .attr('class', `treemap-container-${treemapId}`)
        .style("shape-rendering", "crispEdges");

      containerChart.on('mouseleave', this.closeTooltips)

      const navBreadcrumbs = d3.select(`#treemap-nested-sidebar-nav-${treemapId}`)
        .append('p')
        .attr("class", `treemap-nested-sidebar-nav-breadcumb treemap-nested-sidebar-nav-breadcumb-${treemapId}`)

      const root = d3.hierarchy(rootData);
      treemap(root
        .sum(d => d.value)
        .sort((a, b) => b.height - a.height || b.value - a.value)
      );

      const display = (d) => {
        /*If the level has no parent, it means that we are in the first level,
        so we can know correctly the height of the treemap.*/
        if (d.parent === null) {
          deepLevel = d.height
        }
        navBreadcrumbs
          .datum(d.parent)
          .html(breadcrumbs(d))
          .call(checkSizeBreadcrumbs)

        navBreadcrumbs.selectAll("span")
          .datum(d)
          .on("click", function(d, event) {
            //If user clicked on the first breadcrumb goes to init from the second or third level.
            const firstDataBreadcrumb = root
            const secondDataBreadcrumb = d.parent
            const value = event === 0 ? firstDataBreadcrumb : secondDataBreadcrumb
            transition(value)
          })

        const g1 = svg
          .append("g")
          .datum(d)
          .attr('fill', d => {
            const { depth, data } = d
            const [ contracts ] = data?.children || []
            if (deepLevel === 4 && scaleColor && depth === 3) {
              return this.colors(contracts[this.firstDepthForTreeMap])
            } else if (deepLevel === 3 && scaleColor && depth === 2) {
              return this.colors(contracts[this.firstDepthForTreeMap])
            } else {
              return this.colors(d)
            }
          })
          .attr('class', 'depth')

        const g = g1.selectAll(".children")
          .data(d.children)
          .join("g")

        g.filter(d => d.children)
          .join('rect')
          .attr('class', 'children')
          .attr('fill', d => {
            const { depth, data, parent } = d
            const [ contracts ] = data?.children || []
            const { contractor } = contracts || {}
            return scaleColor && depth === 1 ? this.colors(data?.name) : scaleColor && depth === 2 ? this.colors(parent?.data?.name) : scaleColor && depth === 3 || depth === 4 ? this.colors(contractor) : this.colors(d)
          })
          .on("click", transition);

        const t = svg.transition()
          .duration(250)
          .ease(d3.easeLinear);

        g.selectAll(".child")
          .data(d => d.children || [d])
          .join(
            enter => enter.append("rect")
              .attr("x", ({ x0 }) => x(x0))
              .attr("y", ({ y0 }) => y(y0))
              .attr("width", ({ x1, x0 }) => x(x1) - x(x0))
              .attr("height", ({ y1, y0 }) => y(y1) - y(y0))
              .call(enter => enter.transition(t)),
            update => update
              .attr("x", ({ x0 }) => x(x0))
              .attr("y", ({ y0 }) => y(y0))
              .attr("width", ({ x1, x0 }) => x(x1) - x(x0))
              .attr("height", ({ y1, y0 }) => y(y1) - y(y0))
              .call(update => update.transition(t)),
            exit => exit
              .attr('width', 0)
              .attr('height', 0)
              .call(exit => exit.transition(t)
              .remove())
          )
          .attr("class", "child")

        g.append("rect")
          .attr("class", "parent")
          .call(rect)

        g.append("foreignObject")
          .call(rect)
          .attr("class", "foreignobj")
          .append("xhtml:div")
          .html(d => {
            const { x0, x1, y0, y1, depth, data, parent: { children } } = d
            if (typeof data === "function") {
              return
            }
            /*
              deepLevel: it's the depth or height that the treemap has
              depth: is the level we are at.
              calculateActualDepth: To know at which level of the treemap we are in
              regardless of the depth (it can be 2, 3, or 4), we subtract (deepLevel - depth).
            */
            const calculateActualDepth = deepLevel - depth
            const childrenLength = children.length ? children.length : 0
            const dimensionsElement = (x1 - x0) < 100 && (y1 - y0) < 100
            let htmlTreeMap
            if (dimensionsElement && calculateActualDepth > 0 && childrenLength > 100) {
              return
            } else if (dimensionsElement && calculateActualDepth === 0 && childrenLength > 20) {
              return htmlTreeMap = buildLastDepthOnlyLink(d)
            }
            if (depthEntity && deepLevel === 4) {
              htmlTreeMap = treeMapThreeDepth(d)
            } else if (deepLevel === 2) {
              htmlTreeMap = treeMapFirsthDepth(d)
            } else {
              htmlTreeMap = treeMapTwoDepth(d)
            }
            return htmlTreeMap
          })
          .attr('class', 'treemap-nested-container-text')

        g.selectAll('.treemap-nested-container-text')
          .attr('class', function(d) {
            const element = this
            const { depth } = d
            //y1 - y0 returns the height of the rect, if it's less than the 100 hide the text
            if (depth === 1 && element.clientHeight < 100 || element.clientWidth < 100) {
              return 'treemap-nested-container-text hide-text'
            } else if (depth === 1 && element.clientHeight < 100 || element.clientWidth < 100) {
              return 'treemap-nested-container-text hide-text'
            } else if (depth === 3) {
              let contractType = d.data.contract_type || ''
              //Normalize and create an slug because Servicios de Gestión Públicos isn't a valid css class
              contractType = slugString(contractType)
              return `treemap-nested-container-text ${contractType}`
            }
            return 'treemap-nested-container-text'
          })

        g.selectAll(".foreignobj")
          .on('mousemove', (d, i, event) => {
            const { depth } = d
            if (depth !== 1) {
              this.$emit('showTooltip', d, i, selected_size, event)
            }
          })

        const self = this

        function transition(d) {
          if (transitioning || !d) return;

          self.closeTooltips()

          transitioning = true;
          const g2 = display(d);
          const t1 = g1.transition().duration(450).ease(d3.easeLinear);
          const t2 = g2.transition().duration(450).ease(d3.easeLinear);
          // Update the domain only after entering new elements.
          x.domain([d.x0, d.x1]);
          y.domain([d.y0, d.y1]);
          // Enable anti-aliasing during the transition.
          svg.style("shape-rendering", null);
          // Draw child nodes on top of parent nodes.
          svg.selectAll(".depth").sort((a, b) => a.depth - b.depth);
          g2.selectAll("foreignObject div").style("display", "none");
          /*added*/
          t1.selectAll("rect").call(rect);
          t2.selectAll("rect").call(rect);
          /* Foreign object */
          t1.selectAll(".treemap-nested-container-text").style("display", "none");
          /* added */
          t1.selectAll(".foreignobj").call(foreign);
          /* added */
          t2.selectAll(".treemap-nested-container-text").style("display", "block").attr('class', function(d) {
            const { depth, x0, x1, y0, y1 } = d
            //y1 - y0 returns the height of the rect, if it's less than the 100 hide the text
            if (depth === 1 && (y(y1) - y(y0)) < 100 || (x(x1) - x(x0)) < 100) {
              return 'treemap-nested-container-text hide-text'
            } else if (depth === 1 && (y(y1) - y(y0)) < 100 || (x(x1) - x(x0)) < 150) {
              return 'treemap-nested-container-text hide-text'
            } else if (depth === 3) {
              let contractType = d.data.contract_type || ''
              //Normalize and create an slug because Servicios de Gestión Públicos isn't a valid css class
              contractType = slugString(contractType)
              return `treemap-nested-container-text ${contractType}`
            }
            return 'treemap-nested-container-text'
          });
          /* added */
          t2.selectAll(".foreignobj").call(foreign);
          /* added */
          // Remove the old node when the transition is finished.
          t1.on("end.remove", function() {
            this.remove();
            transitioning = false;
          });
          labelTotalContracts = self.labelTotalPlural

          const { depth } = d
          const calculateActualDepth = deepLevel - depth
          if (calculateActualDepth === 1) {
            self.injectRouter()
          }
        }

        function treeMapFirsthDepth(d) {
          /*We can changes the text content of every rect with d.depth
          d.depth = 1 is the first level, type of contracts
          d.depth = 2 is the second level, beneficiaries by type of contracts
          d.depth = 3 is the last level, contracts of beneficiaries*/
          let title = d.data.name === undefined ? d.data[keyForThirdDepth] : d.data.name;
          let htmlForRect = ''
          const { depth } = d
          if (depth === 1) {
            const children = d.children
            let totalContracts = 0;

            if (children) {
              totalContracts = children.length
            }
            const valueTotalAmount = calculateTotalAmount(d)

            if (totalContracts) {
              labelTotalContracts = totalContracts.length <= 1 ? labelTotalUnique : labelTotalContracts
            }
            htmlForRect = `<p class="title">${title}</p>
              <p class="text">${money(valueTotalAmount)}</p>
              <p class="text">
                <b>${totalContracts}</b> ${labelTotalContracts}</b>
              </p>
              `
          } else if (depth === 2 && typeof d.data !== "function") {
            htmlForRect = buildLastDepth(d)
          }
          return htmlForRect
        }

        function treeMapTwoDepth(d) {
          /*We can changes the text content of every rect with d.depth
          d.depth = 1 is the first level, type of contracts
          d.depth = 2 is the second level, beneficiaries by type of contracts
          d.depth = 3 is the last level, contracts of beneficiaries*/
          let title = d.data.name === undefined ? d.data[keyForThirdDepth] : d.data.name;
          let htmlForRect = ''
          const { depth } = d
          if (depth === 1) {
            const children = d.children
            let totalContracts = 0;

            if (children) {
              children.forEach(d => {
                if (d.data.children !== undefined) {
                  let elementLength = d.data.children
                  elementLength = elementLength.filter(children => children.value >= 0)
                  totalContracts += elementLength.length;
                }
              })
            }

            if (totalContracts) {
              labelTotalContracts = totalContracts.length <= 1 ? labelTotalUnique : labelTotalContracts
            }

            const valueTotalAmount = calculateTotalAmount(d)

            htmlForRect = `<p class="title">${title}</p>
              <p class="text">${money(valueTotalAmount)}</p>
              <p class="text">
                <b>${totalContracts}</b> ${labelTotalContracts}</b>
              </p>
              `
          } else if (depth === 2 && typeof d.data !== "function") {
            htmlForRect = buildMiddleDepth(d, secondDepthForTreeMap)
          } else if (depth === 3 && typeof d.data !== "function") {
            htmlForRect = buildLastDepth(d)
          }
          return htmlForRect
        }

        function treeMapThreeDepth(d) {
          /*We can changes the text content of every rect with d.depth
          d.depth = 1 is the first level, type of contracts
          d.depth = 2 is the second level, beneficiaries by type of contracts
          d.depth = 3 is the last level, contracts of beneficiaries*/
          let title = d.data.name === undefined ? d.data[keyForThirdDepth] : d.data.name;
          let htmlForRect = ''
          const { depth } = d
          if (depth === 1) {
            const children = d.children
            let totalContracts = 0;
            if (children) {
              children.forEach(d => {
                if (d.data.children !== undefined) {
                  d.data.children.forEach(d => {
                    if (d.children) {
                      let elementLength = d.children
                      elementLength = elementLength.filter(children => children.value >= 0)
                      totalContracts += elementLength.length;
                    }
                  })
                }
              })
            }
            const valueTotalAmount = calculateTotalAmount(d)

            if (totalContracts) {
              labelTotalContracts = totalContracts.length <= 1 ? labelTotalUnique : labelTotalContracts
            }
            htmlForRect = `<p class="title">${title}</p>
              <p class="text">${money(valueTotalAmount)}</p>
              <p class="text">
                <b>${totalContracts}</b> ${labelTotalContracts}</b>
              </p>
              `
          } else if (depth === 2 && typeof d.data !== "function") {
            htmlForRect = buildMiddleDepth(d, secondDepthForTreeMap)
          } else if (depth === 3 && typeof d.data !== "function") {
            htmlForRect = buildMiddleDepth(d, thirdDepthForTreeMap)
          } else if (depth === 4 && typeof d.data !== "function") {
            htmlForRect = buildLastDepth(d)
          }
          return htmlForRect
        }

        function calculateTotalAmount(d) {
          let valueTotalAmount
          if (typeof d.data !== "function") {
            let contractType = d.data.name !== undefined ? d.data.name : ''
            const finalAmountTotal = sumDataByGroupKey(dataTreeMapSumFinalAmount, firstDepthForTreeMap, amountKey)
            let totalAmount = finalAmountTotal.filter(contract => contract[firstDepthForTreeMap] === contractType)
            totalAmount = totalAmount.filter(contract => typeof contract.data !== "function")
            valueTotalAmount = totalAmount[0][amountKey]
          }

          return valueTotalAmount = selected_size === amountKey ? d.value : valueTotalAmount
        }

        function buildMiddleDepth(d, property) {
          let title = d.data.name === undefined ? d.data[keyForThirdDepth] : d.data.name;
          let valueTotalAmount
          if (typeof d.data !== "function") {
            let contractType = d.data.name !== undefined ? d.data.name : ''
            const finalAmountTotal = sumDataByGroupKey(dataTreeMapSumFinalAmount, property, amountKey)
            let totalAmount = finalAmountTotal.filter(contract => contract[property] === contractType)
            totalAmount = totalAmount.filter(contract => typeof contract.data !== "function")
            valueTotalAmount = totalAmount[0][amountKey]
          }

          valueTotalAmount = selected_size === amountKey ? d.value : valueTotalAmount

          let totalContracts = d.children === undefined ? '' : d.children
          if (totalContracts) {
            totalContracts = totalContracts.filter(contract => typeof contract.data !== "function").length
            labelTotalContracts = totalContracts <= 1 ? labelTotalUnique : labelTotalContracts
          }
          return `<p class="title">${title}</p>
            <p class="text">${money(valueTotalAmount)}</p>
            <span class="text">
              <b>${totalContracts}</b> ${labelTotalContracts}</b>
            </span>
            `
        }

        function buildLastDepth(d) {
          let title = d.data.name === undefined ? d.data[keyForThirdDepth] : d.data.name;
          const { parent: { data: { name } }, data: { href } } = d
          return `
            <a href="${href}" class="link-last-depth">
              <p class="title">${name}</p>
              <p class="text">${title}</p>
            </a>
            `
        }

        function buildLastDepthOnlyLink(d) {
          const { parent: { data: { href } } } = d
          return `
            <a href="${href}" class="link-last-depth"></a>
            `
        }

        return g;
      }

      display(root);

      function rect(rect) {
        rect
          .attr("x", ({ x0 }) => x(x0))
          .attr("y", ({ y0 }) => y(y0))
          .attr("width", ({ x1, x0 }) => x(x1) - x(x0))
          .attr("height", ({ y1, y0 }) => y(y1) - y(y0))
          .transition()
          .duration(500)
          .ease(d3.easeLinear)
          .attr("x", ({ x0 }) => x(x0))
          .attr("y", ({ y0 }) => y(y0))
          .attr("width", ({ x1, x0 }) => x(x1) - x(x0))
          .attr("height", ({ y1, y0 }) => y(y1) - y(y0))
      }

      function foreign(foreign) {
        foreign
          .attr("x", ({ x0 }) => x(x0))
          .attr("y", ({ y0 }) => y(y0))
          .attr("width", ({ x1, x0 }) => x(x1) - x(x0))
          .attr("height", ({ y1, y0 }) => y(y1) - y(y0))
          .transition()
          .duration(500)
          .ease(d3.easeLinear)
          .attr("x", ({ x0 }) => x(x0))
          .attr("y", ({ y0 }) => y(y0))
          .attr("width", ({ x1, x0 }) => x(x1) - x(x0))
          .attr("height", ({ y1, y0 }) => y(y1) - y(y0));
      }

      function breadcrumbs(d) {
        let res = "";
        const sep = ` <i style="display: inline-block; vertical-align: middle;" class="fas fa-angle-right"></i> `;
        d.ancestors().reverse().forEach(({ data }) => {
          if (res.includes('<b>')) {
            res = res.replace(/<b>/g, '').replace(/<\/b>/g, '')
          }
          res += `<span class="treemap-nested-breadcrumb treemap-nested-breadcrumb-${treemapId}"><b>${data.name}</b></span>` + sep;
        });
        return res.split(sep).filter(i => i !== "").join(sep);
      }

      function checkSizeBreadcrumbs() {
        /*In breadcrumbs, any level can be the largest, so we have to know which element is the largest to add the ellipsis class.*/
        //Get all elements
        const sizeBreadcrumbs = document.querySelectorAll(`.treemap-nested-breadcrumb-${treemapId}`)
        //Convert nodeList into array
        const breadcrumbsArr = [...sizeBreadcrumbs];
        //Sum offsetWidth
        const sidebarNav = breadcrumbsArr.reduce((prev, { offsetWidth }) => prev + offsetWidth, 0);

        //Create an array only with the offsetWidth
        const breadcrumbWidth = breadcrumbsArr.map(({ offsetWidth }) => offsetWidth);
        //Get the max value
        const maxValue = Math.max(...breadcrumbWidth);
        //Get the index of the max value
        const indexBreadcumb = breadcrumbWidth.indexOf(maxValue);

        const sidebarAvailableWidth = (document.querySelector('.treemap-nested-sidebar').offsetWidth - document.querySelector('.treemap-nested-sidebar-button-group').offsetWidth)

        if (sidebarNav > sidebarAvailableWidth) {
          sizeBreadcrumbs[indexBreadcumb].classList.add('ellipsis')
        }
      }
    },
    resizeListener() {
      this.svgWidth = this.containerChart.offsetWidth
      this.transformDataTreemap(this.data)
    },
    injectRouter() {
      this.closeTooltips()
      const contractsLink = document.querySelectorAll(`.treemap-nested-container-${this.treemapId} a.link-last-depth`)
      contractsLink.forEach(contract => contract.addEventListener('click', (e) => {
        e.preventDefault();
        const {
          target: {
            parentNode: {
              __data__: {
                data
              }
            }
          }
        } = e
        this.$emit('on-treemap-click', data)
      }))
    },
    closeTooltips() {
      const tooltipFirstDepth = d3.select(`#treemap-nested-tooltip-first-depth-${this.treemapId}`)
      const tooltipSecondDepth = d3.select(`#treemap-nested-tooltip-second-depth-${this.treemapId}`)

      tooltipSecondDepth
        .style("opacity", 1)
        .transition()
        .duration(200)
        .style("opacity", 0)
        .style("display", "none")

      tooltipFirstDepth
        .style("opacity", 1)
        .transition()
        .duration(200)
        .style("opacity", 0)
        .style("display", "none")
    }
  }
}
</script>
