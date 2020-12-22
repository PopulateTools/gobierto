import { csv } from "d3-fetch";
import { mean, median, sum } from "d3-array";
import { scaleOrdinal } from 'd3-scale';
import axios from "axios";

const d3 = { scaleOrdinal }

const endPointGobiertoData = `/api/v1/data/data.json`

export function getRemoteData(endpoint) {
  return csv(endpoint);
}

export function sortByField(dateField) {
  return function(a, b) {
    const aDate = a[dateField],
      bDate = b[dateField];

    if (aDate == "") {
      return 1;
    }

    if (bDate == "") {
      return -1;
    }

    if (aDate < bDate) {
      return 1;
    } else if (aDate > bDate) {
      return -1;
    } else {
      return 0;
    }
  };
}

export function sumDataByGroupKey(data, group, value) {
  let counts = data.reduce((prev, curr) => {
    let count = prev.get(curr[group]) || 0;
    prev.set(curr[group], curr[value] + count);
    return prev;
  }, new Map());

  let reducedArray = [...counts].map(([key, val]) => {
    return { [group]: key, [value]: val }
  })

  return reducedArray
}

export function getQueryData(params) {
  const qs = new URLSearchParams(params)
  return axios.get(`${endPointGobiertoData}?${qs.toString()}`);
}

export function normalizeString(string) {
  let slug = string.normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/ /g, '-')
    .replace(/[.,()\s]/g, '')
    .toLowerCase();
  return slug
}

export function createScaleColors(values, arrayDomain) {
  let colorsGobiertoExtend = ["#12365b", "#118e9c", "#ff766c", "#f7b200", "#158a2c", "#94d2cf", "#3a78c3", "#15dec5", "#6a7f2f", "#55f17b"]
  colorsGobiertoExtend = colorsGobiertoExtend.slice(0, values)

  const colors = d3.scaleOrdinal()
    .domain(arrayDomain)
    .range(colorsGobiertoExtend);
  return colors;
}

export function calculateSumMeanMedian(value) {
  let sumValue = sum(value) || 0
  let meanValue = mean(value) || 0
  let medianValue = median(value) || 0

  let values = [sumValue, meanValue, medianValue]

  return values
}
