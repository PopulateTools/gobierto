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

// The effective tender of a contract. The ETL publishes it in `tender_id`
// (COALESCE(establishment_tender_id, tender_id)), NULL for minor contracts, so
// it groups both the lots of a tender and the contracts derived from a framework
// agreement / dynamic acquisition system. Sites still serving the old CSV don't
// carry the column: there we fall back to `id`, which holds tenders.id for
// non-minor contracts. For minor ones `id` is contracts.id, a different id space
// that collides with the tenders one, so it is useless as a tender key and we
// return null.
//
// Note the order of the checks: `tender_id !== undefined` tells "column absent"
// (fall back) apart from "column present but empty" (a minor contract with no
// tender). Don't collapse it into `tender_id || ...`.
export const effectiveTenderId = ({ id, tender_id, minor_contract }) => {
  if (tender_id !== undefined) return tender_id || null;
  return minor_contract === 't' ? null : (id || null);
};

// The routing key of a contract. The ETL publishes `contract_id`, unique per
// contract (34,314 out of 34,314 in the UJI). `id` holds the effective tender
// since the ETL was fixed, so the 51 contracts derived from a single dynamic
// acquisition system share it and it cannot route. Sites still serving the old
// CSV don't carry the column: there we fall back to `id`, which is what their
// current URLs already use.
export const contractRoutingId = ({ id, contract_id }) => contract_id || id;
