import * as d3 from 'd3';

export function createScaleColors(values, arrayDomain) {
  let colorsGobiertoExtend = ["var(--color-gobierto-turquoise)", "var(--color-gobierto-blue)", "var(--color-gobierto-red)", "var(--color-gobierto-yellow)", "var(--color-gobierto-extra-5)", "var(--color-gobierto-extra-6)", "var(--color-gobierto-extra-7)", "var(--color-gobierto-extra-8)", "var(--color-gobierto-extra-9)", "var(--color-gobierto-extra-10)" ]
  colorsGobiertoExtend = colorsGobiertoExtend.slice(0, values)

  const colors = d3.scaleOrdinal()
    .domain(arrayDomain)
    .range(colorsGobiertoExtend);
  return colors;
}
