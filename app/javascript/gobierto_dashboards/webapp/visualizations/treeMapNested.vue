<template>
  <div class="container-tree-map-nested">
    <div class="tree-map-nested-nav" />
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
import { treemap, stratify, hierarchy } from 'd3-hierarchy'
import { scaleLinear } from 'd3-scale'
import { easeLinear } from 'd3-ease'
import { mean, median } from "d3-array";
import { nest } from "d3-collection";
import { money } from "lib/shared";

const d3 = { select, selectAll, treemap, stratify, scaleLinear, mouse, easeLinear, mean, median, nest, hierarchy }

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
      default: 0
    },
    marginBottom: {
      type: Number,
      default: 30
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
      sizeForTreemap: 'value',
      selected_size: 'value',
      labelContractAmount: I18n.t('gobierto_dashboards.dashboards.contracts.contract_amount'),
      labelContractTotal: I18n.t('gobierto_dashboards.dashboards.visualizations.tooltip_treemap')
    }
  },
  watch: {
    data(newValue, oldValue) {
      if (newValue !== oldValue) {
        /*this.dataNewValues = newValue
        this.deepCloneData(newValue)
        this.updateData = true*/
      }
    }
  },
  mounted() {
    this.svgWidth = document.getElementsByClassName("dashboards-home-main")[0].offsetWidth;
    this.dataTreeMapWithoutCoordinates = JSON.parse(JSON.stringify(this.data));

    this.transformDataTreemap(this.dataTreeMapWithoutCoordinates)
    /*this.resizeListener()*/
  },
  methods: {
    transformDataTreemap(data) {

      let dataFilter = data
      dataFilter.filter(contract => contract.final_amount_no_taxes !== 0)

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

      //TODO: LOCALE
      rootData.key = "Adjudicataries";
      rootData.values = nested_data;

      rootData = replaceDeepKeys(rootData, "final_amount_no_taxes");

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
      this.dataForTooltips(dataTreeMap)
      this.transformDataTreemap(dataTreeMap)
    },
    buildTreeMap(rootData) {
      let transitioning;
      this.height = 600 - this.marginTop - this.marginBottom
      const tooltip = d3.select('.tree-map-nested-tooltip-contracts')

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
        .attr("transform", `translate(${this.marginLeft},${this.marginTop})`)
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
          .on("click", transition)
          .html(name(d));

        navBreadcrumbs
          .datum(d.parent)

        const g1 = svg
          .insert("g", ".nav-breadcrumbs")
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
            parentNameContract = parentNameContract.normalize('NFD')
              .replace(/[\u0300-\u036f]/g, '')
              .replace(/ /g, '-')
            return `depth ${parentNameContract}`
          })

        const g = g1.selectAll("g")
          .data(d.children)
          .enter()
          .append("g");

        g.filter(d => d.children)
          .attr('class', d => {
            //The name can be the contractor or the type of contract so we have to extract the names of the object, and its parent
            const { data: { name }, parent: { data: { name: parentName = '' } } } = d
            let parentNameContract = parentName
            let sectionName = name
            //Normalize and create an slug because Servicios de Gestión Públicos isn't a valid css class
            sectionName = sectionName.normalize('NFD')
              .replace(/[\u0300-\u036f]/g, '')
              .replace(/ /g, '-')
            return `children ${sectionName} ${parentNameContract}`
          })
          .on("click", transition);

        g.selectAll(".child")
          .data(d => d.children || [d])
          .enter()
          .append("rect")
          .attr("class", "child")
          .call(rect);

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
            let htmlForRect = ''
            const { depth } = d
            if (depth === 1 || depth === 2) {
              let totalContracts = d.children === undefined ? '' : d.children
              if (totalContracts) {
                totalContracts = totalContracts.filter(contract => typeof contract.data !== "function").length
              }
              htmlForRect = `<p class="title">${title}</p>
                <p class="text">${money(d.value)}</p>
                <span class="text">
                  <b>${totalContracts}</b> ${I18n.t('gobierto_dashboards.dashboards.contracts.contracts')}</b>
                </span>
                `
            } else if (depth === 3) {
              htmlForRect = `
                <p class="title">${title}</p>
                <p class="text-depth-third">${I18n.t('gobierto_dashboards.dashboards.contracts.contract_amount')}: <b>${money(d.value)}</b></p>
                `
            }
            return htmlForRect
          })
          .attr('class', d => {
            const { depth } = d
            if (depth === 3) {
              let contractType = d.data.contract_type || ''
              //Normalize and create an slug because Servicios de Gestión Públicos isn't a valid css class
              contractType = contractType.normalize('NFD')
                .replace(/[\u0300-\u036f]/g, '')
                .replace(/ /g, '-')
              return `treemap-nested-container-text ${contractType}`
            }
            return 'treemap-nested-container-text'
          })
          .on('mousemove', function(d) {
            const { depth } = d
            if (depth !== 3) return;

            let title = d.data.name === undefined ? d.data.title : d.data.name;
            const coordinates = d3.mouse(this);
            console.log("d3.mouse(this)", d3.mouse(this));
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

            const { data: { initial_amount_no_taxes, status } } = d

            tooltip
              .style("display", "block")
              .html(() => {
                return `
                  <span class="beeswarm-tooltip-header-title">
                    ${title}
                  </span>
                  <p class="text-depth-third">${I18n.t('gobierto_dashboards.dashboards.contracts.contract_amount')}: <b>${money(d.value)}</b></p>
                  <p class="text-depth-third">${I18n.t('gobierto_dashboards.dashboards.contracts.tender_amount')}: <b>${money(initial_amount_no_taxes)}</b></p>
                  <p class="text-depth-third">${I18n.t('gobierto_dashboards.dashboards.contracts.status')}: <b>${status}</b></p>
                `
              })
              .style('top', positionTop)
              .style('left', positionWidthTooltip > containerWidth ? positionRight : positionLeft)
          })
          .on('mouseout', function() {
            tooltip.style('display', 'none')
          })

        function transition(d) {
          if (transitioning || !d) return;
          transitioning = true;
          const g2 = display(d);
          const t1 = g1.transition().duration(450).ease(d3.easeLinear);;
          const t2 = g2.transition().duration(450).ease(d3.easeLinear);;
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
      }

      function foreign(foreign) {
        foreign
          .attr("x", ({ x0 }) => x(x0))
          .attr("y", ({ y0 }) => y(y0))
          .attr("width", ({ x1, x0 }) => x(x1) - x(x0))
          .attr("height", ({ y1, y0 }) => y(y1) - y(y0));
      }

      function name(d) {
        console.log("d", d);
        return breadcrumbs(d) +
          (d.parent ?
           //TODO: LOCALES
            " -  Click to zoom out" :
            " - Click inside square to zoom in");
      }

      function breadcrumbs(d) {
          let res = "";
          const sep = ` <i style="display: inline-block; vertical-align: middle;" class="fas fa-angle-right"></i> `;
          d.ancestors().reverse().forEach(({ data }) => {
            if (res.includes('<b>')) {
              res = res.replace(/<b>/g, '').replace(/<\/b>/g, '')
            }
            res += `<b>${data.name}</b>` + sep;
          });
          return res.split(sep).filter(i => i !== "").join(sep);
        }
    },
    resizeListener() {
      window.addEventListener("resize", () => {
        let dataResponsive = this.updateData ? this.deepCloneData(this.dataNewValues) : this.transformDataTreemap(this.data);
        const containerChart = document.getElementsByClassName('container-tree-map')[0];
        this.svgWidth = containerChart.offsetWidth
        this.deepCloneData(dataResponsive)
      })
    }
  }
}
</script>
