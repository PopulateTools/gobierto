import { csv } from "d3-fetch";
import axios from "axios";

//TODO changes to location.origin
const endPointGobiertoData = `https://getafe.gobify.net/api/v1/data/data.json`

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

