import { scaleOrdinal } from 'd3-scale';

export function createScaleColors(values, arrayDomain) {
  let colorsGobiertoExtend = ["#118e9c", "#12365b", "#ff766c", "#f7b200", "#158a2c", "#94d2cf", "#3a78c3", "#15dec5", "#6a7f2f", "#55f17b"]
  colorsGobiertoExtend = colorsGobiertoExtend.slice(0, values)

  const colors = scaleOrdinal()
    .domain(arrayDomain)
    .range(colorsGobiertoExtend);
  return colors;
}
