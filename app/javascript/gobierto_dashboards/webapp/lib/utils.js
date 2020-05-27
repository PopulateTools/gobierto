import * as d3 from 'd3'

export function getRemoteData(endpoint) {
  return new Promise((resolve) => {
    d3.csv(endpoint)
      .mimeType("text/csv")
      .get(function(error, csv) {
        if (error) throw error;

        resolve(csv);
      });
  })
}
