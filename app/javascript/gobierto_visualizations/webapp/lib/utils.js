import axios from 'axios';
import * as d3 from 'd3';

const endPointGobiertoData = `/api/v1/data/data.json`

export function getRemoteData(endpoint) {
  return d3.csv(endpoint);
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

export function calculateSumMeanMedian(value) {
  let sumValue = d3.sum(value) || 0
  let meanValue = d3.mean(value) || 0
  let medianValue = d3.median(value) || 0;

  let values = [sumValue, meanValue, medianValue]

  return values
}

export const toNumber = (value) => value ? +(parseFloat(value)) : 0;
