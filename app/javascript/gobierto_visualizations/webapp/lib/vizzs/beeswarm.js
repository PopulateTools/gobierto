import { BeeSwarm as UpstreamBeeSwarm } from "gobierto-vizzs";
import { forceSimulation, forceX, forceY, forceCollide } from "d3-force";

/**
 * Performance patches over gobierto-vizzs@3.2.0 BeeSwarm, needed for large
 * datasets (tens of thousands of contracts). Remove once they land upstream
 * (gobierto/gobierto-vizzs):
 *
 * - parse() and groupBy() spread their accumulator on every row, making them
 *   O(n²) — hundreds of millions of element copies at ~20k rows, on initial
 *   load and on every filter change.
 * - build() never keeps a handle on its forceSimulation, so every
 *   setData()/resize leaves one more simulation running, all fighting to
 *   position the same circles.
 */
export class BeeSwarm extends UpstreamBeeSwarm {
  parse(data) {
    // Same semantics as upstream: drop rows without X value, coerce X to Date
    // and value to Number, but in a single O(n) pass.
    const parsed = [];
    for (const d of data) {
      if (d[this.xAxisProp]) {
        parsed.push({
          ...d,
          [this.xAxisProp]: new Date(d[this.xAxisProp]),
          [this.valueProp]: +d[this.valueProp]
        });
      }
    }
    return parsed;
  }

  groupBy(arr, key) {
    const groups = {};
    for (const item of arr) {
      (groups[item[key]] || (groups[item[key]] = [])).push(item);
    }
    return groups;
  }

  // Copied verbatim from upstream build(), except the previous simulation is
  // stopped and the new one is kept in this.simulation.
  build() {
    this.setScales();

    this.g
      .select(".axis-x")
      .attr("transform", `translate(0 ${this.height})`)
      .call(this.xAxis.bind(this));

    this.g
      .select(".axis-y")
      .attr("transform", `translate(${-this.margin.left} ${-this.scaleY.bandwidth() / 2})`)
      .call(this.yAxis.bind(this));

    if (this.simulation) {
      this.simulation.stop();
    }

    this.simulation = forceSimulation(this.data)
      .force(
        "x",
        forceX((d) => this.scaleX(d[this.xAxisProp]))
      )
      .force(
        "y",
        forceY((d) => this.scaleY(d[this.yAxisProp]))
      )
      .force(
        "collide",
        forceCollide().radius((d) => this.scaleRadius(d[this.valueProp]) + 1)
      )
      .on("tick", () =>
        this.g
          .selectAll("circle.beeswarm-circle")
          .attr("cx", (d) => d.x)
          .attr("cy", (d) => d.y)
      );

    this.g
      .selectAll("circle.beeswarm-circle")
      .data(this.data, d => d[this.idProp])
      .join((enter) =>
        enter
          .append("circle")
          .attr("class", d => this.relationProp ? `beeswarm-circle beeswarm-circle-${d[this.relationProp]}` : "beeswarm-circle")
          .attr("r", (d) => this.scaleRadius(d[this.valueProp]))
          .attr("fill", (d) => this.scaleColor(d[this.yAxisProp]))
      )
      .on("touchmove", e => e.preventDefault())
      .on("pointermove", this.onPointerMove.bind(this))
      .on("pointerout", this.onPointerOut.bind(this))
      .attr("cursor", "pointer")
      .on("click", (...e) => this.onClick(...e));
  }

  remove() {
    if (this.simulation) {
      this.simulation.stop();
    }
    super.remove();
  }
}
