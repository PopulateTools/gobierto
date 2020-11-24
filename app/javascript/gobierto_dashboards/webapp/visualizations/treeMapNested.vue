<template>
  <div class="container-tree-map-nested">
    <div class="treemap-button-group button-group">
      <button
        class="button-grouped sort-G"
        :class="{ active : selected_size == 'final_amount_no_taxes' }"
        @click="handleTreeMapValue('final_amount_no_taxes')"
      >
        {{ labelContractAmount }}
      </button>
      <button
        class="button-grouped sort-G"
        :class="{ active : selected_size == 'number_of_contract' }"
        @click="handleTreeMapValue('number_of_contract')"
      >
        {{ labelContractTotal }}
      </button>
    </div>
    <div class="tree-map-nested-nav" />
    <div class="tree-map-nested-tooltip-assignee" />
    <div class="tree-map-nested-tooltip-contracts" />
    <svg
      id="treemap-nested"
      :width="svgWidth"
      :height="svgHeight"
    />
  </div>
</template>
<script>

import { select, selectAll, mouse } from 'd3-selection'
import { treemap, stratify, hierarchy, treemapBinary } from 'd3-hierarchy'
import { scaleLinear } from 'd3-scale'
import { easeLinear } from 'd3-ease'
import { interpolate } from 'd3-interpolate';
import { sumDataByGroupKey, normalizeString } from "../lib/utils";
import { mean, median } from "d3-array";
import { nest } from "d3-collection";
import { money } from "lib/shared";

const d3 = { select, selectAll, treemap, stratify, scaleLinear, mouse, easeLinear, mean, median, nest, hierarchy, treemapBinary, interpolate }

export default {
  name: 'TreeMapNested',
  props: {
    data: {
      type: Array,
      default: () => []
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
    }
  },
  data() {
    return {
      svgWidth: 0,
      svgHeight: 800,
      dataTreeMapWithoutCoordinates: undefined,
      updateData: false,
      dataForTableTooltip: undefined,
      dataNewValues: undefined,
      sizeForTreemap: 'final_amount_no_taxes',
      selected_size: 'final_amount_no_taxes',
      labelContractAmount: I18n.t('gobierto_dashboards.dashboards.contracts.contract_amount'),
      labelContractTotal: I18n.t('gobierto_dashboards.dashboards.visualizations.tooltip_treemap'),
    }
  },
  watch: {
    data(newValue, oldValue) {
      if (newValue !== oldValue) {
        this.updateData = true
        this.dataNewValues = newValue
        this.deepCloneData(newValue)
      }
    }
  },
  mounted() {
    this.svgWidth = document.getElementsByClassName("dashboards-home-main")[0].offsetWidth;
    this.dataTreeMapWithoutCoordinates = JSON.parse(JSON.stringify(this.data));
    this.dataTreeMapSumFinalAmount = JSON.parse(JSON.stringify(this.data));

    this.transformDataTreemap(this.dataTreeMapWithoutCoordinates)
    /*this.resizeListener()*/
  },
  methods: {
    handleTreeMapValue(value) {
      if (this.selected_size === value) return;
      this.selected_size = value
      this.sizeForTreemap = value
      d3.select('.treemap-container')
      .remove()
      .exit();
      d3.select('.nav-breadcrumbs')
      .remove()
      .exit();
      if (this.updateData) {
        this.deepCloneData(this.dataNewValues)
      } else {
        this.deepCloneData(this.dataTreeMapWithoutCoordinates)
      }
    },
    transformDataTreemap(data) {

      let dataFilter = data
      dataFilter.filter(contract => contract.final_amount_no_taxes !== 0)

      dataFilter.forEach(d => {
        d.number_of_contract = 1
      })
      // d3v6
      //
      // const dataGroupTreeMap = Array.from(
      //   d3.group(data, d =>  d.contract_type, d.assignee),
      // );
      const nested_data = d3.nest()
        .key(d => d.contract_type)
        .key(d => d.assignee)
        .entries(dataFilter);
      let rootData = {};

      rootData.key = this.labelRootKey
      rootData.values = nested_data;

      rootData = replaceDeepKeys(rootData, this.sizeForTreemap);

      //d3 Nest add names to the keys that are not valid to build a treemap, we need to replace them
      function replaceDeepKeys(root, value_key) {
        for (var key in root) {
          if (key === "key") {
            root.name = root.key;
            delete root.key;
          }
          if (key === "values") {
            root.children = [];
            for (key in root.values) {
              root.children.push(replaceDeepKeys(root.values[key], value_key));
            }
            delete root.values;
          }
          if (key === value_key) {
            root.value = parseFloat(root[value_key]);
            delete root[value_key];
          }
        }
        return root;
      }

      this.buildTreeMap(rootData)
    },
    deepCloneData(data) {
      const dataTreeMap = JSON.parse(JSON.stringify(data));
      this.transformDataTreemap(dataTreeMap)
    },
    buildTreeMap(rootData) {
      if (this.updateData) {
        d3.select('.nav-breadcrumbs')
        .remove()
        .exit();
      }

      let transitioning;
      let dataTreeMapSumFinalAmount = this.dataTreeMapSumFinalAmount
      const selected_size = this.selected_size;
      this.height = 600 - this.marginTop - this.marginBottom
      const tooltip = d3.select('.tree-map-nested-tooltip-contracts')
      const tooltipAssignee = d3.select('.tree-map-nested-tooltip-assignee')

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

      const svg = d3.select('#treemap-nested')
        .attr("width", this.svgWidth + this.marginLeft + this.marginRight)
        .attr("height", this.height + this.marginBottom + this.marginTop)
        .style("margin-left", `${-this.marginLeft}px`)
        .style("margin.right", `${-this.marginRight}px`)
        .append("g")
        .attr('class', 'treemap-container')
        .attr("transform", `translate(${this.marginLeft},0)`)
        .style("shape-rendering", "crispEdges");

      const navBreadcrumbs = d3.select('.tree-map-nested-nav')
        .append('p')
        .attr("class", "nav-breadcrumbs")

      const root = d3.hierarchy(rootData);
      treemap(root
        .sum(d => d.value)
        .sort((a, b) => b.height - a.height || b.value - a.value)
      );
      display(root);

      function display(d) {
        navBreadcrumbs
          .datum(d.parent)
          .html(name(d));

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
          .attr('class', d => {
            let parentNameContract = ''
            const { depth } = d
            if (depth === 1) {
              const { data: { name = '' } } = d
              parentNameContract = name
            } else if (depth === 2) {
              const { parent: { data: { name = '' } } } = d
              parentNameContract = name
            }
            //Normalize and create an slug because Servicios de Gestión Públicos isn't a valid class
            parentNameContract = normalizeString(parentNameContract)
            return `depth ${parentNameContract}`
          })

        const g = g1.selectAll(".children")
          .data(d.children)
          .join("g")

        g.filter(d => d.children)
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
          .attr('class', d => {
            //The name can be the contractor or the type of contract so we have to extract the names of the object, and its parent
            const { data: { name }, parent: { data: { name: parentName = '' } } } = d
            let parentNameContract = parentName
            let sectionName = name
            //Normalize and create an slug because Servicios de Gestión Públicos isn't a valid css class
            sectionName = normalizeString(sectionName)
            parentNameContract = normalizeString(parentNameContract)
            return `children ${sectionName} ${parentNameContract}`
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
          .append("title")
          .text(d => d.data.name);

        g.append("foreignObject")
          .call(rect)
          .attr("class", "foreignobj")
          .append("xhtml:div")
          .html(d => {
            /*We can changes the text content of every rect with d.depth
            d.depth = 1 is the first level, type of contracts
            d.depth = 2 is the second level, beneficiaries by type of contracts
            d.depth = 3 is the last level, contracts of beneficiaries*/
            let title = d.data.name === undefined ? d.data.title : d.data.name;
            let labelTotalContracts = `${I18n.t('gobierto_dashboards.dashboards.contracts.contracts')}`
            let htmlForRect = ''
            const { depth } = d
            if (depth === 1) {
              let valueTotalAmount
              if (typeof d.data !== "function") {
                let contractType = d.data.name !== undefined ? d.data.name : ''
                const finalAmountTotal = sumDataByGroupKey(dataTreeMapSumFinalAmount, 'contract_type', 'final_amount_no_taxes')
                let totalAmount = finalAmountTotal.filter(contract => contract.contract_type === contractType)
                totalAmount = totalAmount.filter(contract => typeof contract.data !== "function")
                valueTotalAmount = totalAmount[0].final_amount_no_taxes
              }

              valueTotalAmount = selected_size === 'final_amount_no_taxes' ? d.value : valueTotalAmount

              let totalContracts = d.children === undefined ? '' : d.children
              if (totalContracts) {
                totalContracts = totalContracts.filter(contract => typeof contract.data !== "function").length
                labelTotalContracts = totalContracts > 1 ? labelTotalContracts : `${I18n.t('gobierto_dashboards.dashboards.contracts.contract')}`
              }
              htmlForRect = `<p class="title">${title}</p>
                <p class="text">${money(valueTotalAmount)}</p>
                <span class="text">
                  <b>${totalContracts}</b> ${labelTotalContracts}</b>
                </span>
                `
            } else if (depth === 2 && typeof d.data !== "function") {

              if (typeof d.data !== "function") {
                let contractType = d.data.name !== undefined ? d.data.name : ''
                const finalAmountTotal = sumDataByGroupKey(dataTreeMapSumFinalAmount, 'assignee', 'final_amount_no_taxes')
                let totalAmount = finalAmountTotal.filter(contract => contract.assignee === contractType)
                totalAmount = totalAmount.filter(contract => typeof contract.data !== "function")
                valueTotalAmount = totalAmount[0].final_amount_no_taxes
              }

              let valueTotalAmount = selected_size === 'final_amount_no_taxes' ? d.value : valueTotalAmount

              let totalContracts = d.children === undefined ? '' : d.children
              if (totalContracts) {
                totalContracts = totalContracts.filter(contract => typeof contract.data !== "function").length
                labelTotalContracts = totalContracts > 1 ? labelTotalContracts : `${I18n.t('gobierto_dashboards.dashboards.contracts.contract')}`
              }
              htmlForRect = `<p class="title">${title}</p>
                <p class="text">${money(valueTotalAmount)}</p>
                <span class="text">
                  <b>${totalContracts}</b> ${labelTotalContracts}</b>
                </span>
                `
            } else if (depth === 3) {
              htmlForRect = `
                <p class="title">${title}</p>
                `
            }
            return htmlForRect
          })
          .attr('class', d => {
            const { depth, y1, y0 } = d
            //y1 - y0 returns the height of the rect, if it's less than the 100 hide the text
            if (depth === 2 && (y(y1) - y(y0)) < 100 && selected_size === 'final_amount_no_taxes') {
              return 'treemap-nested-container-text hide-text'
            } else if (depth === 2 && (y1 - y0) < 40 && selected_size !== 'final_amount_no_taxes') {
              return 'treemap-nested-container-text hide-text'
            } else if (depth === 3) {
              let contractType = d.data.contract_type || ''
              //Normalize and create an slug because Servicios de Gestión Públicos isn't a valid css class
              contractType = normalizeString(contractType)
              return `treemap-nested-container-text ${contractType}`
            }
            return 'treemap-nested-container-text'
          })

        g.selectAll(".foreignobj")
        .on('mousemove', function(d) {
          const { depth } = d
          if (depth === 1) return;
          let title = d.data.name === undefined ? d.data.title : d.data.name;
          const coordinates = d3.mouse(this);
          const x = coordinates[0];
          const y = coordinates[1];

          //Elements to determinate the position of tooltip
          const container = document.getElementsByClassName('container-tree-map-nested')[0];
          const containerWidth = container.offsetWidth
          const tooltipWidth = tooltip.node().offsetWidth
          const positionWidthTooltip = x + tooltipWidth
          const positionTop = `${y - 20}px`
          const positionLeft = `${x + 10}px`
          const positionRight = `${x - tooltipWidth - 10}px`

          if (depth === 2) {
            let labelTotalContracts = `${I18n.t('gobierto_dashboards.dashboards.contracts.contracts')}`
            let totalContracts = d.children === undefined ? '' : d.children
            if (totalContracts) {
              totalContracts = totalContracts.filter(contract => typeof contract.data !== "function").length
              labelTotalContracts = totalContracts > 1 ? labelTotalContracts : `${I18n.t('gobierto_dashboards.dashboards.contracts.contract')}`
            }

            tooltipAssignee
              .style("display", "block")
              .html(() => {
                return `
                  <span class="beeswarm-tooltip-header-title">
                    ${title}
                  </span>
                  <p class="text-depth-third"><b>${totalContracts}</b> ${labelTotalContracts}</b></p>
                `
              })
              .style('top', positionTop)
              .style('left', positionWidthTooltip > containerWidth ? positionRight : positionLeft)

          } else if (depth === 3 && typeof d.data !== "function") {
            const { data: { initial_amount_no_taxes, status } } = d
            let valueTotalAmount
            if (typeof d.data !== "function") {
              let contractId = d.data.id !== undefined ? d.data.id : ''
              const finalAmountTotal = sumDataByGroupKey(dataTreeMapSumFinalAmount, 'id', 'final_amount_no_taxes')
              let totalAmount = finalAmountTotal.filter(contract => contract.id === contractId)
              valueTotalAmount = totalAmount[0].final_amount_no_taxes
            }

            valueTotalAmount = selected_size === 'final_amount_no_taxes' ? d.value : valueTotalAmount

            tooltip
              .style("display", "block")
              .html(() => {
                return `
                  <span class="beeswarm-tooltip-header-title">
                    ${title}
                  </span>
                  <p class="text-depth-third">${I18n.t('gobierto_dashboards.dashboards.contracts.contract_amount')}: <b>${money(valueTotalAmount)}</b></p>
                  <p class="text-depth-third">${I18n.t('gobierto_dashboards.dashboards.contracts.tender_amount')}: <b>${money(initial_amount_no_taxes)}</b></p>
                  <p class="text-depth-third">${I18n.t('gobierto_dashboards.dashboards.contracts.status')}: <b>${status}</b></p>
                `
              })
              .style('top', positionTop)
              .style('left', positionWidthTooltip > containerWidth ? positionRight : positionLeft)
          }
        })
        .on('mouseout', function() {
          tooltip.style('display', 'none')
          tooltipAssignee.style('display', 'none')
        })

        function transition(d) {
          if (transitioning || !d) return;
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
          // Fade-in entering text.
          g2.selectAll("text").style("fill-opacity", 0);
          g2.selectAll("foreignObject div").style("display", "none");
          /*added*/
          // Transition to the new view.
          t1.selectAll("text").call(text).style("fill-opacity", 0);
          t2.selectAll("text").call(text).style("fill-opacity", 1);
          t1.selectAll("rect").call(rect);
          t2.selectAll("rect").call(rect);
          /* Foreign object */
          t1.selectAll(".treemap-nested-container-text").style("display", "none");
          /* added */
          t1.selectAll(".foreignobj").call(foreign);
          /* added */
          t2.selectAll(".treemap-nested-container-text").style("display", "block");
          /* added */
          t2.selectAll(".foreignobj").call(foreign);
          /* added */
          // Remove the old node when the transition is finished.
          t1.on("end.remove", function() {
            this.remove();
            transitioning = false;
          });
        }
        return g;
      }

      function text(text) {
        text.attr("x", d => x(d.x) + 6)
          .attr("y", d => y(d.y) + 6);
      }

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

      function name(d) {
        return breadcrumbs(d) +
          (d.parent ? ` - ${I18n.t('gobierto_dashboards.dashboards.visualizations.zoom_out_treemap')}` : ` - ${I18n.t('gobierto_dashboards.dashboards.visualizations.zoom_in_treemap')}`);
      }

      function breadcrumbs(d) {
          let res = "";
          const sep = ` <i style="display: inline-block; vertical-align: middle;" class="fas fa-angle-right"></i> `;
          d.ancestors().reverse().forEach(({ data }) => {
            if (res.includes('<b>')) {
              res = res.replace(/<b>/g, '').replace(/<\/b>/g, '')
            }
            res += `<span><b>${data.name}</b></span>` + sep;
          });
          return res.split(sep).filter(i => i !== "").join(sep);
        }
    },
    resizeListener() {
      window.addEventListener("resize", () => {
        let dataResponsive = this.updateData ? this.deepCloneData(this.dataNewValues) : this.transformDataTreemap(this.data);
        const containerChart = document.getElementsByClassName('container-tree-map-nested')[0];
        this.svgWidth = containerChart.offsetWidth
        this.deepCloneData(dataResponsive)
      })
    }
  }
}
</script>
